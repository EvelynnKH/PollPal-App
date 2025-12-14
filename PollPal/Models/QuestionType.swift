//
//  QuestionType.swift
//  PollPal
//
//  Created by Shienny Megawati Sutanto on 05/12/25.
//
import Foundation

// Ubah Enum agar rawValue-nya cocok dengan Database
enum QuestionType: String, CaseIterable, Identifiable {
    // Kiri: Nama Case di Swift (Boleh camelCase)
    // Kanan: String persis yang tersimpan di Database/Seeder
    
    case shortAnswer = "Short Answer"
    case paragraph = "Paragraph"
    case multipleChoice = "Multiple Choice"
    case checkboxes = "Check Box"  // Perhatikan: Seeder pakai "Check Box"
    case dropdown = "Drop Down"  // Perhatikan: Seeder pakai "Drop Down"
    case linearscale = "Linear Scale"  // Perhatikan: Seeder pakai "Linear Scale"
    
    var id: String { self.rawValue }
    /// Harga poin per pertanyaan
    var pointCost: Int {
        switch self {
        case .shortAnswer:
            return 12
        case .paragraph:
            return 20
        case .multipleChoice:
            return 10  // pilgan
        case .checkboxes:
            return 15  // bisa multi pilihan
        case .dropdown:
            return 12
        case .linearscale:
            return 12
        }
    }
}

// Extension untuk judul tampilan (Optional, tapi bagus untuk UI)
extension QuestionType {
    var title: String {
        // Karena rawValue kita sudah rapi ("Multiple Choice"),
        // kita bisa langsung kembalikan rawValue-nya.
        return self.rawValue
    }
}
