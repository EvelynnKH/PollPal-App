//
//  ForgotPasswordViewModel.swift
//  PollPal
//
//  Created by student on 05/12/25.
//

import Foundation
import CoreData
import SwiftUI

class ForgotPasswordViewModel: ObservableObject {
    // Input
    @Published var email: String = ""
    
    // Output UI
    @Published var navigateToVerify: Bool = false // Jika email ketemu, pindah layar
    @Published var errorMessage: String = ""
    @Published var showError: Bool = false
    
    private var viewContext: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.viewContext = context
    }
    
    func sendCode() {
        // 1. Validasi Input Kosong
        guard !email.isEmpty else {
            showError(msg: "Please enter your email address.")
            return
        }
        
        // 2. Cek apakah Email ada di Core Data?
        if checkEmailExists(email: email) {
            print("✅ Email ditemukan! Simulasi kirim kode ke \(email)")
            // Di sini kita anggap sukses dan lanjut ke layar berikutnya
            self.navigateToVerify = true
        } else {
            print("❌ Email tidak terdaftar.")
            showError(msg: "Email not found. Please register first.")
        }
    }
    
    private func checkEmailExists(email: String) -> Bool {
        let request: NSFetchRequest<User> = User.fetchRequest()
        request.predicate = NSPredicate(format: "user_email == %@", email)
        request.fetchLimit = 1
        
        do {
            let count = try viewContext.count(for: request)
            return count > 0
        } catch {
            return false
        }
    }
    
    private func showError(msg: String) {
        self.errorMessage = msg
        self.showError = true
    }
}
