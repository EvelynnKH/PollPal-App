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
    
    // Tambahkan properti ini untuk menampung filter
    var filterCategory: String?
    var initialSearchText: String?

    private let context: NSManagedObjectContext
    
    // Update init untuk menerima parameter opsional
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
            // "Carikan survey yang punya kategori bernama X"
            // Asumsi relationship di Survey bernama 'has_category'
            let categoryPredicate = NSPredicate(format: "SUBQUERY(has_category, $cat, $cat.category_name == %@).@count > 0", catName)
            predicates.append(categoryPredicate)
        }
        
        // 3. Filter Search (Jika ada)
        if let search = initialSearchText, !search.isEmpty {
            let searchPredicate = NSPredicate(format: "survey_title CONTAINS[cd] %@", search)
            predicates.append(searchPredicate)
        }
        
        // TODO: Jangan lupa tambahkan filter 'NotFilledByUser' yang kita bahas sebelumnya disini juga
        
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        request.sortDescriptors = [NSSortDescriptor(key: "survey_created_at", ascending: false)]
        
        do {
            let results = try context.fetch(request)
            self.surveys = results.map { AvailableSurvey(entity: $0) }
        } catch {
            print("❌ Error: \(error.localizedDescription)")
        }
    }
}

