//
//  ChangePasswordViewModel.swift
//  PollPal
//
//  Created by student on 08/12/25.
//

import Foundation
import CoreData
import SwiftUI

class ChangePasswordViewModel: ObservableObject {
    // Input UI
    @Published var currentPassword = "" // Input Password Lama
    @Published var newPassword = ""
    @Published var confirmPassword = ""
    
    // Status UI
    @Published var showAlert = false
    @Published var alertMessage = ""
    @Published var isSuccess = false
    
    private var viewContext: NSManagedObjectContext
    
    // Ambil ID User yang sedang login
    private var currentUserUUID: UUID? {
        if let idString = UserDefaults.standard.string(forKey: "logged_in_user_id") {
            return UUID(uuidString: idString)
        }
        return nil
    }
    
    init(context: NSManagedObjectContext) {
        self.viewContext = context
    }
    
    func changePassword() {
        // 1. Validasi Input Kosong
        guard !currentPassword.isEmpty, !newPassword.isEmpty, !confirmPassword.isEmpty else {
            showError("Please fill in all fields.")
            return
        }
        
        // 2. Validasi Match Password Baru
        guard newPassword == confirmPassword else {
            showError("New passwords do not match.")
            return
        }
        
        // 3. Validasi Kompleksitas Password Baru
        if !isValidPassword(newPassword) {
             showError("New password must be at least 8 characters, containing letters, numbers, and symbols.")
             return
        }
        
        // 4. Proses Database
        performDatabaseUpdate()
    }
    
    private func performDatabaseUpdate() {
        guard let myID = currentUserUUID else {
            showError("Session expired. Please re-login.")
            return
        }
        
        let request: NSFetchRequest<User> = User.fetchRequest()
        request.predicate = NSPredicate(format: "user_id == %@", myID as CVarArg)
        request.fetchLimit = 1
        
        do {
            let results = try viewContext.fetch(request)
            
            if let user = results.first {
                // 5. CEK PASSWORD LAMA (CRITICAL SECURITY)
                // Pastikan password lama yang diinput user cocok dengan di database
                if user.user_pwd != currentPassword {
                    showError("Incorrect current password.")
                    return
                }
                
                // 6. Update Password
                user.user_pwd = newPassword
                
                try viewContext.save()
                print("✅ Password changed successfully for user.")
                
                // Berhasil
                self.isSuccess = true
                
            } else {
                showError("User not found.")
            }
        } catch {
            showError("Database error: \(error.localizedDescription)")
        }
    }
    
    // Helper: Validasi Password (Huruf, Angka, Simbol, Min 8 Karakter)
    private func isValidPassword(_ pass: String) -> Bool {
        if pass.count < 8 { return false }
        let hasLetter = pass.rangeOfCharacter(from: .letters) != nil
        let hasNumber = pass.rangeOfCharacter(from: .decimalDigits) != nil
        let hasSymbol = pass.rangeOfCharacter(from: .alphanumerics.inverted) != nil
        return hasLetter && hasNumber && hasSymbol
    }
    
    private func showError(_ msg: String) {
        self.alertMessage = msg
        self.showAlert = true
    }
}
