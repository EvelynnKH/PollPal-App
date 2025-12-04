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
    private let context: NSManagedObjectContext
    //hardcode
    var currentUserID: String = "felicia"
    init(context: NSManagedObjectContext) {
        self.context = context
        fetchSurveys()
    }
    func fetchSurveys() {
            let request: NSFetchRequest<Survey> = Survey.fetchRequest()
            
            // --- 1. SAMAKAN DATA DENGAN SEEDER ---
            // Di Seeder: user_name = "Felicia Kathrin"
            // Maka disini harus sama persis, atau logic filter user ganti pakai UUID/Email biar aman.
            let targetUserName = "Felicia Kathrin"
            let predicateNotDeleted = NSPredicate(format: "survey_status_del == NO")
            let predicateIsPublic = NSPredicate(format: "is_public == YES")
            
            // --- 2. PERBAIKAN LOGIC HUBUNGAN (RELATIONSHIP) ---
            // Penjelasan Path:
            // has_hresponse       -> Masuk ke daftar jawaban header
            // $resp               -> Ambil satu jawaban
            // is_filled_by_user   -> Masuk ke User Entity (Bukan String!)
            // user_name           -> Ambil properti String namanya
            
            let predicateNotFilledByUser = NSPredicate(
                format: "SUBQUERY(has_hresponse, $resp, $resp.is_filled_by_user.user_name == %@).@count == 0",
                targetUserName
            )
            
            // Gabungkan
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
                predicateNotDeleted, predicateIsPublic, predicateNotFilledByUser
            ])
            
            request.sortDescriptors = [NSSortDescriptor(key: "survey_created_at", ascending: false)]
            
            do {
                let results = try context.fetch(request)
                self.surveys = results.map { AvailableSurvey(entity: $0) }
                
            } catch {
                print("❌ Gagal fetch survey: \(error.localizedDescription)")
            }
        }
}

