//
//  SurveyDetailViewModel.swift
//  PollPal
//
//  Created by student on 08/12/25.
//

import CoreData
import Foundation

class SurveyDetailViewModel: ObservableObject {
    let survey: Survey

    @Published var errorMessage: String = ""
    @Published var showError: Bool = false
    @Published var canNavigate: Bool = false

    init(survey: Survey) {
        self.survey = survey
    }

    // Computed properties untuk format tampilan
    var title: String { survey.survey_title ?? "Unknown Survey" }
    var description: String {
        survey.survey_description ?? "No description available."
    }
    var points: Int { Int(survey.survey_points) }

    // Menghitung jumlah pertanyaan dari relasi Core Data
    var questionCount: Int {
        survey.has_question?.count ?? 0
    }

    // Estimasi durasi (misal 1 menit per soal sebagai contoh sederhana)
    var durationString: String {
        let estimatedMinutes = questionCount * 1  // Asumsi 1 menit/soal
        return "\(estimatedMinutes) Mins"
    }

    var categoryNames: [String] {
        // Ambil relasi 'has_category'
        if let catSet = survey.has_category as? Set<Category> {
            return catSet.compactMap { $0.category_name }.sorted()
        }
        return []
    }

    var deadlineString: String {
        guard let date = survey.survey_deadline else { return "No Deadline" }
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM yyyy"  // Contoh: 12 Dec 2025
        return formatter.string(from: date)
    }

    var isExpired: Bool {
        guard let date = survey.survey_deadline else { return false }
        return date < Date()
    }

    var hasDeadline: Bool {
        return survey.survey_deadline != nil
    }

    // MARK: - VALIDASI START SURVEY (PENTING!)
    // Fungsi ini dipanggil saat tombol "Start Survey" ditekan
    func validateAndStart() {
        // 1. Cek Deadline lagi (Real-time)
        if isExpired {
            self.errorMessage = "Sorry, survey is no longer opened."
            self.showError = true
            return
        }

        // 2. Cek Kuota (Real-time Refresh)
        // Kita paksa Core Data refresh object ini untuk dapat data terbaru dari database
        survey.managedObjectContext?.refresh(survey, mergeChanges: true)

        let currentCount = survey.has_hresponse?.count ?? 0
        let target = Int(survey.survey_target_responden)

        if currentCount >= target {
            self.errorMessage = "Sorry, survey limits has been reached."
            self.showError = true
            return
        }

        // 3. Jika Lolos Semua, izinkan navigasi
        self.canNavigate = true
    }

}
