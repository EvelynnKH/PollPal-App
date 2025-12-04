//
//  ListSurveyViewModel.swift
//  PollPal
//
//  Created by student on 03/12/25.
//

import Foundation
import CoreData
import SwiftUI

class ListSurveyViewModel: ObservableObject {
    @Published var surveys: [AvailableSurvey] = []
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
        fetchSurveys()
    }
    
    func fetchSurveys() {
        let request: NSFetchRequest<Survey> = Survey.fetchRequest()
        
        // FILTERING:
        // Pastikan nama attribute sesuai persis dengan Core Data Editor
        // survey_status_del == false (Anggap 0 atau false)
        // is_public == true (Anggap 1 atau true)
        
        let predicateNotDeleted = NSPredicate(format: "survey_status_del == NO")
        let predicateIsPublic = NSPredicate(format: "is_public == YES")
        
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicateNotDeleted, predicateIsPublic])
        
        // SORTING: Tampilkan yang terbaru di atas
        request.sortDescriptors = [NSSortDescriptor(key: "survey_created_at", ascending: false)]
        
        do {
            let results = try context.fetch(request)
            // Transformasi Entity ke Struct View
            self.surveys = results.map { AvailableSurvey(entity: $0) }
        } catch {
            print("❌ Gagal fetch survey: \(error.localizedDescription)")
        }
    }
}
