//
//  AvailableSurvey.swift
//  PollPal
//
//  Created by student on 03/12/25.
//

import Foundation
import CoreData

struct AvailableSurvey: Identifiable {
    let id: UUID
    let title: String
    let category: String
    let reward: Int?
    let estimatedTime: Int?
    let originEntity: Survey
    
    // Init khusus dari Core Data Entity
    init(entity: Survey) {
        // 1. Handling ID (Langsung ambil karena sudah UUID)
        // Jika nil, kita buat UUID baru agar tidak crash/error
        self.id = entity.survey_id ?? UUID()
        
        self.title = entity.survey_title ?? "Tanpa Judul"
        
        // 2. Handling Many-to-Many Category (CRITICAL PART)
        // Relasi 'has_category' di Core Data adalah NSSet. Kita perlu cast ke Set<Category>
        if let categorySet = entity.has_category as? Set<Category> {
            // Ambil nama category, filter yang nil, lalu gabungkan dengan koma
            let names = categorySet.compactMap { $0.category_name }
            
            if names.isEmpty {
                self.category = "Uncategorized"
            } else {
                // Contoh hasil: "Technology, Design"
                self.category = names.sorted().joined(separator: ", ")
            }
        } else {
            self.category = "Uncategorized"
        }
        
        // 3. Mapping Reward
        self.reward = Int(entity.survey_rewards_points)
        
        // 4. Estimasi Waktu (Logic: Jumlah Soal x 1 Menit)
        if let questions = entity.has_question {
            self.estimatedTime = 10 * 1
        } else {
            self.estimatedTime = 0
        }
        
        self.originEntity = entity
    }
}
