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
    
    // Ambil ID User yang login
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
        // Cek user login
        if currentUserUUID != nil {
            fetchUserData()
            fetchOngoingSurveys()
        } else {
            print("⚠️ Tidak ada user login (Guest Mode)")
            self.userName = "Guest"
            self.userPoints = 0
        }
        
        fetchCategories()
        fetchPopularSurveys() // Logic filter baru diterapkan disini
    }
    
    // MARK: - HELPER: Base Predicates
    // Fungsi ini membuat filter dasar agar tidak perlu tulis ulang di Search & Popular
    private func getBasePredicates() -> [NSPredicate] {
        // 1. Syarat Wajib: Public & Tidak Dihapus
        var predicates: [NSPredicate] = [
            NSPredicate(format: "is_public == YES"),
            NSPredicate(format: "survey_status_del == NO")
        ]
        
        // 2. Syarat User (Jika Login)
        if let myID = currentUserUUID {
            
            // A. Jangan tampilkan survei milik sendiri (Creator tidak isi survei sendiri)
            let notMinePredicate = NSPredicate(format: "owned_by_user.user_id != %@", myID as CVarArg)
            predicates.append(notMinePredicate)
            
            // B. Jangan tampilkan survei yang SUDAH diisi (History)
            // Logic: Cari Survey dimana jumlah HResponse dari user ini adalah 0
            // has_hresponse     = Relasi di Survey ke HResponse
            // is_filled_by_user = Relasi di HResponse ke User
            let notFilledPredicate = NSPredicate(
                format: "SUBQUERY(has_hresponse, $resp, $resp.is_filled_by_user.user_id == %@).@count == 0",
                myID as CVarArg
            )
            predicates.append(notFilledPredicate)
        }
        
        return predicates
    }
    
    // MARK: - 1. Fetch User
    private func fetchUserData() {
        guard let myID = currentUserUUID else { return }

        let request: NSFetchRequest<User> = User.fetchRequest()
        request.predicate = NSPredicate(format: "user_id == %@", myID as CVarArg)
        request.fetchLimit = 1
        
        do {
            let results = try viewContext.fetch(request)
            if let user = results.first {
                self.userName = user.user_name ?? "Unknown"
                self.userPoints = Int(user.user_point)
            }
        } catch {
            print("❌ Error fetching user: \(error.localizedDescription)")
        }
    }
    
    // MARK: - 2. Fetch Categories
    private func fetchCategories() {
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "category_name", ascending: true)]
        
        do {
            self.categories = try viewContext.fetch(request)
        } catch {
            print("❌ Error fetching categories: \(error.localizedDescription)")
        }
    }
    
    // MARK: - 3. Fetch Popular Surveys (Updated Filter)
    private func fetchPopularSurveys() {
        let request: NSFetchRequest<Survey> = Survey.fetchRequest()
        
        // Ambil filter dasar (Public + Active + Not Mine + Not Filled)
        let predicates = getBasePredicates()
        
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        request.fetchLimit = 5
        
        // Opsional: Sortir berdasarkan reward terbesar atau tanggal terbaru
        request.sortDescriptors = [NSSortDescriptor(key: "survey_created_at", ascending: false)]
        
        do {
            self.popularSurveys = try viewContext.fetch(request)
        } catch {
            print("❌ Error fetching popular surveys: \(error.localizedDescription)")
        }
    }
    
    // MARK: - 4. Fetch Ongoing Surveys
    private func fetchOngoingSurveys() {
        guard let myID = currentUserUUID else { return }

        let request: NSFetchRequest<HResponse> = HResponse.fetchRequest()
        
        let pUser = NSPredicate(format: "is_filled_by_user.user_id == %@", myID as CVarArg)
        let pNotSubmitted = NSPredicate(format: "submitted_at == NIL")
        
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [pUser, pNotSubmitted])
        
        do {
            let hResponses = try viewContext.fetch(request)
            var tempOngoing: [(String, Double)] = []
            
            for hRes in hResponses {
                guard let survey = hRes.in_survey else { continue }
                
                // Pastikan nama relasi 'has_question' benar (sesuai DataSeeder Anda sebelumnya: has_question)
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
    
    // MARK: - 5. Search Logic (Updated Filter)
    private func filterSurveys() {
        if searchText.isEmpty {
            searchResults = []
            return
        }
        
        let request: NSFetchRequest<Survey> = Survey.fetchRequest()
        
        // Ambil filter dasar (Public + Active + Not Mine + Not Filled)
        var predicates = getBasePredicates()
        
        // Tambahkan filter kata kunci pencarian
        let pSearch = NSPredicate(format: "survey_title CONTAINS[cd] %@", searchText)
        predicates.append(pSearch)
        
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        
        do {
            self.searchResults = try viewContext.fetch(request)
        } catch {
            print("❌ Error searching: \(error.localizedDescription)")
        }
    }
}
