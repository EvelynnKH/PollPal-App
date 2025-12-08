//
//  ListSurveyViewModel.swift
//  PollPal
//
//  Created by student on 03/12/25.
//

import CoreData
import Foundation
import SwiftUI

class ListSurveyViewModel: ObservableObject {
    @Published var surveys: [AvailableSurvey] = []
    
    // Properties Filter
    var filterCategory: String?
    var initialSearchText: String?

    private let context: NSManagedObjectContext
    
    // 1. TAMBAHAN: Ambil ID User yang sedang login
    private var currentUserUUID: UUID? {
        if let idString = UserDefaults.standard.string(forKey: "logged_in_user_id") {
            return UUID(uuidString: idString)
        }
        return nil
    }
    
    // Init (Tidak berubah)
    init(context: NSManagedObjectContext, category: String? = nil, searchText: String? = nil) {
        self.context = context
        self.filterCategory = category
        self.initialSearchText = searchText
        
        fetchSurveys()
    }
    
    func fetchSurveys() {
        let request: NSFetchRequest<Survey> = Survey.fetchRequest()
        
        // 1. Predicate Dasar (Aktif & Public)
        var predicates: [NSPredicate] = [
            NSPredicate(format: "survey_status_del == NO"),
            NSPredicate(format: "is_public == YES")
        ]
        
        // 2. Filter Kategori (Jika ada)
        if let catName = filterCategory {
            let categoryPredicate = NSPredicate(format: "SUBQUERY(has_category, $cat, $cat.category_name == %@).@count > 0", catName)
            predicates.append(categoryPredicate)
        }
        
        // 3. Filter Search (Jika ada)
        if let search = initialSearchText, !search.isEmpty {
            let searchPredicate = NSPredicate(format: "survey_title CONTAINS[cd] %@", search)
            predicates.append(searchPredicate)
        }
        
        // 4. LOGIK PENGECUALIAN (Untuk User Login)
        if let myID = currentUserUUID {
            
            // A. Jangan tampilkan survei milik sendiri (Creator tidak isi survei sendiri)
            let notMinePredicate = NSPredicate(format: "owned_by_user.user_id != %@", myID as CVarArg)
            predicates.append(notMinePredicate)
            
            // B. Jangan tampilkan survei yang SUDAH diisi (History)
            // Logic: Cari Survey dimana jumlah HResponse dari user ini adalah 0
            let notFilledPredicate = NSPredicate(
                format: "SUBQUERY(has_hresponse, $resp, $resp.is_filled_by_user.user_id == %@).@count == 0",
                myID as CVarArg
            )
            predicates.append(notFilledPredicate)
        }
        
        // Gabungkan semua filter
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        
        // Sorting: Terbaru di atas
        request.sortDescriptors = [NSSortDescriptor(key: "survey_created_at", ascending: false)]
        
        do {
            let results = try context.fetch(request)
            // Transformasi Entity ke Struct View
            self.surveys = results.map { AvailableSurvey(entity: $0) }
            
            // Debugging (Opsional)
            print("🔍 List Survey Loaded: \(results.count) items found.")
            
        } catch {
            print("❌ Error fetching list surveys: \(error.localizedDescription)")
        }
    }
}
