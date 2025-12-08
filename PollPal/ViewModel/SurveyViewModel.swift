import CoreData
import SwiftUI
import PhotosUI

class SurveyViewModel: ObservableObject {

    @Published var questions: [Question] = []

    private let context: NSManagedObjectContext
    private var survey: Survey

    init(context: NSManagedObjectContext, survey: Survey) {
        self.context = context
        self.survey = survey
        loadQuestions()
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

        save()
        loadQuestions()
    }
    

    func save() {
        do { try context.save() }
        catch { print("❌ Save error:", error) }
    }
    
    func saveImage(_ image: UIImage) {
        guard let data = image.jpegData(compressionQuality: 0.8) else { return }

        let filename = UUID().uuidString + ".jpg"
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
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
        guard let data = image.jpegData(compressionQuality: 0.8) else { return nil }

        let filename = UUID().uuidString + ".jpg"
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(filename)

        do {
            try data.write(to: url)
            return url.absoluteString
        } catch {
            print("Failed saving image:", error)
            return nil
        }
    }
    
    func createSurveyIfNeeded() {
        if survey.survey_created_at == nil {
            survey.survey_created_at = Date()
            survey.survey_id = UUID()
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
                if let data = try? await newItem.loadTransferable(type: Data.self),
                   let uiImg = UIImage(data: data) {
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

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {

            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }

            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}
