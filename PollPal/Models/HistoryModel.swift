//
//  HistoryModel.swift
//  PollPal
//
//  Created by student on 04/12/25.
//

import Foundation

enum SurveyStatus {
    case inProgress
    case finished
}

struct HistoryItem: Identifiable {
    let id: UUID
    let owner: String
    let title: String
    let status: SurveyStatus
    let categories: [String]
}
