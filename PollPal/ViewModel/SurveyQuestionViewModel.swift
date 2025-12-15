//
//  SurveyQuestionViewModel.swift
//  PollPal
//
//  Created by student on 08/12/25.
//

import CoreData
import Foundation
import SwiftUI

class SurveyQuestionViewModel: ObservableObject {
    private var viewContext: NSManagedObjectContext
    let survey: Survey
    
    @Published var questions: [Question] = []
    @Published var currentIndex: Int = 0
    @Published var showSuccessScreen = false
    
    // --- PENYIMPANAN JAWABAN ---
    
    // 1. Single Select (Multiple Choice, Drop Down, Linear Scale)
    // Key: QuestionID, Value: OptionID
    @Published var singleSelectionAnswers: [UUID: UUID] = [:]
    
    // 2. Multi Select (Check Box)
    // Key: QuestionID, Value: Set of OptionIDs
    @Published var multiSelectionAnswers: [UUID: Set<UUID>] = [:]
    
    // 3. Text Input (Short Answer, Paragraph)
    // Key: QuestionID, Value: String Text
    @Published var textAnswers: [UUID: String] = [:]
    
    private var currentUserUUID: UUID? {
        if let idString = UserDefaults.standard.string(
            forKey: "logged_in_user_id"
        ) {
            return UUID(uuidString: idString)
        }
        return nil
    }
    
    init(context: NSManagedObjectContext, survey: Survey) {
        self.viewContext = context
        self.survey = survey
        loadQuestions()
    }
    
    private func loadQuestions() {
        if let questionSet = survey.has_question as? Set<Question> {
            // Sort by text (atau logic lain jika ada field index)
            self.questions = questionSet.sorted {
                ($0.question_text ?? "") < ($1.question_text ?? "")
            }
        }
    }
    
    // MARK: - Computed Properties
    var currentQuestion: Question? {
        guard questions.indices.contains(currentIndex) else { return nil }
        return questions[currentIndex]
    }
    
    var progressString: String { "\(currentIndex + 1)/\(questions.count)" }
    var progressFraction: Double {
        Double(currentIndex + 1) / Double(max(questions.count, 1))
    }
    var isLastQuestion: Bool { currentIndex == questions.count - 1 }
    
    // Validasi tombol Next
    var canGoNext: Bool {
        guard let q = currentQuestion, let qID = q.question_id else {
            return false
        }
        let type = q.question_type ?? ""
        
        switch type {
        case "Multiple Choice", "Drop Down", "Linear Scale":
            return singleSelectionAnswers[qID] != nil
            
        case "Check Box":
            // Harus pilih minimal 1
            let selectedSet = multiSelectionAnswers[qID] ?? []
            return !selectedSet.isEmpty
            
        case "Short Answer", "Paragraph":
            let text = textAnswers[qID] ?? ""
            return !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            
        default:
            return true
        }
    }
    
    // MARK: - Actions
    
    // Untuk Single Select (Radio / Dropdown / Scale)
    func selectSingleOption(questionId: UUID, optionId: UUID) {
        singleSelectionAnswers[questionId] = optionId
    }
    
    // Untuk Check Box (Toggle)
    func toggleMultiOption(questionId: UUID, optionId: UUID) {
        var currentSet = multiSelectionAnswers[questionId] ?? []
        if currentSet.contains(optionId) {
            currentSet.remove(optionId)
        } else {
            currentSet.insert(optionId)
        }
        multiSelectionAnswers[questionId] = currentSet
    }
    
    func bindingForText(questionId: UUID) -> Binding<String> {
        Binding(
            get: { self.textAnswers[questionId] ?? "" },
            set: { self.textAnswers[questionId] = $0 }
        )
    }
    
    func nextPage() {
        if isLastQuestion {
            submitSurvey()
        } else {
            currentIndex += 1
        }
    }
    
    func prevPage() {
        if currentIndex > 0 { currentIndex -= 1 }
    }
    
