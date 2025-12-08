//
//  ResetPasswordViewModel.swift
//  PollPal
//
//  Created by student on 08/12/25.
//

import Foundation
import CoreData
import SwiftUI

class ResetPasswordViewModel: ObservableObject {
    // Input dari View sebelumnya
    var targetEmail: String
    
    // Input User
    @Published var newPassword = ""
    @Published var confirmPassword = ""
    
    // Status UI
    @Published var isSuccess = false // Jika sukses, pindah ke Login
    @Published var errorMessage = ""
    @Published var showError = false
    
    private var viewContext: NSManagedObjectContext
    
    init(context: NSManagedObjectContext, email: String) {
        self.viewContext = context
        self.targetEmail = email
    }
    
    func resetPassword() {
            // 1. Validasi Input Kosong
            guard !newPassword.isEmpty, !confirmPassword.isEmpty else {
                showError(msg: "Please fill in all password fields.")
                return
            }
            
            // 2. Validasi Kecocokan Password
            guard newPassword == confirmPassword else {
                showError(msg: "Passwords do not match.")
                return
            }
            
            // --- 3. VALIDASI KOMPLEKSITAS PASSWORD (BARU) ---
            // Cek Huruf, Angka, Simbol, dan Min 8 Karakter
            if !isValidPassword(newPassword) {
                showError(msg: "Password must be at least 8 characters, containing letters, numbers, and symbols.")
                return
            }
            
            // 4. Update ke Core Data
            updatePasswordInDatabase()
        }
    
    private func updatePasswordInDatabase() {
        let request: NSFetchRequest<User> = User.fetchRequest()
        request.predicate = NSPredicate(format: "user_email == %@", targetEmail)
        request.fetchLimit = 1
        
        do {
            let results = try viewContext.fetch(request)
            
            if let userToUpdate = results.first {
                // UPDATE PASSWORD
                userToUpdate.user_pwd = newPassword
                // Update timestamp (opsional)
                // userToUpdate.updated_at = Date()
                
                // SIMPAN
                try viewContext.save()
                print("✅ Password updated for \(targetEmail)")
                
                // Trigger Navigasi
                self.isSuccess = true
            } else {
                showError(msg: "User not found. Cannot reset password.")
            }
        } catch {
            showError(msg: "Database error: \(error.localizedDescription)")
        }
    }
    
    // Helper: Validasi Password (Huruf, Angka, Simbol, Min 8 Karakter)
        private func isValidPassword(_ pass: String) -> Bool {
            // 1. Cek Panjang Karakter (Minimal 8)
            if pass.count < 8 {
                return false
            }
            
            // 2. Cek apakah ada Huruf (A-Z atau a-z)
            let hasLetter = pass.rangeOfCharacter(from: .letters) != nil
            
            // 3. Cek apakah ada Angka (0-9)
            let hasNumber = pass.rangeOfCharacter(from: .decimalDigits) != nil
            
            // 4. Cek apakah ada Simbol
            // Logikanya: Simbol adalah karakter yang BUKAN huruf dan BUKAN angka.
            let hasSymbol = pass.rangeOfCharacter(from: .alphanumerics.inverted) != nil
            
            // Syarat: Harus memenuhi ketiganya
            return hasLetter && hasNumber && hasSymbol
        }
    
    private func showError(msg: String) {
        self.errorMessage = msg
        self.showError = true
    }
}
