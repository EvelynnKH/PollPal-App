import CoreData
import PhotosUI
import SwiftUI

class SurveyViewModel: ObservableObject {

    @Published var questions: [Question] = []
    @Published var responses: [DResponse] = []

    private let context: NSManagedObjectContext
    private var survey: Survey

    init(context: NSManagedObjectContext, survey: Survey) {
        self.context = context
        self.survey = survey
        loadQuestions()
        fetchResponses()
    }

    func loadQuestions() {
        let request = Question.fetchRequest()

        // FILTER BERDASARKAN SURVEY
        request.predicate = NSPredicate(format: "in_survey == %@", survey)

        do {
            questions = try context.fetch(request)
        } catch {
            print("❌ Failed loadQuestions:", error)
        }
    }

    func addQuestion(type: QuestionType) {
        let q = Question(context: context)
        q.question_id = UUID()
        q.question_type = type.rawValue
        q.question_text = "Enter Your Question"
        q.question_status_del = false
        q.question_price = 0
        q.question_img_url = nil

        // assign survey_id manual
        q.in_survey = survey

        saveContext()
        updateSurveyPoints()
        loadQuestions()
    }
    
    func calculateTotalPoints() -> Int {
        var total = 0
        for q in questions {
            total += q.safeType.pointCost
        }
        return total
    }

    
    func updateSurveyPoints() {
        survey.survey_points = Int32(calculateTotalPoints())
    }

    func createSurveyIfNeeded() {
        if survey.survey_created_at == nil {
            survey.survey_created_at = Date()
            survey.survey_id = UUID()
            survey.survey_status_del = false

        }
    }

    func saveSurvey() {
        survey.is_public = false

        if survey.owned_by_user == nil {
            if let uuidString = UserDefaults.standard.string(
                forKey: "logged_in_user_id"
            ),
                let uuid = UUID(uuidString: uuidString)
            {
                let req: NSFetchRequest<User> = User.fetchRequest()
                req.predicate = NSPredicate(
                    format: "user_id == %@",
                    uuid as CVarArg
                )
                if let u = try? context.fetch(req).first {
                    survey.owned_by_user = u
                }
            }
        }
        saveContext()
        printSurveyAttributes()
    }

    func publishSurvey() {
        survey.is_public = true
        survey.survey_status_del = false
        if survey.owned_by_user == nil {
            if let uuidString = UserDefaults.standard.string(
                forKey: "logged_in_user_id"
            ),
                let uuid = UUID(uuidString: uuidString)
            {
                let req: NSFetchRequest<User> = User.fetchRequest()
                req.predicate = NSPredicate(
                    format: "user_id == %@",
                    uuid as CVarArg
                )
                if let u = try? context.fetch(req).first {
                    survey.owned_by_user = u
                }
            }
        }
        saveContext()
        printSurveyAttributes()
    }

    private func saveContext() {
        do {
            try context.save()
            print("✅ Context saved successfully.")
        } catch {
            print("❌ Failed to save context:", error)
        }
    }

    func saveCategories(_ categories: [String], for survey: Survey) {
        for name in categories {
            // Cek kalau category sudah ada
            let req: NSFetchRequest<Category> = Category.fetchRequest()
            req.predicate = NSPredicate(format: "category_name == %@", name)

            let existing = try? context.fetch(req).first

            let cat: Category

            if let existing = existing {
                cat = existing  // sudah ada → pakai ini aja
            } else {
                // belum ada → create baru
                cat = Category(context: context)
                cat.category_id = UUID()
                cat.category_name = name
            }

            // MARK: - RELATION
            cat.addToIn_survey(survey)
        }

        saveContext()
    }

    private func printSurveyAttributes() {
        print("------------ SURVEY DATA ------------")
        print("ID: \(survey.survey_id?.uuidString ?? "nil")")
        print("Title: \(survey.survey_title ?? "nil")")
        print("Desc: \(survey.survey_description ?? "nil")")
        print("Created At: \(String(describing: survey.survey_created_at))")
        print("Updated At: \(String(describing: survey.survey_updated_at))")
        print("Is Public: \(survey.is_public)")
        print("Is Deleted: \(survey.survey_status_del)")

        if let owner = survey.owned_by_user {
            print("Owned Oleh ->")
            print("   User ID: \(owner.user_id?.uuidString ?? "nil")")
            print("   User Name: \(owner.user_name ?? "nil")")
        } else {
            print("Owned Oleh: nil (❌ belum pernah diset)")
        }

        let active = fetchActiveSurveys()
        print("Active Surveys Count: \(active.count)")
        print("------------------------------------")
    }

