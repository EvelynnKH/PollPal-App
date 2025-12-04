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
    
    // Ganti ini nanti dengan sistem Login asli (UserDefaults)
    let targetUserName = "Felicia Kathrin"
    
    init(context: NSManagedObjectContext) {
        self.viewContext = context
        fetchHistory()
    }
    
    func fetchHistory() {
        let userRequest: NSFetchRequest<User> = User.fetchRequest()
        
        // 1. JANGAN MENGANDALKAN URUTAN INSERT!
        // Gunakan Predicate untuk mencari spesifik user Felicia.
        userRequest.predicate = NSPredicate(format: "user_name == %@", targetUserName)
        userRequest.fetchLimit = 1
        
        do {
            let users = try viewContext.fetch(userRequest)
            
            // Debugging: Lihat siapa yang ketangkap
            if let currentUser = users.first {
                print("👤 HistoryViewModel: User ditemukan -> \(currentUser.user_name ?? "Nil")")
                
                // 2. Ambil HResponse
                if let responses = currentUser.filled_hresponse as? Set<HResponse> {
                    print("   Jumlah History: \(responses.count)")
                    
                    self.historyItems = responses.compactMap { hRes in
                        // Validasi Survey (Takutnya survey induk sudah dihapus)
                        guard let survey = hRes.in_survey else { return nil }
                        
                        let ownerName = survey.owned_by_user?.user_name ?? "Unknown"
                        let title = survey.survey_title ?? "No Title"
                        
                        var categoryNames: [String] = []
                        if let cats = survey.has_category as? Set<Category> {
                            categoryNames = cats.compactMap { $0.category_name }.sorted()
                        }
                        
                        let status: SurveyStatus = (hRes.submitted_at != nil) ? .finished : .inProgress
                        
                        return HistoryItem(
                            id: hRes.hresponse_id ?? UUID(),
                            owner: ownerName,
                            title: title,
                            status: status,
                            categories: categoryNames
                        )
                    }
                } else {
                    print("⚠️ User \(targetUserName) tidak punya history (filled_hresponse kosong).")
                }
            } else {
                print("❌ User '\(targetUserName)' TIDAK DITEMUKAN di Database.")
                // Ini berarti Seeder gagal jalan atau Data masih kotor
            }
            
        } catch {
            print("❌ Gagal fetch history: \(error.localizedDescription)")
        }
    }
}
