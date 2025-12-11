//
//  HistoryModel.swift
//  PollPal
//
//  Created by student on 04/12/25.
//

import Foundation

struct HistoryItem: Identifiable {
    let id: UUID
    let owner: String
    let title: String
    let status: SurveyStatus
    let categories: [String]
    let submittedDate: Date? // BARU: Tanggal submit
    let points: Int          // BARU: Poin survey
    
    // Helper untuk format tanggal di View
    var formattedDate: String {
        guard let date = submittedDate else { return "-" }
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM yyyy, HH:mm" // Contoh: 12 Dec 2025, 14:30
        return formatter.string(from: date)
    }
}

enum SurveyStatus {
    case inProgress
    case finished
}
