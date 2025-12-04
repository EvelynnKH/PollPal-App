//
//  DashboardViewModel.swift
//  PollPal
//
//  Created by student on 04/12/25.
//

import Foundation
import CoreData
import SwiftUI

class DashboardViewModel: ObservableObject {
    // --- Published Properties (Data untuk UI) ---
    @Published var userName: String = "Guest"
    @Published var userPoints: Int = 0
    @Published var categories: [Category] = []
    @Published var popularSurveys: [Survey] = []
    
    // Tuple untuk ongoing: (Judul Survey, Progress 0.0 - 1.0)
    @Published var ongoingSurveys: [(String, Double)] = []
    
    // Search
    @Published var searchText: String = "" {
        didSet {
            filterSurveys()
        }
    }
    @Published var searchResults: [Survey] = [] // Hasil pencarian
    
    private var viewContext: NSManagedObjectContext
    // Hardcode target user (sesuaikan dengan login nanti)
    private let targetUserName = "Felicia Kathrin"
    
    init(context: NSManagedObjectContext) {
        self.viewContext = context
        fetchAllData()
    }
    
    func fetchAllData() {
        fetchUserData()
        fetchCategories()
        fetchPopularSurveys()
        fetchOngoingSurveys()
    }
    
    // MARK: - 1. Fetch User (Name & Points)
    private func fetchUserData() {
        let request: NSFetchRequest<User> = User.fetchRequest()
        request.predicate = NSPredicate(format: "user_name == %@", targetUserName)
        request.fetchLimit = 1
        
        do {
            let results = try viewContext.fetch(request)
            if let user = results.first {
                self.userName = user.user_name ?? "Guest"
                self.userPoints = Int(user.user_point)
            }
        } catch {
            print("❌ Error fetching user: \(error.localizedDescription)")
        }
    }
    
    // MARK: - 2. Fetch Categories
    private func fetchCategories() {
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        // Urutkan abjad
        request.sortDescriptors = [NSSortDescriptor(key: "category_name", ascending: true)]
        
        do {
            self.categories = try viewContext.fetch(request)
        } catch {
            print("❌ Error fetching categories: \(error.localizedDescription)")
        }
    }
    
    // MARK: - 3. Fetch Popular Surveys (Logic: Public & Active)
    private func fetchPopularSurveys() {
        let request: NSFetchRequest<Survey> = Survey.fetchRequest()
        let p1 = NSPredicate(format: "is_public == YES")
        let p2 = NSPredicate(format: "survey_status_del == NO")
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [p1, p2])
        request.fetchLimit = 5 // Ambil 5 saja
        
        do {
            self.popularSurveys = try viewContext.fetch(request)
        } catch {
            print("❌ Error fetching popular surveys: \(error.localizedDescription)")
        }
    }
    
    // MARK: - 4. Fetch Ongoing Surveys & Calculate Progress
    private func fetchOngoingSurveys() {
        // Logika: Cari HResponse milik user ini yang submitted_at == nil (belum finish)
        let request: NSFetchRequest<HResponse> = HResponse.fetchRequest()
        
        let pUser = NSPredicate(format: "is_filled_by_user.user_name == %@", targetUserName)
        let pNotSubmitted = NSPredicate(format: "submitted_at == NIL")
        
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [pUser, pNotSubmitted])
        
        do {
            let hResponses = try viewContext.fetch(request)
            
            var tempOngoing: [(String, Double)] = []
            
            for hRes in hResponses {
                guard let survey = hRes.in_survey else { continue }
                
                // Hitung Progress
                // A. Jumlah Pertanyaan di Survey
                let totalQuestions = survey.has_question?.count ?? 1 // Hindari div by zero
                
                // B. Jumlah Jawaban di HResponse ini
                let answeredCount = hRes.has_dresponse?.count ?? 0
                
                // C. Kalkulasi (Double)
                let progress = Double(answeredCount) / Double(max(totalQuestions, 1))
                
                tempOngoing.append((survey.survey_title ?? "Untitled", progress))
            }
            
            self.ongoingSurveys = tempOngoing
            
        } catch {
            print("❌ Error fetching ongoing: \(error.localizedDescription)")
        }
    }
    
    // MARK: - 5. Search Logic
    private func filterSurveys() {
        if searchText.isEmpty {
            searchResults = []
            return
        }
        
        let request: NSFetchRequest<Survey> = Survey.fetchRequest()
        let p1 = NSPredicate(format: "is_public == YES")
        let p2 = NSPredicate(format: "survey_status_del == NO")
        let pSearch = NSPredicate(format: "survey_title CONTAINS[cd] %@", searchText)
        
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [p1, p2, pSearch])
        
        do {
            self.searchResults = try viewContext.fetch(request)
        } catch {
            print("❌ Error searching: \(error.localizedDescription)")
        }
    }
}
