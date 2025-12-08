//
//  EditProfileViewModel.swift
//  PollPal
//
//  Created by student on 08/12/25.
//

import Foundation
import CoreData
import SwiftUI

class EditProfileViewModel: ObservableObject {
    // MARK: - Published Properties (Untuk UI)
    @Published var fullName: String = ""
    @Published var allCategories: [Category] = []      // Daftar semua pilihan kategori
    @Published var selectedCategories: Set<Category> = [] // Kategori yang sedang dipilih user
    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""
    
    private var viewContext: NSManagedObjectContext
    private var currentUser: User?
    
    // Ambil UUID User yang sedang login dari Session
    private var currentUserUUID: UUID? {
        if let idString = UserDefaults.standard.string(forKey: "logged_in_user_id") {
            return UUID(uuidString: idString)
        }
        return nil
    }
    
    init(context: NSManagedObjectContext) {
        self.viewContext = context
        fetchData()
    }
    
    // MARK: - Fetch Data
    func fetchData() {
        // 1. Ambil Semua Kategori yang tersedia di Database (Tech, Health, dll)
        let catRequest: NSFetchRequest<Category> = Category.fetchRequest()
        catRequest.sortDescriptors = [NSSortDescriptor(key: "category_name", ascending: true)]
        
        do {
            self.allCategories = try viewContext.fetch(catRequest)
        } catch {
            print("❌ Error fetch categories: \(error.localizedDescription)")
        }
        
        // 2. Ambil Data User yang sedang login
        guard let myID = currentUserUUID else { return }
        
        let userRequest: NSFetchRequest<User> = User.fetchRequest()
        userRequest.predicate = NSPredicate(format: "user_id == %@", myID as CVarArg)
        userRequest.fetchLimit = 1
        
        do {
            let users = try viewContext.fetch(userRequest)
            if let user = users.first {
                self.currentUser = user
                
                // Isi Form dengan data lama
                self.fullName = user.user_name ?? ""
                
                // Isi Checkbox dengan interest lama user
                if let interests = user.like_category as? Set<Category> {
                    self.selectedCategories = interests
                }
            }
        } catch {
            print("❌ Error fetch user: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Logic Actions
        
        func toggleCategory(_ category: Category) {
            if selectedCategories.contains(category) {
                // 1. Jika sudah dipilih -> Hapus (Selalu boleh)
                selectedCategories.remove(category)
            } else {
                // 2. Jika belum dipilih -> Cek Limit Dulu
                if selectedCategories.count < 3 {
                    selectedCategories.insert(category)
                } else {
                    // 3. Jika sudah 3 -> Tampilkan Error
                    alertMessage = "You can only select up to 3 interests."
                    showAlert = true
                }
            }
        }
    
    // Fungsi Simpan Perubahan
    func saveChanges() {
        guard let user = currentUser else { return }
        
        // 1. Update Nama
        user.user_name = fullName
        
        // 2. Update Kategori (Relationship Many-to-Many)
        // Kita timpa relasi lama dengan Set baru
        user.like_category = selectedCategories as NSSet
        
        // 3. Commit ke Core Data
        do {
            try viewContext.save()
            print("✅ Profile Updated Successfully for \(fullName)")
        } catch {
            print("❌ Failed to save profile: \(error.localizedDescription)")
        }
    }
}
