import CoreData
import SwiftUI

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
        request.predicate = NSPredicate(format: "survey_id == %@", survey.survey_id! as CVarArg)

        do {
            questions = try context.fetch(request)
        } catch {
            print("❌ Failed loadQuestions:", error)
        }
    }

    func addQuestion(type: String) {
        let q = Question(context: context)
        q.question_id = UUID()
        q.question_type = type
        q.question_text = "Pertanyaan Baru"
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
}