    // MARK: - SUBMIT LOGIC
    private func submitSurvey() {
        guard let userId = currentUserUUID else {
            print("❌ Submit failed: Current user UUID not found.")
            return
        }
        
        // Use viewContext.performAndWait for Core Data operations on the private queue
        viewContext.performAndWait {
            // 1. Fetch User (The user who is filling the survey)
            let userReq: NSFetchRequest<User> = User.fetchRequest()
            userReq.predicate = NSPredicate(
                format: "user_id == %@",
                userId as CVarArg
            )
            guard let user = try? viewContext.fetch(userReq).first else {
                print("❌ Submit failed: User object not found for UUID.")
                return
            }
            
            // Ensure survey has a point value
            let rewardPoints = survey.survey_points
            
            // 2. Buat HResponse (Header Response)
            let hRes = HResponse(context: viewContext)
            hRes.hresponse_id = UUID()
            hRes.submitted_at = Date()
            hRes.in_survey = survey
            hRes.is_filled_by_user = user
            
            // 3. Simpan Jawaban (DResponse) - The existing logic for DResponse is fine
            for question in questions {
                guard let qID = question.question_id else { continue }
                let type = question.question_type ?? ""
                
                // --- CASE 1: MULTI SELECT (CHECK BOX) ---
                if type == "Check Box" {
                    if let selectedSet = multiSelectionAnswers[qID] {
                        for optionID in selectedSet {
                            createDResponse(
                                hRes: hRes,
                                question: question,
                                optionID: optionID,
                                text: nil
                            )
                        }
                    }
                }
                // --- CASE 2: SINGLE SELECT ---
                else if ["Multiple Choice", "Drop Down", "Linear Scale"]
                    .contains(type)
                {
                    if let optionID = singleSelectionAnswers[qID] {
                        createDResponse(
                            hRes: hRes,
                            question: question,
                            optionID: optionID,
                            text: nil
                        )
                    }
                }
                // --- CASE 3: TEXT ---
                else if ["Short Answer", "Paragraph"].contains(type) {
                    let text = textAnswers[qID]
                    if let textContent = text, !textContent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        createDResponse(
                            hRes: hRes,
                            question: question,
                            optionID: nil,
                            text: textContent
                        )
                    }
                }
                // Note: If a question type is not covered and has no answer, no DResponse is created, which is acceptable.
            }
            
            // 🔥 4. RECORD TRANSACTION (REWARD) 🔥
            if rewardPoints > 0 {
                let trans = Transaction(context: viewContext)
                trans.transaction_id = UUID()
                trans.transaction_point_change = rewardPoints // Nilai positif untuk reward
                trans.transaction_description = "Reward Survey: \(survey.survey_title ?? "Untitled Survey")"
                trans.transaction_status_del = false
                trans.owned_by_user = user
                trans.in_survey = survey
                trans.transaction_created_at = Date()
                trans.transaction_type = "REWARD SURVEY"
                
                print("✅ Transaction recorded: +\(rewardPoints) points.")
                
                // 5. Update Poin User
                user.user_point += rewardPoints // Add the points to the user
                print("User \(user.user_name ?? "Unknown") new point total: \(user.user_point)")
            } else {
                print("⚠️ Survey has 0 points reward, no transaction recorded.")
            }
            
            // 6. Save Context (All changes are committed here)
            do {
                try viewContext.save()
                DispatchQueue.main.async { self.showSuccessScreen = true }
                print("✅ Survey submission and reward transaction saved successfully.")
            } catch {
                print("❌ Submit Error: Failed to save context: \(error)")
                viewContext.rollback() // Rollback if save fails
            }
        }
    }
    
    // Helper untuk membuat DResponse
    //    private func createDResponse(hRes: HResponse, question: Question, optionID: UUID?, text: String?) {
    //        let dRes = DResponse(context: viewContext)
    //        dRes.dresponse_id = UUID()
    //        dRes.dresponse_status_del = false
    //
    //        // Relasi
    //        dRes.setValue(hRes, forKey: "in_hresponse") // Pastikan nama relasi benar di Core Data
    //        dRes.in_question = question
    //
    //        // Jika ada Option ID
    //        if let optID = optionID {
    //            let req: NSFetchRequest<Option> = Option.fetchRequest()
    //            req.predicate = NSPredicate(format: "option_id == %@", optID as CVarArg)
    //            if let option = try? viewContext.fetch(req).first {
    //                dRes.setValue(option, forKey: "has_option") // Pastikan nama relasi benar
    //                dRes.dresponse_answer_text = option.option_text // Simpan teks juga sebagai backup
    //            }
    //        }
    //
    //        // Jika Text Input
    //        if let txt = text {
    //            dRes.dresponse_answer_text = txt
    //        }
    //    }
    
    private func createDResponse(
        hRes: HResponse,
        question: Question,
        optionID: UUID?,
        text: String?
    ) {
        let dRes = DResponse(context: viewContext)
        dRes.dresponse_id = UUID()
        dRes.dresponse_status_del = false
        
        dRes.in_hresponse = hRes
        dRes.in_question = question
        
        // OPTION CASE
        if let optID = optionID {
            let req: NSFetchRequest<Option> = Option.fetchRequest()
            req.predicate = NSPredicate(
                format: "option_id == %@",
                optID as CVarArg
            )
            
            if let option = try? viewContext.fetch(req).first {
                // HAS OPTION HARUS NSSet!
                dRes.has_option = NSSet(array: [option])
                dRes.dresponse_answer_text = option.option_text
            }
        }
        
        // TEXT CASE
        if let txt = text {
            dRes.dresponse_answer_text = txt
        }
    }
    
}
