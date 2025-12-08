//
//  DashboardCreatorViewModel.swift
//  PollPal
//
//  Created by student on 04/12/25.
//
import Foundation
import CoreData

class DashboardCreatorViewModel: ObservableObject {
    
    @Published var user: User?
    @Published var points: Int = 0

    @Published var activeSurveys: [Survey] = []
    @Published var draftSurveys: [Survey] = []
    @Published var totalResponses: Int = 0

    private var context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
        loadData()
    }
    
    func loadData() {
        fetchUser()
        fetchActiveSurveys()
        fetchDraftSurveys()
        fetchTotalResponses()
    }
    
    private func fetchUser() {
        let req: NSFetchRequest<User> = User.fetchRequest()
        req.predicate = NSPredicate(format: "user_status_del == 0")
        
        if let result = try? context.fetch(req).first {
            self.user = result
            self.points = Int(result.user_point)
        }
    }
    
    private func fetchActiveSurveys() {
        let req: NSFetchRequest<Survey> = Survey.fetchRequest()
        req.predicate = NSPredicate(format: "survey_status_del == 0")
        req.sortDescriptors = [NSSortDescriptor(keyPath: \Survey.survey_created_at, ascending: false)]
        
        self.activeSurveys = (try? context.fetch(req)) ?? []
    }
    
    private func fetchDraftSurveys() {
        let req: NSFetchRequest<Survey> = Survey.fetchRequest()
        req.predicate = NSPredicate(format: "is_public = %@", NSNumber(booleanLiteral: false))

        self.draftSurveys = (try? context.fetch(req)) ?? []
    }
    
    private func fetchTotalResponses() {
        let req: NSFetchRequest<HResponse> = HResponse.fetchRequest()
        let results = (try? context.fetch(req)) ?? []
        self.totalResponses = results.count
    }
    
    
}
