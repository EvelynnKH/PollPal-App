//
//  QuestionType.swift
//  PollPal
//
//  Created by Shienny Megawati Sutanto on 05/12/25.
//

import Foundation

enum QuestionType: String, CaseIterable, Identifiable {
    case shortAnswer
    case paragraph
    case multipleChoice
    case checkboxes
    case dropdown

    var id: String { self.rawValue }
}
