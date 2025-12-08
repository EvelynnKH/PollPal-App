//
//  ProfileUserViewModel.swift
//  PollPal
//
//  Created by student on 03/12/25.
//

import CoreData
import Foundation
import SwiftUI
import PhotosUI // Wajib import ini

class ProfileUserViewModel: ObservableObject {
    // MARK: - Properties
    @Published var userName: String = "Guest"
    @Published var userEmail: String = "-"
    @Published var userPoints: Int = 0
    @Published var userHeaderImage: String = "mountain"
    @Published var userProfileImage: String = "cat"
    @Published var userInterests: String = "-"
    @Published var completedSurveysCount: Int = 0
    
    // UI Images (Preview)
    @Published var uiProfileImage: UIImage? = nil
    @Published var uiHeaderImage: UIImage? = nil

    private var viewContext: NSManagedObjectContext
    private var currentUser: User?

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

    // MARK: - Fetch Data
    func fetchUserProfile() {
        guard let myID = currentUserUUID else { return }

        let request: NSFetchRequest<User> = User.fetchRequest()
        request.predicate = NSPredicate(format: "user_id == %@", myID as CVarArg)
        request.fetchLimit = 1

        do {
            let users = try viewContext.fetch(request)
            if let user = users.first {
                self.currentUser = user
                self.userName = user.user_name ?? "No Name"
                self.userEmail = user.user_email ?? "-"
                self.userPoints = Int(user.user_point)
                
                // Load nama file gambar (String)
                self.userHeaderImage = user.user_header_img ?? "mountain"
                self.userProfileImage = user.user_profile_img ?? "cat"
                
                if let interests = user.like_category as? Set<Category> {
                    let names = interests.compactMap { $0.category_name }
                    self.userInterests = names.isEmpty ? "No interest yet" : names.sorted().joined(separator: ", ")
                } else {
                    self.userInterests = "No interest yet"
                }

                if let filledSurveys = user.filled_hresponse {
                    self.completedSurveysCount = filledSurveys.count
                }
            }
        } catch {
            print("❌ Gagal fetch profile: \(error)")
        }
    }
    
    // MARK: - LOGIC GANTI FOTO (Updated)
    
    func updateProfileImage(item: PhotosPickerItem?) {
        guard let item = item else { return }
        Task {
            if let data = try? await item.loadTransferable(type: Data.self),
               let uiImage = UIImage(data: data) {
                await MainActor.run { self.uiProfileImage = uiImage }
                saveToCoreData(image: uiImage, isHeader: false)
            }
        }
    }
    
    func updateHeaderImage(item: PhotosPickerItem?) {
        guard let item = item else { return }
        Task {
            if let data = try? await item.loadTransferable(type: Data.self),
               let uiImage = UIImage(data: data) {
                await MainActor.run { self.uiHeaderImage = uiImage }
                saveToCoreData(image: uiImage, isHeader: true)
            }
        }
    }
    
    private func saveToCoreData(image: UIImage, isHeader: Bool) {
        guard let user = currentUser else { return }
        
        // 1. Simpan ke Disk (Pakai fungsi internal di bawah)
        guard let newFileName = saveImageToDisk(image) else { return }
        
        // 2. Hapus file lama & Update Core Data
        if isHeader {
            if let oldFile = user.user_header_img { deleteImageFromDisk(named: oldFile) }
            user.user_header_img = newFileName
        } else {
            if let oldFile = user.user_profile_img { deleteImageFromDisk(named: oldFile) }
            user.user_profile_img = newFileName
        }
        
        // 3. Save Context
        do {
            try viewContext.save()
            print("✅ Gambar tersimpan: \(newFileName)")
        } catch {
            print("❌ Gagal simpan DB: \(error)")
        }
    }
    
    // MARK: - INTERNAL FILE MANAGER HELPERS
    // (Fungsi Helper dipindah ke sini)
    
    private func saveImageToDisk(_ image: UIImage) -> String? {
        guard let data = image.jpegData(compressionQuality: 0.6) else { return nil }
        let fileName = UUID().uuidString + ".jpg"
        let fileURL = getDocumentsDirectory().appendingPathComponent(fileName)
        
        do {
            try data.write(to: fileURL)
            return fileName
        } catch {
            print("❌ Gagal tulis file: \(error)")
            return nil
        }
    }
    
    private func deleteImageFromDisk(named fileName: String) {
        let fileURL = getDocumentsDirectory().appendingPathComponent(fileName)
        try? FileManager.default.removeItem(at: fileURL)
    }
    
    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}
