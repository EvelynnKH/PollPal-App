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
    }

    private func fetchUser() {
        guard
            let uuidString = UserDefaults.standard.string(
                forKey: "logged_in_user_id"
            ),
            let uuid = UUID(uuidString: uuidString)
        else {
            print("❌ No logged_in_user_id in UserDefaults")
            return
        }

        let req: NSFetchRequest<User> = User.fetchRequest()
        req.predicate = NSPredicate(format: "user_id == %@", uuid as CVarArg)
        req.fetchLimit = 1

        do {
            if let user = try context.fetch(req).first {
                self.user = user
                self.points = Int(user.user_point)
                
                print("📌 Dashboard user:", user.user_id!.uuidString)


                print("✅ Logged in user:", user.user_name ?? "")
                print("✅ User ID:", uuid)
            }
        } catch {
            print("❌ Error fetching user:", error.localizedDescription)
        }
    }

    // MARK: - ACTIVE SURVEY
    private func fetchActiveSurveys(for user: User) {
        let req: NSFetchRequest<Survey> = Survey.fetchRequest()

        req.predicate = NSPredicate(
            format: "is_public == true AND owned_by_user == %@",
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
            format: "is_public == NO AND owned_by_user == %@",
            user
        )

        self.draftSurveys = (try? context.fetch(req)) ?? []
    }

    // MARK: - TOTAL RESPONSES
    func calculateTotalResponsesForAllSurveys() {
        var total = 0

        for survey in activeSurveys {
            // Re-fetch supaya instance match
            guard let safeSurvey = try? context.existingObject(with: survey.objectID) as? Survey else { continue }

            let request: NSFetchRequest<HResponse> = HResponse.fetchRequest()
            request.predicate = NSPredicate(format: "in_survey == %@", safeSurvey)

            if let results = try? context.fetch(request) {
                let uniqueUsers = Set(results.compactMap { $0.is_filled_by_user })
                total += uniqueUsers.count
            }
        }

        self.totalResponses = total
    }
    
    func calculateTotalSurveyCount() {
        var total = 0

        for survey in activeSurveys + draftSurveys {
            guard let safeSurvey = try? context.existingObject(with: survey.objectID) as? Survey else { continue }
            total += 1
        }

        self.allSurveys = total
    }






    
    
}

