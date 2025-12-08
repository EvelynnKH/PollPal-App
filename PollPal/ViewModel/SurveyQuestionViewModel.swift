//
//  SurveyQuestionViewModel.swift
//  PollPal
//
//  Created by student on 08/12/25.
//

import Foundation
import CoreData
import SwiftUI

class SurveyQuestionViewModel: ObservableObject {
    private var viewContext: NSManagedObjectContext
    let survey: Survey
    
    // Data Pertanyaan
    @Published var questions: [Question] = []
    @Published var currentIndex: Int = 0
    
    // Penyimpanan Jawaban Sementara
    // Dictionary: [QuestionID : OptionID] (Untuk Multiple Choice)
    @Published var selectedOptions: [UUID: UUID] = [:]
    
    // Dictionary: [QuestionID : String] (Untuk Essay/Long Answer)
    @Published var textAnswers: [UUID: String] = [:]
    
    @Published var showSuccessScreen = false
    
    // Ambil User ID dari Session
    private var currentUserUUID: UUID? {
        if let idString = UserDefaults.standard.string(forKey: "logged_in_user_id") {
            return UUID(uuidString: idString)
        }
        return nil
    }
    
    init(context: NSManagedObjectContext, survey: Survey) {
        self.viewContext = context
        self.survey = survey
        loadQuestions()
    }
    
    // MARK: - LOAD DATA
    private func loadQuestions() {
        // Ambil dari relationship 'has_question' (Assuming it's a Set)
        if let questionSet = survey.has_question as? Set<Question> {
            // Sort agar urutan konsisten (misal by text atau ID karena belum ada field index)
            self.questions = questionSet.sorted { ($0.question_text ?? "") < ($1.question_text ?? "") }
        }
    }
    
    // MARK: - COMPUTED PROPERTIES
    var currentQuestion: Question? {
        guard questions.indices.contains(currentIndex) else { return nil }
        return questions[currentIndex]
    }
    
    var progressString: String {
        "\(currentIndex + 1)/\(questions.count)"
    }
    
    var progressFraction: Double {
        guard !questions.isEmpty else { return 0 }
        return Double(currentIndex + 1) / Double(questions.count)
    }
    
    var isLastQuestion: Bool {
        currentIndex == questions.count - 1
    }
    
    // Cek apakah pertanyaan saat ini sudah dijawab?
    var canGoNext: Bool {
        guard let q = currentQuestion, let qID = q.question_id else { return false }
        
        if q.question_type == "Multiple Choice" {
            return selectedOptions[qID] != nil
        } else {
            // Untuk Essay/Short Answer, pastikan teks tidak kosong
            let answer = textAnswers[qID] ?? ""
            return !answer.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
    }
    
    // MARK: - ACTIONS
    
    // Simpan pilihan ganda
    func selectOption(questionId: UUID, optionId: UUID) {
        selectedOptions[questionId] = optionId
    }
    
    // Simpan teks esai (Binding)
    func bindingForText(questionId: UUID) -> Binding<String> {
        return Binding(
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
        if currentIndex > 0 {
            currentIndex -= 1
        }
    }
    
    // MARK: - SUBMIT LOGIC (SESUAI DATAMODEL)
    private func submitSurvey() {
        guard let userId = currentUserUUID else { return }
        
        viewContext.performAndWait {
            // 1. Fetch User (Owner)
            let userReq: NSFetchRequest<User> = User.fetchRequest()
            userReq.predicate = NSPredicate(format: "user_id == %@", userId as CVarArg)
            
            guard let user = try? viewContext.fetch(userReq).first else { return }
            
            // 2. Buat HRESPONSE (Header)
            let hRes = HResponse(context: viewContext)
            hRes.hresponse_id = UUID()
            hRes.submitted_at = Date()
            
            // Relasi HResponse
            hRes.in_survey = survey // Link ke Survey
            hRes.is_filled_by_user = user // Link ke User
            
            // 3. Buat DRESPONSE (Detail) untuk setiap pertanyaan
            for question in questions {
                guard let qID = question.question_id else { continue }
                
                let dRes = DResponse(context: viewContext)
                dRes.dresponse_id = UUID()
                dRes.dresponse_status_del = false
                
                // Link Relasi Wajib
                // Note: Asumsi nama inverse di DResponse ke HResponse adalah 'in_hresponse'
                // (Anda tidak menulis inverse DResponse di prompt, tapi biasanya 'in_hresponse')
                // Jika error, cek nama relationship di CoreData Editor pada entity DResponse.
                dRes.setValue(hRes, forKey: "in_hresponse")
                
                // Link ke Question
                dRes.in_question = question
                
                // Isi Jawaban Sesuai Tipe
                if question.question_type == "Multiple Choice" {
                    // Ambil Option ID yg dipilih
                    if let selectedOptID = selectedOptions[qID] {
                        // Kita harus fetch object Option aslinya untuk relasi
                        let optReq: NSFetchRequest<Option> = Option.fetchRequest()
                        optReq.predicate = NSPredicate(format: "option_id == %@", selectedOptID as CVarArg)
                        if let selectedOptionEntity = try? viewContext.fetch(optReq).first {
                            // Relasi DResponse ke Option
                            // Asumsi nama relationship di DResponse adalah 'has_option'
                            // (karena di Option ada 'in_dresponse')
                            dRes.setValue(selectedOptionEntity, forKey: "has_option")
                            
                            // Simpan teks juga sebagai backup/sejarah
                            dRes.dresponse_answer_text = selectedOptionEntity.option_text
                        }
                    }
                } else {
                    // Isi Text
                    let text = textAnswers[qID] ?? ""
                    dRes.dresponse_answer_text = text
                }
            }
            
            // 4. Update Point User
            user.user_point += survey.survey_points
            
            // 5. Simpan Transaksi (Opsional jika ada entity Transaction)
            // ...
            
            // 6. Save Context
            do {
                try viewContext.save()
                print("✅ Survey Submitted! +\(survey.survey_points) points")
                
                DispatchQueue.main.async {
                    self.showSuccessScreen = true
                }
            } catch {
                print("❌ Failed to submit: \(error)")
            }
        }
    }
}
