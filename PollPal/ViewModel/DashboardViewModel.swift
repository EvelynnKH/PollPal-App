//
//  DashboardViewModel.swift
//  PollPal
//
//  Created by student on 01/12/25.
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
    @Published var ongoingSurveys: [(String, Double)] = []
    
    // Search
    @Published var searchText: String = "" {
        didSet {
            filterSurveys()
        }
    }
    @Published var searchResults: [Survey] = []
    
    private var viewContext: NSManagedObjectContext
    
    // --- PERUBAHAN UTAMA DISINI ---
    // 1. Hapus variable hardcode 'targetUserName'
    // 2. Buat Computed Property untuk mengambil ID dari UserDefaults
    private var currentUserUUID: UUID? {
        if let idString = UserDefaults.standard.string(forKey: "logged_in_user_id") {
            return UUID(uuidString: idString)
        }
        return nil
    }
    
    init(context: NSManagedObjectContext) {
        self.viewContext = context
        fetchAllData()
    }
    
    func fetchAllData() {
        // Cek dulu apakah ada user login?
        if currentUserUUID != nil {
            fetchUserData()
            fetchOngoingSurveys() // Hanya fetch ongoing jika ada user
        } else {
            print("⚠️ Tidak ada user login (Guest Mode)")
            self.userName = "Guest"
            self.userPoints = 0
        }
        
        // Data umum (tetap diambil meski Guest)
        fetchCategories()
        fetchPopularSurveys()
    }
    
    // MARK: - 1. Fetch User (By UUID)
    private func fetchUserData() {
        guard let myID = currentUserUUID else { return }

        let request: NSFetchRequest<User> = User.fetchRequest()
        
        // GANTI PREDICATE: Cari berdasarkan user_id (UUID), bukan user_name
        request.predicate = NSPredicate(format: "user_id == %@", myID as CVarArg)
        request.fetchLimit = 1
        
        do {
            let results = try viewContext.fetch(request)
            if let user = results.first {
                self.userName = user.user_name ?? "Unknown"
                self.userPoints = Int(user.user_point)
                print("✅ Dashboard loaded for: \(self.userName)")
            }
        } catch {
            print("❌ Error fetching user: \(error.localizedDescription)")
        }
    }
    
    // MARK: - 2. Fetch Categories (Tetap Sama)
    private func fetchCategories() {
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "category_name", ascending: true)]
        
        do {
            self.categories = try viewContext.fetch(request)
        } catch {
            print("❌ Error fetching categories: \(error.localizedDescription)")
        }
    }
    
    // MARK: - 3. Fetch Popular Surveys (Tetap Sama)
    private func fetchPopularSurveys() {
        let request: NSFetchRequest<Survey> = Survey.fetchRequest()
        let p1 = NSPredicate(format: "is_public == YES")
        let p2 = NSPredicate(format: "survey_status_del == NO")
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [p1, p2])
        request.fetchLimit = 5
        
        do {
            self.popularSurveys = try viewContext.fetch(request)
        } catch {
            print("❌ Error fetching popular surveys: \(error.localizedDescription)")
        }
    }
    
    // MARK: - 4. Fetch Ongoing Surveys (By UUID)
    private func fetchOngoingSurveys() {
        guard let myID = currentUserUUID else { return }

        let request: NSFetchRequest<HResponse> = HResponse.fetchRequest()
        
        // GANTI PREDICATE: Filter berdasarkan user_id (UUID)
        // Masuk ke relationship 'is_filled_by_user' -> property 'user_id'
        let pUser = NSPredicate(format: "is_filled_by_user.user_id == %@", myID as CVarArg)
        let pNotSubmitted = NSPredicate(format: "submitted_at == NIL")
        
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [pUser, pNotSubmitted])
        
        do {
            let hResponses = try viewContext.fetch(request)
            var tempOngoing: [(String, Double)] = []
            
            for hRes in hResponses {
                guard let survey = hRes.in_survey else { continue }
                
                // Hitung Progress (Pastikan Relationship has_dresponse Type: To Many)
                let questions = survey.has_question as? Set<Question> ?? []
                let totalQuestions = max(questions.count, 1)
                
                let answeredList = hRes.has_dresponse as? Set<NSManagedObject> ?? []
                let answeredCount = answeredList.count
                
                let progress = Double(answeredCount) / Double(totalQuestions)
                
                tempOngoing.append((survey.survey_title ?? "Untitled", progress))
            }
            self.ongoingSurveys = tempOngoing
            
        } catch {
            print("❌ Error fetching ongoing: \(error.localizedDescription)")
        }
    }
    
    // MARK: - 5. Search Logic (Tetap Sama)
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
