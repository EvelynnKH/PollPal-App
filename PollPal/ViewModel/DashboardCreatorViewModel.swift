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

    func loadData() {
        fetchUser()

        guard let user = self.user else { return }

        fetchActiveSurveys(for: user)
        fetchDraftSurveys(for: user)
        fetchTotalResponses(for: user)
        fetchAllSurveys()
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
            format: "survey_status_del == 0 AND owned_by_user == %@",
            user
        )
        req.sortDescriptors = [
            NSSortDescriptor(
                keyPath: \Survey.survey_created_at,
                ascending: false
            )
        ]

        self.activeSurveys = (try? context.fetch(req)) ?? []
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
    private func fetchTotalResponses(for user: User) {
        let req: NSFetchRequest<HResponse> = HResponse.fetchRequest()
        req.predicate = NSPredicate(format: "is_filled_by_user == %@", user)

        let results = (try? context.fetch(req)) ?? []
        self.totalResponses = results.count
    }

    // MARK: - TOTAL SURVEYS (INI YANG KAMU MAU)
    private func fetchAllSurveys() {

        guard let user = self.user else {
            print("❌ User not found")
            return
        }

        let req: NSFetchRequest<Survey> = Survey.fetchRequest()
        req.predicate = NSPredicate(format: "survey_status_del == false AND owned_by_user == %@", user)

        do {
            let count = try context.count(for: req)
            self.allSurveys = count

            print("✅ Total surveys milik \(user.user_name ?? ""): \(count)")

        } catch {
            print("❌ Error counting surveys:", error.localizedDescription)
            self.allSurveys = 0
        }
    }

    
    
}

