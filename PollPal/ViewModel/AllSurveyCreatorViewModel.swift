//
//  AllSurveyCreatorViewModel.swift
//  PollPal
//
//  Created by student on 08/12/25.
//

import Foundation
import SwiftUI
import CoreData

class AllSurveyCreatorViewModel: ObservableObject {

    @Published var surveys: [Survey] = []
    @Published var searchText: String = ""
    @Published var selectedFilter: FilterType = .all

    let context: NSManagedObjectContext
    let currentUser: User   // user yang login

    init(context: NSManagedObjectContext, currentUser: User) {
        self.context = context
        self.currentUser = currentUser
        fetchSurveys()
    }

    func fetchSurveys() {
        let request: NSFetchRequest<Survey> = Survey.fetchRequest()
        
        // Filter berdasarkan user yang login
        request.predicate = NSPredicate(
            format: "owned_by_user == %@", currentUser
        )

        // Sorting
        request.sortDescriptors = [
            NSSortDescriptor(key: "survey_created_at", ascending: false)
        ]

        do {
            surveys = try context.fetch(request)
        } catch {
            print("❌ Fetch survey error:", error)
        }
    }

    // Filter after fetch (UI filter)
    var filteredSurveys: [Survey] {
        var list = surveys
        
        // Search filter
        if !searchText.isEmpty {
            list = list.filter {
                $0.survey_title?.lowercased().contains(searchText.lowercased()) ?? false
            }
        }

        // Status filter
        switch selectedFilter {
        case .all: break
        case .published: list = list.filter { $0.survey_rewards_points > 0 }
        case .draft: list = list.filter { $0.survey_rewards_points == 0 }
        case .finished: list = list.filter { $0.survey_status_del == true }
        }

        return list
    }
}



