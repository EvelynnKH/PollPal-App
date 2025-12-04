////
////  SurveyViewModel.swift
////  PollPal
////
////  Created by student on 27/11/25.
////
//
//import Foundation
//
//import SwiftUI
//
//class SurveyViewModel: ObservableObject {
//    @Published var questions: [Question] = []
//
//    func addQuestion(type: QuestionType) {
//        var newQ = Question(title: "Pertanyaan Baru", type: type)
//
//        switch type {
//        case .multipleChoice, .checkboxes, .dropdown:
//            newQ.options = ["Option 1", "Option 2"]
//        case .linearScale:
//            newQ.scaleRange = 1...5
//        default: break
//        }
//
//        questions.append(newQ)
//    }
//}
