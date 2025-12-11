//
//  EditProfileViewModel.swift
//  PollPal
//
//  Created by student on 08/12/25.
//

import Foundation
import CoreData
import SwiftUI

class EditProfileViewModel: ObservableObject {
    // MARK: - Published Properties (Untuk UI)
    @Published var fullName: String = ""
    
    // --- NEW DEMOGRAPHIC PROPERTIES ---
    // Display Only (Loaded from User)
    @Published var gender: String = "Not Set"
    // Core Data Attribute: user_birthdate (Date)
    @Published var dateOfBirth: Date = Date()
    // Core Data Attribute: user_birthplace (String)
    @Published var placeOfBirth: String = "Not Set"
    
    // Editable Fields
    // Core Data Attribute: user_residence (String)
    @Published var placeOfResidence: String = ""
    // Core Data Attribute: user_hp (String)
    @Published var phoneNumber: String = ""
    
    // Image Upload (Simulating UIImage for UI, Core Data attribute is String/Binary Data)
    // Core Data Attribute: user_ktm_img (String - assuming this stores a path or URL)
    @Published var ktmImage: UIImage? = nil
    
    // --- EXISTING PROPERTIES ---
    @Published var allCategories: [Category] = []
    @Published var selectedCategories: Set<Category> = []
    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""
    
    @Published var isShowingImagePicker = false
    @Published var imageUploadError: String? = nil
    
    private var viewContext: NSManagedObjectContext
    private var currentUser: User?
    
    // Property to hold the path/URL for saving (if user_ktm_img is a String)
    private var ktmImagePath: String?
    
    private var currentUserUUID: UUID? {
        if let idString = UserDefaults.standard.string(forKey: "logged_in_user_id") {
            return UUID(uuidString: idString)
        }
        return nil
    }
    
    init(context: NSManagedObjectContext) {
        self.viewContext = context
    }
    
    // MARK: - Fetch Data
    func fetchData() {
        // ... (Existing Category fetch logic) ...
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
                
                // --- Load Form Data from User (Matching Core Data Attributes) ---
                self.fullName = user.user_name ?? "Not Set"
                
                // Display Only Fields:
                self.gender = user.user_gender ?? "Not Set"
                self.dateOfBirth = user.user_birthdate ?? Date()
                self.placeOfBirth = user.user_birthplace ?? "Not Set"
                
                // Editable Fields:
                self.placeOfResidence = user.user_residence ?? "Not Set"
                self.phoneNumber = user.user_hp ?? "Not Set"
                
                // Load KTM Image:
                if let imagePath = user.user_ktm_img, !imagePath.isEmpty {
                    self.ktmImagePath = imagePath // Store the path/URL
                    self.ktmImage = ImageLoaderUtility.loadImage(from: imagePath) // Load the image for preview
                } else {
                    self.ktmImagePath = nil
                    self.ktmImage = nil
                }
                
                // Load Interests
                if let interests = user.like_category as? Set<Category> {
                    self.selectedCategories = interests
                }
            }
        } catch {
            print("❌ Error fetch user: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Image Handling
    
    /// Called by the ImagePicker in the View when a new photo is selected.
    func didSelectNewImage(_ image: UIImage) {
        // 1. Update the UI preview
        self.ktmImage = image
        
        // 2. Save the image to the device/server and get the new path/URL
        // --- TODO: IMPLEMENT REAL IMAGE PERSISTENCE LOGIC HERE ---
        // Example: Save image to temp directory, get URL string, and store it:
        // let newPath = ImageLoaderUtility.saveImage(image)
        // self.ktmImagePath = newPath
        // ---------------------------------------------------------
        
        // Placeholder for saving the new path/URL string:
        self.ktmImagePath = "new_ktm_image_selected_\(UUID().uuidString)"
    }
    
    // MARK: - Other Logic Actions
    
    func toggleCategory(_ category: Category) {
        if selectedCategories.contains(category) {
            selectedCategories.remove(category)
        } else {
            if selectedCategories.count < 3 {
                selectedCategories.insert(category)
            } else {
                alertMessage = "You can only select up to 3 interests."
                showAlert = true
            }
        }
    }
    
    // Fungsi Simpan Perubahan
    func saveChanges() {
        guard let user = currentUser else { return }
        
        // 1. Update Editable Fields (Matching Core Data Attributes)
        user.user_name = fullName
        user.user_residence = placeOfResidence
        user.user_hp = phoneNumber
        
        // 2. Update KTM Image Path/URL
        // This saves the path string we stored in ktmImagePath (either the old path or the new one)
        user.user_ktm_img = ktmImagePath
        
        // 3. Update Kategori (Relationship Many-to-Many)
        user.like_category = selectedCategories as NSSet
        
        // 4. Commit ke Core Data
        do {
            try viewContext.save()
            print("✅ Profile Updated Successfully for \(fullName)")
        } catch {
            print("❌ Failed to save profile: \(error.localizedDescription)")
        }
    }
}


// MARK: - IMAGE UTILITY (Must be defined to resolve 'Cannot find')

struct ImageLoaderUtility {
    /// Placeholder function to convert a path/URL String into a UIImage.
    static func loadImage(from path: String?) -> UIImage? {
        guard let path = path, !path.isEmpty else { return nil }
        
        // --- TODO: IMPLEMENT REAL IMAGE LOADING LOGIC HERE ---
        // e.g., load image from local URL, cache, or network
        
        // Placeholder: Return a generic system image or a default image
        // If you have an image asset in your project named "default_ktm", use it:
        // return UIImage(named: "default_ktm")
        
        // Example to return a generic system symbol as a placeholder:
        let config = UIImage.SymbolConfiguration(pointSize: 100, weight: .regular, scale: .large)
        let placeholderImage = UIImage(systemName: "photo", withConfiguration: config)
        return placeholderImage
    }
    
    /// Placeholder function to save a UIImage and return its path/URL String.
    /// You will need to implement this when integrating the ImagePicker.
    static func saveImage(_ image: UIImage) -> String? {
        // --- TODO: IMPLEMENT REAL IMAGE SAVING LOGIC HERE ---
        // e.g., Save image to the application's document directory and return the file path.
        return "temporary_save_path/\(UUID().uuidString).jpg"
    }
}
