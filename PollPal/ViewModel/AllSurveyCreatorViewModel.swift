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
    @Published var totalResponses: Int = 0

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
        case .all:
            break
        case .published:
            print("📌 AllSurvey user:", currentUser.user_id!.uuidString)

            list = list.filter { $0.is_public == true && $0.survey_status_del == false }
        case .draft:
            list = list.filter { $0.is_public == false && $0.survey_status_del == false }
        case .finished:
            list = list.filter { $0.survey_status_del == true}
        }
        return list
    }
    
//    private func fetchTotalResponses(for user: User) {
//        let req: NSFetchRequest<HResponse> = HResponse.fetchRequest()
//        req.predicate = NSPredicate(
//            format: "is_filled_by_user.objectID == %@", user.objectID
//        )
//
//        let results = (try? context.fetch(req)) ?? []
//        self.totalResponses = results.count
//    }
    
    func getResponseCount(for survey: Survey) -> Int {
            // Mengambil jumlah data dari relationship 'has_hresponse'
            // has_hresponse adalah kumpulan (Set) HResponse yang mengisi survei ini
            let count = survey.has_hresponse?.count ?? 0
            return count
        }


}



