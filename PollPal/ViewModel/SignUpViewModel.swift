//
//  SignUpViewModel.swift
//  PollPal
//
//  Created by student on 05/12/25.
//

import CoreData
import Foundation
import SwiftUI
import PhotosUI

class SignUpViewModel: ObservableObject {
    // MARK: - STEP 1 DATA (Personal Info)
    @Published var fullName: String = ""
    @Published var gender: String = "Female"
    @Published var birthDate: Date = Date()
    @Published var placeOfBirth: String = ""
    @Published var placeOfResidence: String = ""
    @Published var phoneNumber: String = ""
    
    // Image handling (KTM)
    @Published var selectedPhotoItem: PhotosPickerItem? = nil {
        didSet { processPhoto() }
    }
    @Published var ktmImage: UIImage? = nil
    
    // MARK: - STEP 2 DATA (Credentials)
    @Published var email: String = ""
    @Published var password: String = ""

    // MARK: - Status UI
    @Published var errorMessage: String = ""
    @Published var showError: Bool = false
    
    @Published var isStep1Valid: Bool = false
    @Published var isRegistered: Bool = false

    private var viewContext: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.viewContext = context
    }
    
    // MARK: - VALIDASI STEP 1 (UPDATED)
    func validateStep1() {
        // 1. Cek apakah ada field text yang kosong (atau hanya spasi)
        if fullName.trimmingCharacters(in: .whitespaces).isEmpty ||
           placeOfResidence.trimmingCharacters(in: .whitespaces).isEmpty {
            
            showError(msg: "Please fill in all personal details (Name and Birth Place).")
            return
        }
        
        // 2. Validasi Khusus Phone Number
        // Cek kosong
        if phoneNumber.trimmingCharacters(in: .whitespaces).isEmpty {
            showError(msg: "Phone number is required.")
            return
        }
        
        // Cek hanya angka
        if !phoneNumber.allSatisfy({ $0.isNumber }) {
            showError(msg: "Phone number must contain only numbers.")
            return
        }
        
        // Cek panjang minimal (opsional, sesuaikan kebutuhan, misal min 10 digit)
        if phoneNumber.count < 10 {
            showError(msg: "Phone number must be at least 10 digits.")
            return
        }
        
        // 3. Cek Foto KTM
        if ktmImage == nil {
            showError(msg: "Please upload your ID Card photo.")
            return
        }
        
        
        // Jika semua lolos, lanjut ke Step 2
        isStep1Valid = true
    }
    
    private func processPhoto() {
        guard let item = selectedPhotoItem else { return }
        Task {
            if let data = try? await item.loadTransferable(type: Data.self),
               let uiImage = UIImage(data: data) {
                await MainActor.run { self.ktmImage = uiImage }
            }
        }
    }

    // MARK: - FINAL REGISTER LOGIC
    func registerUser() {
        // 1. Validasi Input Step 2
        guard !email.isEmpty, !password.isEmpty else {
            showError(msg: "Please fill in email and password.")
            return
        }

        // 2. Validasi Format Email
        if !isValidEmail(email) {
            showError(msg: "Invalid email format.")
            return
        }

        // 3. Validasi Password
        if !isValidPassword(password) {
            showError(
                msg: "Password must be at least 8 characters, containing letters, numbers, and symbols."
            )
            return
        }

        // 4. Validasi Email Unik
        if emailExists(email: email) {
            showError(msg: "This email is already registered.")
            return
        }

        // 5. Buat User Baru (Simpan SEMUA Data)
        let newUser = User(context: viewContext)
        let newUUID = UUID()

        newUser.user_id = newUUID
        newUser.user_created_at = Date()
        newUser.user_status_del = false
        
        // Data dari Step 1
        newUser.user_name = fullName
        
//         Pastikan CoreData entity Anda memiliki atribut ini jika ingin disimpan:
         newUser.user_hp = phoneNumber
         newUser.user_birthdate = birthDate
         newUser.user_birthplace = placeOfBirth
         newUser.user_gender = gender
        
        // Data dari Step 2
        newUser.user_email = email
        newUser.user_pwd = password
        
        // Data Default
        newUser.user_point = 50
        newUser.user_header_img = "mountain"
        newUser.user_profile_img = "cat"

        // 6. Simpan ke Core Data
        do {
            try viewContext.save()
            print("✅ User Registered: \(fullName)")

            UserDefaults.standard.set(
                newUUID.uuidString,
                forKey: "logged_in_user_id"
            )

            self.isRegistered = true

        } catch {
            showError(msg: "Failed to save user: \(error.localizedDescription)")
        }
    }

    // MARK: - Helper Functions
    private func emailExists(email: String) -> Bool {
        let request: NSFetchRequest<User> = User.fetchRequest()
        request.predicate = NSPredicate(format: "user_email == %@", email)
        do {
            let count = try viewContext.count(for: request)
            return count > 0
        } catch { return false }
    }

    private func showError(msg: String) {
        self.errorMessage = msg
        self.showError = true
    }

    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }

    private func isValidPassword(_ pass: String) -> Bool {
        if pass.count < 8 { return false }
        let hasLetter = pass.rangeOfCharacter(from: .letters) != nil
        let hasNumber = pass.rangeOfCharacter(from: .decimalDigits) != nil
        let hasSymbol = pass.rangeOfCharacter(from: .alphanumerics.inverted) != nil
        return hasLetter && hasNumber && hasSymbol
    }
}
