//
//  HistoryViewModel.swift
//  PollPal
//
//  Created by student on 04/12/25.
//

import Foundation
import CoreData
import SwiftUI
class HistoryViewModel: ObservableObject {
    @Published var historyItems: [HistoryItem] = []
    
    private var viewContext: NSManagedObjectContext
    
    private var currentUserUUID: UUID? {
        if let idString = UserDefaults.standard.string(forKey: "logged_in_user_id") {
            return UUID(uuidString: idString)
        }
        return nil
    }
    
    init(context: NSManagedObjectContext) {
        self.viewContext = context
        fetchHistory()
    }
    
    func fetchHistory() {
        guard let myID = currentUserUUID else {
            self.historyItems = []
            return
        }

        let userRequest: NSFetchRequest<User> = User.fetchRequest()
        userRequest.predicate = NSPredicate(format: "user_id == %@", myID as CVarArg)
        userRequest.fetchLimit = 1
        
        do {
            let users = try viewContext.fetch(userRequest)
            
            if let currentUser = users.first {
                
                if let responses = currentUser.filled_hresponse as? Set<HResponse> {
                    
                    // Ambil data dan urutkan dari yang paling baru (submitted_at desc)
                    let sortedResponses = responses.sorted {
                        ($0.submitted_at ?? Date.distantPast) > ($1.submitted_at ?? Date.distantPast)
                    }
                    
                    self.historyItems = sortedResponses.compactMap { hRes in
                        guard let survey = hRes.in_survey else { return nil }
                        
                        let ownerName = survey.owned_by_user?.user_name ?? "Unknown"
                        let title = survey.survey_title ?? "No Title"
                        
                        var categoryNames: [String] = []
                        if let cats = survey.has_category as? Set<Category> {
                            categoryNames = cats.compactMap { $0.category_name }.sorted()
                        }
                        
                        let status: SurveyStatus = (hRes.submitted_at != nil) ? .finished : .inProgress
                        
                        // BARU: Ambil Poin Reward
                        let rewardPoints = Int(survey.survey_rewards_points)
                        
                        return HistoryItem(
                            id: hRes.hresponse_id ?? UUID(),
                            owner: ownerName,
                            title: title,
                            status: status,
                            categories: categoryNames,
                            submittedDate: hRes.submitted_at, // BARU: Masukkan tanggal
                            points: rewardPoints              // BARU: Masukkan poin
                        )
                    }
                } else {
                    self.historyItems = []
                }
            } else {
                self.historyItems = []
            }
            
        } catch {
            print("❌ Gagal fetch history: \(error.localizedDescription)")
        }
    }
}
