//
//  LoginViewModel.swift
//  PollPal
//
//  Created by student on 05/12/25.
//

import CoreData
import Foundation
import SwiftUI

class LoginViewModel: ObservableObject {
    // Input User
    @Published var email: String = ""
    @Published var password: String = ""

    // Status UI
    @Published var errorMessage: String = ""
    @Published var showError: Bool = false
    @Published var isLoggedIn: Bool = false  // Pemicu pindah ke Dashboard

    private var viewContext: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.viewContext = context
    }

    func login() {
        // 1. Validasi Input Kosong
        guard !email.isEmpty, !password.isEmpty else {
            showError(msg: "Please fill in email and password.")
            return
        }

        // 2. Cari User berdasarkan Email
        let request: NSFetchRequest<User> = User.fetchRequest()
        request.predicate = NSPredicate(format: "user_email == %@", email)
        request.fetchLimit = 1

        do {
            let results = try viewContext.fetch(request)

            // 3. Cek apakah user ditemukan?
            if let user = results.first {

                // 4. Cek Password (Manual String Comparison)
                // Note: Di app asli, password harus di-hash (encrypted), jangan plain text.
                if user.user_pwd == password {
                    print("✅ Login Berhasil: \(user.user_name ?? "Unknown")")

                    // 5. Simpan Session (PENTING!)
                    // Ini kuncinya agar Dashboard tahu siapa yang login
                    if let uuid = user.user_id {
                        UserDefaults.standard.set(
                            uuid.uuidString,
                            forKey: "logged_in_user_id"
                        )
                        self.isLoggedIn = true  // Trigger navigasi
                    } else {
                        showError(msg: "Data User Corrupt (No ID).")
                    }

                } else {
                    // Password salah
                    showError(msg: "Incorrect password.")
                }

            } else {
                // Email tidak ditemukan
                showError(msg: "Email not registered.")
            }

        } catch {
            showError(msg: "Login error: \(error.localizedDescription)")
        }
    }

    private func showError(msg: String) {
        self.errorMessage = msg
        self.showError = true
    }
}
