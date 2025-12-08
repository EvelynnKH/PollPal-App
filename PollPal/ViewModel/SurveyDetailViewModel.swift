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
}
