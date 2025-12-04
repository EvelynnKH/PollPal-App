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

    init(context: NSManagedObjectContext) {
        self.viewContext = context
        fetchUserProfile()
    }

    func fetchUserProfile() {
        // 1. Fetch User
        // Karena belum ada sistem login, kita ambil user pertama yang ada di database
        // (Biasanya ini diambil berdasarkan ID user yang login)
        let request: NSFetchRequest<User> = User.fetchRequest()
        request.fetchLimit = 1

        do {
            let users = try viewContext.fetch(request)
            if let user = users.first {
                self.currentUser = user

                // 2. Set Data ke Property
                self.userName = user.user_name ?? "No Name"
                self.userEmail = user.user_email ?? "-"
                self.userPoints = Int(user.user_point)
                self.userHeaderImage = user.user_header_img ?? "mountain"
                self.userProfileImage = user.user_profile_img ?? "cat"
                if let interests = user.like_category as? Set<Category> {
                    let names = interests.compactMap { $0.category_name }

                    if names.isEmpty {
                        self.userInterests = "No interest yet"
                    } else {
                        // Hasil: "Gaming, Science, Technology"
                        self.userInterests = names.sorted().joined(
                            separator: ", "
                        )
                    }
                } else {
                    self.userInterests = "No interest yet"
                }

                // 3. Hitung Jumlah Survey yang sudah dikerjakan
                // Menggunakan relasi 'is_filled_by_user' (HResponse)
                if let filledSurveys = user.filled_hresponse {
                    self.completedSurveysCount = filledSurveys.count
                } else {
                    self.completedSurveysCount = 0
                }
            }
        } catch {
            print(
                "❌ Gagal mengambil profile user: \(error.localizedDescription)"
            )
        }
    }
}
