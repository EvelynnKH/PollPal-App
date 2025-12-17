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
        fetchPopularSurveys()
        debugAllSurveysAndCompare() // Logic filter baru diterapkan disini
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
        print("\n🔍 --- START FETCH POPULAR SURVEYS (FIXED) ---")
        
        // 1. Ambil User Login
        guard let userIdStr = UserDefaults.standard.string(forKey: "logged_in_user_id"),
              let userId = UUID(uuidString: userIdStr) else { return }
        
        let userReq: NSFetchRequest<User> = User.fetchRequest()
        userReq.predicate = NSPredicate(format: "user_id == %@", userId as CVarArg)
        userReq.fetchLimit = 1
        
        do {
            guard let currentUser = try viewContext.fetch(userReq).first else { return }

            // 2. Siapkan Request
            let request: NSFetchRequest<Survey> = Survey.fetchRequest()
            var predicates = getBasePredicates() // Mengambil filter dasar
            
            // --- A. DEADLINE ---
            let deadlinePred = NSPredicate(format: "survey_deadline == nil OR survey_deadline >= %@", Date() as NSDate)
            predicates.append(deadlinePred)
            
            // --- B. QUOTA ---
            predicates.append(NSPredicate(format: "has_hresponse.@count < survey_target_responden"))
            
            // --- C. GENDER ---
            if let userGender = currentUser.user_gender {
                // Gunakan ==[cd] (Aman)
                let genderPred = NSPredicate(format: "survey_gender ==[cd] %@ OR survey_gender ==[cd] 'All'", userGender)
                predicates.append(genderPred)
            }
            
            // --- D. RESIDENCE (DIKEMBALIKAN KE VERSI AMAN) ---
            if let userRes = currentUser.user_residence, !userRes.isEmpty {
                // Kita gunakan pencocokan persis (==) agar TIDAK CRASH.
                // Logika: Lokasi Survey == Lokasi User, ATAU 'All', ATAU Kosong/Nil
                let resPred = NSPredicate(format: "survey_residence ==[cd] %@ OR survey_residence ==[cd] 'All' OR survey_residence == '' OR survey_residence == nil", userRes)
                predicates.append(resPred)
            } else {
                // User tidak punya lokasi -> Hanya boleh lihat 'All' atau Kosong
                let noResPred = NSPredicate(format: "survey_residence ==[cd] 'All' OR survey_residence == '' OR survey_residence == nil")
                predicates.append(noResPred)
            }
            
            // --- E. USIA ---
            if let birthDate = currentUser.user_birthdate {
                let userAge = Calendar.current.dateComponents([.year], from: birthDate, to: Date()).year ?? 0
                print(userAge)
                predicates.append(NSPredicate(format: "survey_usia_min <= %d", userAge))
                predicates.append(NSPredicate(format: "survey_usia_max >= %d", userAge))
            }
            
            // Eksekusi
            let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
            request.predicate = compoundPredicate
            request.fetchLimit = 10
            request.sortDescriptors = [
                NSSortDescriptor(key: "survey_rewards_points", ascending: false),
                NSSortDescriptor(key: "survey_created_at", ascending: false)
            ]
            
            self.popularSurveys = try viewContext.fetch(request)
            print("✅ Found \(self.popularSurveys.count) matching surveys.")
            
        } catch {
            print("❌ Error fetching surveys: \(error.localizedDescription)")
        }
    }
    
    func debugAllSurveysAndCompare() {
        print("\n🕵️‍♂️ --- START DEBUGGING ALL SURVEYS (NO FILTER) ---")
        
        // 1. Ambil User Login
        guard let userIdStr = UserDefaults.standard.string(forKey: "logged_in_user_id"),
              let userId = UUID(uuidString: userIdStr) else {
            print("⚠️ No User Login")
            return
        }
        
        // Fetch User
        let userReq: NSFetchRequest<User> = User.fetchRequest()
        userReq.predicate = NSPredicate(format: "user_id == %@", userId as CVarArg)
        
        do {
            guard let user = try viewContext.fetch(userReq).first else { return }
            
            // Data User untuk Perbandingan
            let userGender = user.user_gender ?? "nil"
            let userRes = user.user_residence ?? "nil"
            let birthDate = user.user_birthdate
            let userAge = birthDate != nil ? Calendar.current.dateComponents([.year], from: birthDate!, to: Date()).year ?? 0 : -1
            
            print("👤 USER: \(user.user_name ?? "-") | Age: \(userAge) | Gender: \(userGender) | Res: \(userRes)\n")
            
            // 2. Fetch SEMUA Survey (Tanpa Filter Demografi)
            let request: NSFetchRequest<Survey> = Survey.fetchRequest()
            // Hanya filter dasar (biar yang dihapus gak muncul)
            request.predicate = NSPredicate(format: "survey_status_del == NO AND is_public == YES")
            request.sortDescriptors = [NSSortDescriptor(key: "survey_created_at", ascending: false)]
            
            let allSurveys = try viewContext.fetch(request)
            print("📚 Found \(allSurveys.count) Total Public Surveys. Checking constraints...\n")
            
            // 3. Loop dan Analisis Syaratnya
            for (index, survey) in allSurveys.enumerated() {
                print("📝 [\(index + 1)] TITLE: \"\(survey.survey_title ?? "No Title")\"")
                
                var isMatch = true
                
                // --- CEK 1: DEADLINE ---
                let deadline = survey.survey_deadline
                if let d = deadline, d < Date() {
                    print("   ❌ DEADLINE: Expired (\(d.description))")
                    isMatch = false
                } else {
                    print("   ✅ DEADLINE: Active")
                }
                
                // --- CEK 2: QUOTA ---
                let current = survey.has_hresponse?.count ?? 0
                let target = Int(survey.survey_target_responden)
                if current >= target {
                    print("   ❌ QUOTA: Full (\(current)/\(target))")
                    isMatch = false
                } else {
                    print("   ✅ QUOTA: Open (\(current)/\(target))")
                }
                
                // --- CEK 3: GENDER ---
                let sGender = survey.survey_gender ?? "All"
                // Case insensitive check
                if sGender.caseInsensitiveCompare("All") == .orderedSame {
                     print("   ✅ GENDER: Universal (All)")
                } else if sGender.caseInsensitiveCompare(userGender) == .orderedSame {
                     print("   ✅ GENDER: Match (\(sGender))")
                } else {
                     print("   ❌ GENDER: Mismatch (Target: \(sGender) vs User: \(userGender))")
                     isMatch = false
                }
                
                // --- CEK 4: RESIDENCE ---
                let sRes = survey.survey_residence ?? "All"
                if sRes.caseInsensitiveCompare("All") == .orderedSame {
                    print("   ✅ LOCATION: Universal (All)")
                } else if userRes.localizedCaseInsensitiveContains(sRes) {
                    // User: Citraland Surabaya, Target: Surabaya -> MATCH
                    print("   ✅ LOCATION: Match (Target: \(sRes) in User: \(userRes))")
                } else {
                    print("   ❌ LOCATION: Mismatch (Target: \(sRes) vs User: \(userRes))")
                    isMatch = false
                }
                
                // --- CEK 5: AGE ---
                let minAge = Int(survey.survey_usia_min)
                let maxAge = Int(survey.survey_usia_max)
                if userAge >= minAge && userAge <= maxAge {
                    print("   ✅ AGE: Match (Range: \(minAge)-\(maxAge), User: \(userAge))")
                } else {
                    print("   ❌ AGE: Mismatch (Range: \(minAge)-\(maxAge) vs User: \(userAge))")
                    isMatch = false
                }
                
                let img = survey.survey_img_url
                print("   ✅ Img: \(img)")
                
                // KESIMPULAN
                if isMatch {
                    print("   🎉 RESULT: AKAN MUNCUL DI LIST")
                } else {
                    print("   ⛔ RESULT: HIDDEN / TIDAK MUNCUL")
                }
                print("--------------------------------------------------")
            }
            
        } catch {
            print("Error: \(error.localizedDescription)")
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
