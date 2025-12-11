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
    let deadline: Date? // 1. Property Baru
    let originEntity: Survey
    
    // Init khusus dari Core Data Entity
    init(entity: Survey) {
        self.id = entity.survey_id ?? UUID()
        self.title = entity.survey_title ?? "Tanpa Judul"
        
        // Handling Category
        if let categorySet = entity.has_category as? Set<Category> {
            let names = categorySet.compactMap { $0.category_name }
            if names.isEmpty {
                self.category = "Uncategorized"
            } else {
                self.category = names.sorted().joined(separator: ", ")
            }
        } else {
            self.category = "Uncategorized"
        }
        
        // Handling Reward (Sesuai Core Data)
        self.reward = Int(entity.survey_rewards_points)
        
        if let questions = entity.has_question, questions.count > 0 {
            let count = Double(questions.count)
            
            // Asumsi: 1 soal = 30 detik (0.5 menit)
            let durationInMinutes = count * 0.5
            
            // Bulatkan ke atas
            let calculatedDuration = Int(ceil(durationInMinutes))
            
            // Gunakan fungsi max() untuk memastikan minimal 1 menit
            // Jadi kita hanya melakukan assignment ke self.estimatedTime SATU KALI
            self.estimatedTime = max(1, calculatedDuration)
            
        } else {
            // Jika tidak ada soal, set 0
            self.estimatedTime = 0
        }
        
        // 2. Mapping Deadline
        self.deadline = entity.survey_deadline
        
        self.originEntity = entity
    }
    
    // Helper untuk format tanggal (Biar rapi di View)
    var formattedDeadline: String {
        guard let date = deadline else { return "" }
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM yyyy" // Contoh: 12 Dec 2025
        return formatter.string(from: date)
    }
    
    // Helper untuk cek apakah sudah expired (Opsional, buat warna merah nanti)
    var isExpired: Bool {
        guard let date = deadline else { return false }
        return date < Date()
    }
}
