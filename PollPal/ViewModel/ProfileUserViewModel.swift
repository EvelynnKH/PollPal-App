//
//  ProfileUserViewModel.swift
//  PollPal
//
//  Created by student on 03/12/25.
//

import CoreData
import Foundation
import SwiftUI

class ProfileUserViewModel: ObservableObject {
    // Properties yang akan ditampilkan di View
    @Published var userName: String = "Guest"
    @Published var userEmail: String = "-"
    @Published var userPoints: Int = 0
    @Published var userHeaderImage: String = "mountain"
    @Published var userProfileImage: String = "cat"
    @Published var userInterests: String = "-"
    @Published var completedSurveysCount: Int = 0

    private var viewContext: NSManagedObjectContext
    private var currentUser: User?

    // 1. Hapus Hardcode Nama
    // private let targetName = "Felicia Kathrin" // DELETE

    // 2. Ambil UUID User yang sedang login
    private var currentUserUUID: UUID? {
        if let idString = UserDefaults.standard.string(forKey: "logged_in_user_id") {
            return UUID(uuidString: idString)
        }
        return nil
    }

    init(context: NSManagedObjectContext) {
        self.viewContext = context
        fetchUserProfile()
    }

    func fetchUserProfile() {
        // 3. Cek apakah ada user login?
        guard let myID = currentUserUUID else {
            print("⚠️ ProfileViewModel: Tidak ada user login (Guest).")
            // Reset ke default Guest
            self.userName = "Guest"
            self.userEmail = "Please Login"
            self.userPoints = 0
            self.completedSurveysCount = 0
            self.userInterests = "-"
            return
        }

        let request: NSFetchRequest<User> = User.fetchRequest()
        
        // 4. Ubah Predicate: Cari berdasarkan user_id (UUID)
        request.predicate = NSPredicate(format: "user_id == %@", myID as CVarArg)
        request.fetchLimit = 1

        do {
            let users = try viewContext.fetch(request)
            
            // Debugging: Cek siapa yang terpanggil
            if let user = users.first {
                print("👤 Profile Loaded: \(user.user_name ?? "No Name")")
                self.currentUser = user

                // 5. Set Data ke Property
                self.userName = user.user_name ?? "No Name"
                self.userEmail = user.user_email ?? "-"
                self.userPoints = Int(user.user_point)
                self.userHeaderImage = user.user_header_img ?? "mountain"
                self.userProfileImage = user.user_profile_img ?? "cat"
                
                // Logic Interests (Categories)
                if let interests = user.like_category as? Set<Category> {
                    let names = interests.compactMap { $0.category_name }

                    if names.isEmpty {
                        self.userInterests = "No interest yet"
                    } else {
                        self.userInterests = names.sorted().joined(separator: ", ")
                    }
                } else {
                    self.userInterests = "No interest yet"
                }

                // Logic Survey Count
                // Pastikan relationship 'filled_hresponse' tipe To-Many di Core Data Editor
                if let filledSurveys = user.filled_hresponse {
                    self.completedSurveysCount = filledSurveys.count
                } else {
                    self.completedSurveysCount = 0
                }
            } else {
                print("❌ User ID '\(myID)' tidak ditemukan. Pastikan proses Sign Up/Login berhasil.")
            }
        } catch {
            print("❌ Gagal mengambil profile user: \(error.localizedDescription)")
        }
    }
}
