import Foundation
import CoreData

extension Question {

    // MARK: - SAFE TEXT (title)
    var safeText: String {
        get { question_text ?? "" }
        set { question_text = newValue }
    }

    // MARK: - SAFE TYPE (enum wrapper)
    var safeType: QuestionType {
        get {
            QuestionType(rawValue: question_type ?? "") ?? .shortAnswer
        }
        set {
            question_type = newValue.rawValue
        }
    }

    // MARK: - OPTIONS ARRAY (pakai relationship)
    var optionsArray: [Option] {
        let set = has_option as? Set<Option> ?? []

        return set.sorted { a, b in
            (a.option_id?.uuidString ?? "") < (b.option_id?.uuidString ?? "")
        }
    }

    // MARK: - Add Option
    func addOption(text: String, context: NSManagedObjectContext) {
        let newOption = Option(context: context)

        newOption.option_id = UUID()
        newOption.option_text = text
        newOption.in_question = self       // RELATIONSHIP BENAR
    }

    // MARK: - Delete Option
    func deleteOption(_ option: Option, context: NSManagedObjectContext) {
        context.delete(option)
    }

}
