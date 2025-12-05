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
    
    // 2. Ambil UUID User yang sedang login
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
        // 3. Cek apakah ada user login?
        guard let myID = currentUserUUID else {
            print("⚠️ HistoryViewModel: Tidak ada user login (Guest). History kosong.")
            self.historyItems = [] // Kosongkan list
            return
        }

        let userRequest: NSFetchRequest<User> = User.fetchRequest()
        
        // 4. Ubah Predicate: Cari berdasarkan user_id (UUID)
        userRequest.predicate = NSPredicate(format: "user_id == %@", myID as CVarArg)
        userRequest.fetchLimit = 1
        
        do {
            let users = try viewContext.fetch(userRequest)
            
            // Debugging: Lihat siapa yang ketangkap
            if let currentUser = users.first {
                print("👤 HistoryViewModel: User ditemukan -> \(currentUser.user_name ?? "Nil")")
                
                // 5. Ambil HResponse (History)
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
                        
                        // Tentukan Status: Jika ada tanggal submit, berarti selesai
                        let status: SurveyStatus = (hRes.submitted_at != nil) ? .finished : .inProgress
                        
                        return HistoryItem(
                            id: hRes.hresponse_id ?? UUID(),
                            owner: ownerName,
                            title: title,
                            status: status,
                            categories: categoryNames
                        )
                    }
                    
                    // Opsional: Urutkan history berdasarkan tanggal submit terbaru
                    // self.historyItems.sort { ... }
                    
                } else {
                    print("⚠️ User ini belum memiliki history.")
                    self.historyItems = []
                }
            } else {
                print("❌ User ID '\(myID)' tidak ditemukan di Database.")
                self.historyItems = []
            }
            
        } catch {
            print("❌ Gagal fetch history: \(error.localizedDescription)")
        }
    }
}
