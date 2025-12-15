//
//  DashboardCreatorViewModel.swift
//  PollPal
//
//  Created by student on 04/12/25.
//

import CoreData
import Foundation

class DashboardCreatorViewModel: ObservableObject {
    
    @Published var user: User?
    @Published var points: Int = 0
    @Published var activeSurveys: [Survey] = []
    @Published var draftSurveys: [Survey] = []
    @Published var finishedSurveys: [Survey] = []
    @Published var totalResponses: Int = 0
    @Published var allSurveys: Int = 0
    private var context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
        loadData()
    }
    
    func debugAllSurveys() {
        guard let user = self.user else { return }
        
        let req: NSFetchRequest<Survey> = Survey.fetchRequest()
        req.predicate = NSPredicate(format: "owned_by_user == %@", user)
        
        do {
            let results = try context.fetch(req)
            
            print("\n===== DEBUG ALL SURVEYS =====")
            for s in results {
                print("Title:", s.survey_title ?? "(no title)")
                print("Deleted:", s.survey_status_del)
                print("-------------------------")
            }
        } catch {
            print("❌ error:", error)
        }
    }
    
    func refetchData() {
        // 1. Fetch data user (ini juga akan mengupdate 'points' terbaru)
        fetchUser()
        
        // Pastikan user ada sebelum melanjutkan fetch survei
        guard let user = self.user else { return }
        
        // 2. Fetch data survei
        fetchActiveSurveys(for: user)
        fetchDraftSurveys(for: user)
        fetchFinishedSurveys(for: user)
        
        // 3. Hitung ulang semua metrik
        calculateTotalResponsesForAllSurveys()
        calculateTotalSurveyCount()
        
        // Memastikan ObservableObject memberitahu View tentang perubahan data.
        objectWillChange.send()
    }
    
    func responseCount(for survey: Survey) -> Int {
        let req: NSFetchRequest<HResponse> = HResponse.fetchRequest()
        req.predicate = NSPredicate(format: "in_survey == %@", survey)
        
        if let results = try? context.fetch(req) {
            let uniqueUsers = Set(results.compactMap { $0.is_filled_by_user })
            return uniqueUsers.count
        }
        return 0
    }
    
    func loadData() {
        fetchUser()
        
        guard let user = self.user else { return }
        
        fetchActiveSurveys(for: user)
        fetchDraftSurveys(for: user)
        calculateTotalResponsesForAllSurveys()
        calculateTotalSurveyCount()
        fetchFinishedSurveys(for: user)  // Fungsi baru
    }
    
    private func fetchUser() {
        guard
            let uuidString = UserDefaults.standard.string(
                forKey: "logged_in_user_id"
            ),
            let uuid = UUID(uuidString: uuidString)
        else {
            print("❌ No logged_in_user_id in UserDefaults")
            self.user = nil
            self.points = 0 // Reset points jika user tidak ada
            return
        }
        
        let req: NSFetchRequest<User> = User.fetchRequest()
        req.predicate = NSPredicate(format: "user_id == %@", uuid as CVarArg)
        req.fetchLimit = 1
        
        do {
            if let user = try context.fetch(req).first {
                // *** INI ADALAH LOGIKA FETCH DATA POINT ***
                self.user = user
                self.points = Int(user.user_point) // <--- POINTS DIUPDATE DI SINI
                // *******************************************
                
                print("📌 Dashboard user:", user.user_id!.uuidString)
                print("✅ Logged in user:", user.user_name ?? "")
                print("✅ Current Points:", self.points) // Debug
            } else {
                self.user = nil
                self.points = 0
            }
        } catch {
            print("❌ Error fetching user:", error.localizedDescription)
        }
    }
    
    // MARK: - ACTIVE SURVEY
    private func fetchActiveSurveys(for user: User) {
        let req: NSFetchRequest<Survey> = Survey.fetchRequest()
        
        req.predicate = NSPredicate(
            format: "is_public == YES AND survey_status_del == NO AND owned_by_user == %@",
            user
        )
        
        req.sortDescriptors = [
            NSSortDescriptor(
                keyPath: \Survey.survey_created_at,
                ascending: false
            )
        ]
        
        let result = try? context.fetch(req)
        print("FETCH RESULT:", result?.count ?? 0)
        
        self.activeSurveys = result ?? []
    }
    
    // MARK: - DRAFT SURVEYS
    private func fetchDraftSurveys(for user: User) {
        let req: NSFetchRequest<Survey> = Survey.fetchRequest()
        req.predicate = NSPredicate(
            format:
                "is_public == NO AND owned_by_user == %@",
            user
        )
        
        self.draftSurveys = (try? context.fetch(req)) ?? []
    }
    
    private func fetchFinishedSurveys(for user: User) {
        let req: NSFetchRequest<Survey> = Survey.fetchRequest()
        
        req.predicate = NSPredicate(
            format:
                "survey_status_del == YES AND owned_by_user == %@",
            user
        )
        
        self.finishedSurveys = (try? context.fetch(req)) ?? []
    }
    
    // MARK: - TOTAL RESPONSES
    func calculateTotalResponsesForAllSurveys() {
        var total = 0
        
        for survey in activeSurveys {
            // Re-fetch supaya instance match
            guard
                let safeSurvey = try? context.existingObject(
                    with: survey.objectID
                ) as? Survey
            else { continue }
            
            let request: NSFetchRequest<HResponse> = HResponse.fetchRequest()
            request.predicate = NSPredicate(
                format: "in_survey == %@",
                safeSurvey
            )
            
            if let results = try? context.fetch(request) {
                let uniqueUsers = Set(
                    results.compactMap { $0.is_filled_by_user }
                )
                total += uniqueUsers.count
            }
        }
        
        self.totalResponses = total
    }
    
    
    func calculateTotalSurveyCount() {
        let total = activeSurveys.count + draftSurveys.count + finishedSurveys.count
        self.allSurveys = total
    }
    
    func autoCheckFinishedSurveys() {
        guard let user = self.user else { return }

        let req: NSFetchRequest<Survey> = Survey.fetchRequest()
        req.predicate = NSPredicate(
            format: "is_public == YES AND survey_status_del == NO AND owned_by_user == %@",
            user
        )

        do {
            let surveys = try context.fetch(req)

            for survey in surveys {
                let responseReq: NSFetchRequest<HResponse> = HResponse.fetchRequest()
                responseReq.predicate = NSPredicate(
                    format: "in_survey == %@",
                    survey
                )

                let responses = try context.fetch(responseReq)
                let uniqueUsers = Set(responses.compactMap { $0.is_filled_by_user })
                let responseCount = uniqueUsers.count

                // 🔑 BANDINKAN DENGAN TARGET
                if responseCount >= Int(survey.survey_target_responden) {
                    survey.survey_status_del = true   // tandai selesai
                    print("✅ Survey finished:", survey.survey_title ?? "")
                }
            }

            try context.save()
        } catch {
            print("❌ autoCheckFinishedSurveys error:", error)
        }
    }

    
}
