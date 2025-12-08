//
//  SignUpViewModel.swift
//  PollPal
//
//  Created by student on 05/12/25.
//

import CoreData
import Foundation
import SwiftUI

class SignUpViewModel: ObservableObject {
    // Input dari User
    @Published var email = ""
    @Published var password = ""
    @Published var fullName = ""

    // Status UI
    @Published var errorMessage = ""
    @Published var showError = false
    @Published var isRegistered = false  // Pemicu navigasi ke Dashboard

    private var viewContext: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.viewContext = context
    }

    func registerUser() {
        // 1. Validasi Input Kosong
        guard !email.isEmpty, !password.isEmpty, !fullName.isEmpty else {
            showError(msg: "Please fill in all fields.")
            return
        }

        // 2. Validasi Format Email
        if !isValidEmail(email) {
            showError(msg: "Invalid email format.")
            return
        }

        // --- 3. VALIDASI PASSWORD (BARU) ---
        if !isValidPassword(password) {
            // Pesan error yang detail
            showError(
                msg:
                    "Password must be at least 8 characters, containing letters, numbers, and symbols."
            )
            return
        }

        // 4. Validasi Email Unik (Cek Database)
        if emailExists(email: email) {
            showError(msg: "This email is already registered.")
            return
        }

        // 3. Buat User Baru
        let newUser = User(context: viewContext)
        let newUUID = UUID()

        newUser.user_id = newUUID
        newUser.user_email = email
        newUser.user_pwd = password  // Note: Di aplikasi nyata, password harus di-hash!
        newUser.user_name = fullName

        // Set Default Value (Penting agar tidak crash/kosong di Dashboard)
        newUser.user_point = 50  // Welcome Bonus Poin!
        newUser.user_created_at = Date()
        newUser.user_status_del = false
        newUser.user_header_img = "mountain"  // Gambar default
        newUser.user_profile_img = "cat"  // Gambar default

        // 4. Simpan ke Core Data
        do {
            try viewContext.save()
            print("✅ User berhasil dibuat: \(fullName)")

            // 5. Simpan Session Login
            // Agar Dashboard tahu siapa yang sedang login
            UserDefaults.standard.set(
                newUUID.uuidString,
                forKey: "logged_in_user_id"
            )

            // Trigger navigasi ke Dashboard
            self.isRegistered = true

        } catch {
            showError(msg: "Failed to save user: \(error.localizedDescription)")
        }
    }

    // Helper: Cek Email di Database
    private func emailExists(email: String) -> Bool {
        let request: NSFetchRequest<User> = User.fetchRequest()
        request.predicate = NSPredicate(format: "user_email == %@", email)

        do {
            let count = try viewContext.count(for: request)
            return count > 0
        } catch {
            return false
        }
    }

    // Helper: Tampilkan Error
    private func showError(msg: String) {
        self.errorMessage = msg
        self.showError = true
    }

    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

        let emailPred = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
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
        // .alphanumerics.inverted artinya "Segala sesuatu kecuali huruf dan angka"
        let hasSymbol =
            pass.rangeOfCharacter(from: .alphanumerics.inverted) != nil

        // Syarat: Harus memenuhi ketiganya
        return hasLetter && hasNumber && hasSymbol
    }
}
