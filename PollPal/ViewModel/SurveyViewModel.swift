import CoreData
import PhotosUI
import SwiftUI

class SurveyViewModel: ObservableObject {

    @Published var questions: [Question] = []
    @Published var responses: [DResponse] = []
    var onSurveyPublished: (() -> Void)?

    private let context: NSManagedObjectContext
    private var survey: Survey

    init(context: NSManagedObjectContext, survey: Survey) {
        self.context = context
        self.survey = survey
        loadQuestions()
        fetchResponses()
    }
    func loadQuestions() {
            let request: NSFetchRequest<Question> = Question.fetchRequest()

            // 1. FILTER: Hanya ambil pertanyaan milik survey ini
            request.predicate = NSPredicate(format: "in_survey == %@", survey)
            
            // 2. ✅ SORTING: Urutkan berdasarkan waktu pembuatan (Lama -> Baru)
            // Pastikan Anda sudah menambahkan atribut 'question_created_at' di Core Data Editor!
            request.sortDescriptors = [
                NSSortDescriptor(key: "question_created_at", ascending: true)
            ]

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
            
            // ✅ PENTING: Simpan tanggal pembuatan saat tombol ditekan
            q.question_created_at = Date()

            // Assign survey_id manual
            q.in_survey = survey

            saveContext()
            updateSurveyPoints()
            loadQuestions() // Refresh list agar UI update sesuai urutan
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

    func publishSurvey() -> Bool {

        // 2. Update Points terakhir (Harus di sini agar survey_points terbaru)
        //        updateSurveyPoints()

        // 1. PASTIKAN SURVEY MEMILIKI OWNER & AMBIL POIN TERBARU
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

                // Coba ambil User dari Core Data
                if let userOwner = try? context.fetch(req).first {
                    survey.owned_by_user = userOwner
                    // Tidak perlu saveContext() di sini, karena akan disave nanti
                    print(
                        "✅ User owner linked successfully in publishSurvey()."
                    )
                }
            }
        }

        // 3. VALIDASI POIN DAN OWNER
        // Guard ini sekarang akan menggunakan owner yang BARU SAJA dicoba di-link di atas.
        guard let owner = survey.owned_by_user else {
            print(
                "❌ Cannot publish: User owner not found after linking attempt."
            )
            survey.is_public = false  // 🔥 TAMBAHAN
            saveContext()
            return false  // Gagal jika User tetap tidak ditemukan
        }

        let requiredPoints = survey.survey_points

        if owner.user_point < requiredPoints {
            print(
                "⚠️ Publish cancelled: Insufficient user points. Current: \(owner.user_point), Needed: \(requiredPoints)"
            )
            survey.is_public = false  // 🔥 TAMBAHAN
            saveContext()
            return false  // Gagal jika poin tidak cukup
        }

        // 4. JIKA POIN CUKUP, set status ke public
        survey.is_public = true
        survey.survey_status_del = false

        // Simpan status survey (belum termasuk transaksi pengurangan poin)
        saveContext()

        print("✅ Survey status updated to Public (Points deduction pending).")
        return true
    }

    func deductUserPoints() -> Bool {
        guard let owner = survey.owned_by_user else {
            print("⚠️ Failed to deduct points: Survey owner is nil.")
            return false
        }

        let pointsToDeduct = survey.survey_points
        let currentPoints = owner.user_point

        if currentPoints >= pointsToDeduct {
            owner.user_point = currentPoints - pointsToDeduct
            saveContext()
            print(
                "✅ Points deducted successfully. User: \(owner.user_name ?? "Unknown"), New Points: \(owner.user_point)"
            )
            return true
        } else {
            print(
                "❌ Failed to deduct points: Insufficient points. Current: \(currentPoints), Needed: \(pointsToDeduct)"
            )
            // Jika perlu, tambahkan logika untuk menandai bahwa user tidak bisa publish
            return false
        }
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

    func recordSurveyCostTransaction(for survey: Survey, cost: Int) {
        guard let user = survey.owned_by_user else {
            print(
                "❌ ERROR: User not linked to survey, cannot record transaction."
            )
            return
        }

        // Cek Poin sebelum mengurangi, untuk jaminan ekstra
        if user.user_point < Int32(cost) {
            print(
                "❌ ERROR: User points (\(user.user_point)) are insufficient for cost \(cost)."
            )
            // Mungkin perlu throw error atau mengembalikan Bool di sini
            return
        }

        // 1. Buat objek Transaction baru
        let transaction = Transaction(context: context)
        transaction.transaction_id = UUID()
        transaction.transaction_point_change = Int32(-cost)  // Nilai negatif
        transaction.transaction_description =
            "Survey Cost: \(survey.survey_title ?? "Untitled Survey")"
        transaction.transaction_status_del = false
        transaction.transaction_created_at = Date()
        transaction.transaction_type = "COST SURVEY"

        // Hubungkan ke User dan Survey
        transaction.owned_by_user = user
        transaction.in_survey = survey

        // 2. Kurangi Poin User
        user.user_point -= Int32(cost)

        // 3. Coba simpan perubahan ke Core Data
        do {
            try context.save()
            print(
                "✅ Transaction recorded and User points updated successfully. New point: \(user.user_point)"
            )

            // 4. Panggil closure untuk refresh Dashboard (PENTING!)
            // Ini akan memicu dashboardVM.refetchData() dari parent view.
            self.onSurveyPublished?()

        } catch {
            print(
                "❌ Failed to save transaction and update user points: \(error.localizedDescription)"
            )
            context.rollback()
        }
    }

    // In SurveyViewModel.swift
    func closeSurvey() {
        survey.is_public = true
        survey.survey_status_del = true  // <--- TANDAI SEBAGAI FINISHED
        saveContext()
        objectWillChange.send()
    }
    
    func deleteQuestion(_ question: Question) {
        context.delete(question)

        if let index = questions.firstIndex(of: question) {
            questions.remove(at: index)
        }

        do {
            try context.save()
        } catch {
            print("❌ Failed to delete question:", error)
        }
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
