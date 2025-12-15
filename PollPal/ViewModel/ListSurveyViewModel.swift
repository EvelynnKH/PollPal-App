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
    
    // Properties Filter
    var filterCategory: String?
    var initialSearchText: String?

    private let context: NSManagedObjectContext
    
    // 1. TAMBAHAN: Ambil ID User yang sedang login
    private var currentUserUUID: UUID? {
        if let idString = UserDefaults.standard.string(forKey: "logged_in_user_id") {
            return UUID(uuidString: idString)
        }
        return nil
    }
    
    // Init (Tidak berubah)
    init(context: NSManagedObjectContext, category: String? = nil, searchText: String? = nil) {
        self.context = context
        self.filterCategory = category
        self.initialSearchText = searchText
        
        fetchSurveys()
    }
    
    func fetchSurveys() {
            let request: NSFetchRequest<Survey> = Survey.fetchRequest()
            
            // 1. Predicate Dasar (Aktif & Public)
            var predicates: [NSPredicate] = [
                NSPredicate(format: "survey_status_del == NO"),
                NSPredicate(format: "is_public == YES")
            ]
            
            // 2. Filter Kategori (Jika ada)
            if let catName = filterCategory {
                let categoryPredicate = NSPredicate(
                    format: "SUBQUERY(has_category, $cat, $cat.category_name == %@).@count > 0",
                    catName
                )
                predicates.append(categoryPredicate)
            }
            
            // 3. Filter Search (Jika ada)
            if let search = initialSearchText, !search.isEmpty {
                let searchPredicate = NSPredicate(
                    format: "survey_title CONTAINS[cd] %@",
                    search
                )
                predicates.append(searchPredicate)
            }
            
            // 4. LOGIKA UTAMA: FETCH USER UNTUK DEMOGRAFI & PENGECUALIAN
            // Ambil ID dari UserDefaults
            if let userIdStr = UserDefaults.standard.string(forKey: "logged_in_user_id"),
               let userId = UUID(uuidString: userIdStr) {
                
                let userReq: NSFetchRequest<User> = User.fetchRequest()
                userReq.predicate = NSPredicate(format: "user_id == %@", userId as CVarArg)
                userReq.fetchLimit = 1
                
                do {
                    // Coba ambil object User
                    if let currentUser = try context.fetch(userReq).first {
                        
                        // --- A. DEADLINE (Aktif) ---
                        // Deadline Kosong OR Deadline >= Hari Ini
                        predicates.append(
                            NSPredicate(format: "survey_deadline == nil OR survey_deadline >= %@", Date() as NSDate)
                        )
                        
                        // --- B. QUOTA (Belum Penuh) ---
                        predicates.append(
                            NSPredicate(format: "has_hresponse.@count < survey_target_responden")
                        )
                        
                        // --- C. GENDER ---
                        if let userGender = currentUser.user_gender {
                            let genderPred = NSPredicate(
                                format: "survey_gender ==[cd] %@ OR survey_gender ==[cd] 'All'",
                                userGender
                            )
                            predicates.append(genderPred)
                        }
                        
                        // --- D. RESIDENCE ---
                        if let userRes = currentUser.user_residence, !userRes.isEmpty {
                            // Logic: Lokasi User Match, ATAU Target 'All', ATAU Target Kosong
                            let resPred = NSPredicate(
                                format: "survey_residence ==[cd] %@ OR survey_residence ==[cd] 'All' OR survey_residence == '' OR survey_residence == nil",
                                userRes
                            )
                            predicates.append(resPred)
                        } else {
                            // User Tanpa Lokasi -> Hanya lihat 'All' atau Kosong
                            let noResPred = NSPredicate(
                                format: "survey_residence ==[cd] 'All' OR survey_residence == '' OR survey_residence == nil"
                            )
                            predicates.append(noResPred)
                        }
                        
                        // --- E. USIA ---
                        if let birthDate = currentUser.user_birthdate {
                            let userAge = Calendar.current.dateComponents([.year], from: birthDate, to: Date()).year ?? 0
                            
                            predicates.append(NSPredicate(format: "survey_usia_min <= %d", userAge))
                            predicates.append(NSPredicate(format: "survey_usia_max >= %d", userAge))
                        }
                        
                        // --- F. PENGECUALIAN (Not Mine & Not Filled) ---
                        
                        // Jangan tampilkan survei milik sendiri
                        let notMinePredicate = NSPredicate(
                            format: "owned_by_user.user_id != %@",
                            userId as CVarArg
                        )
                        predicates.append(notMinePredicate)
                        
                        // Jangan tampilkan survei yang SUDAH diisi
                        let notFilledPredicate = NSPredicate(
                            format: "SUBQUERY(has_hresponse, $resp, $resp.is_filled_by_user.user_id == %@).@count == 0",
                            userId as CVarArg
                        )
                        predicates.append(notFilledPredicate)
                    }
                } catch {
                    print("❌ Gagal ambil data user untuk filter: \(error)")
                }
            }
            
            // 5. EKSEKUSI FINAL
            // Gabungkan semua filter
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
            
            // Sortir: Terbaru di atas
            request.sortDescriptors = [
                NSSortDescriptor(key: "survey_created_at", ascending: false)
            ]
            
            do {
                let results = try context.fetch(request)
                // Transformasi Entity ke Struct View
                self.surveys = results.map { AvailableSurvey(entity: $0) }
                
                print("🔍 List Survey Loaded: \(results.count) items found matching all criteria.")
                
            } catch {
                print("❌ Error fetching list surveys: \(error.localizedDescription)")
            }
        }
}