    @Published var activeSurveys: [Survey] = []

    private func fetchActiveSurveys() -> [Survey] {
        let req: NSFetchRequest<Survey> = Survey.fetchRequest()

        // ambil semua yg tidak deleted
        req.predicate = NSPredicate(format: "survey_status_del == NO")
        req.sortDescriptors = [
            NSSortDescriptor(
                keyPath: \Survey.survey_created_at,
                ascending: false
            )
        ]

        do {
            let result = try context.fetch(req)
            self.activeSurveys = result

            print("📌 Active surveys count: \(result.count)")
            for s in result {
                print(
                    " → \(s.survey_title ?? "(no title)") | id=\(s.survey_id?.uuidString ?? "-")"
                )
            }

            return result
        } catch {
            print("❌ fetchActiveSurveys error:", error)
            return []
        }
    }

    func refreshSurvey() {
        let req: NSFetchRequest<Survey> = Survey.fetchRequest()
        req.predicate = NSPredicate(
            format: "survey_id == %@",
            survey.survey_id! as CVarArg
        )

        if let updated = try? context.fetch(req).first {
            self.survey = updated  // ⬅️ replace old object!
        }
    }

    func saveImage(_ image: UIImage) {
        guard let data = image.jpegData(compressionQuality: 0.8) else { return }

        let filename = UUID().uuidString + ".jpg"
        let url = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        )[0]
        .appendingPathComponent(filename)

        do {
            let q = Question(context: context)
            try data.write(to: url)
            q.question_img_url = url.absoluteString

            try context.save()
            print("Saved image at:", url.absoluteString)

        } catch {
            print("Error saving image:", error)
        }
    }

    func saveImageReturnURL(_ image: UIImage) -> String? {
        guard let data = image.jpegData(compressionQuality: 0.8) else {
            return nil
        }

        let filename = UUID().uuidString + ".jpg"
        let url = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        )[0]
        .appendingPathComponent(filename)

        do {
            try data.write(to: url)
            return url.absoluteString
        } catch {
            print("Failed saving image:", error)
            return nil
        }
    }

    func getResponseFor(_ question: Question) -> DResponse {
        let r = DResponse(context: context)
        r.dresponse_answer_text = ""
        r.in_question = question
        return r
    }

    func reset() {
        // drop in-memory cache
        DispatchQueue.main.async {
            self.questions.removeAll()
        }

        // rollback any unsaved changes in the context so UI shows clean state
        if context.hasChanges {
            context.rollback()
        }
    }

    /// (Optional) If you want to delete the current survey from Core Data entirely:
    func deleteCurrentSurvey() {
        context.delete(survey)
        do {
            try context.save()
        } catch {
            print("Failed to delete survey: \(error)")
            context.rollback()
        }
    }

    func responsesFor(_ question: Question) -> [DResponse] {
        responses.filter { $0.in_question == question }
    }

    func fetchResponses() {
        let req: NSFetchRequest<DResponse> = DResponse.fetchRequest()
        req.predicate = NSPredicate(
            format: "in_question.in_survey == %@",
            survey
        )

        do {
            responses = try context.fetch(req)
        } catch {
            print("❌ fetchResponses error:", error)
        }
    }

    // In SurveyViewModel.swift
    func closeSurvey() {
        survey.is_public = false
        survey.survey_status_del = true // <--- TANDAI SEBAGAI FINISHED
        saveContext()
        objectWillChange.send()
    }

}

struct ImagePickerForQuestion: View {
    @Binding var selectedImage: UIImage?
    @State private var item: PhotosPickerItem?

    var body: some View {
        PhotosPicker(
            selection: $item,
            matching: .images
        ) {
            Text("Select Image")
                .font(.headline)
        }
        .onChange(of: item) { newItem in
            guard let newItem else { return }
            Task {
                if let data = try? await newItem.loadTransferable(
                    type: Data.self
                ),
                    let uiImg = UIImage(data: data)
                {
                    await MainActor.run {
                        selectedImage = uiImg
                    }
                }
            }
        }
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode
    @Binding var image: UIImage?

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.allowsEditing = false
        return picker
    }

    func updateUIViewController(
        _ uiViewController: UIImagePickerController,
        context: Context
    ) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UINavigationControllerDelegate,
        UIImagePickerControllerDelegate
    {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController
                .InfoKey: Any]
        ) {

            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }

            parent.presentationMode.wrappedValue.dismiss()
        }
    }

}
