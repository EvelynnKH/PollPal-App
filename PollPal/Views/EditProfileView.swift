//
//  EditProfileView.swift
//  PollPal
//
//  Created by student on 08/12/25.
//

import SwiftUI
import CoreData

struct EditProfileView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel: EditProfileViewModel
    
    init(context: NSManagedObjectContext) {
        _viewModel = StateObject(wrappedValue: EditProfileViewModel(context: context))
    }
    
    // Colors
    let darkTeal = Color(hex: "0C4254")
    let brandOrange = Color(hex: "FE982A")
    let inputBg = Color.gray.opacity(0.15)
    
    private var shortDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        // Set the format to force DD/MM/YYYY or MM/DD/YYYY numeric look
        formatter.dateStyle = .short // e.g., 11/5/25
        return formatter
    }
    
    var body: some View {
        ScrollView { // Wrap in ScrollView to handle content overflow
            VStack(alignment: .leading, spacing: 15) {
                
                // MARK: - CUSTOM HEADER (Manual Title)
                VStack(alignment: .leading, spacing: 5) {
                    Text("Edit Profile")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(darkTeal)
                    
                    Text("Update your personal details")
                        .foregroundColor(darkTeal.opacity(0.7))
                }
                .padding(.top, 20)
                
                // MARK: - FULL NAME FIELD (Editable)
                InputLabel(title: "Full Name", darkTeal: darkTeal)
                                // 🚨 Change from TextField to Text wrapped in the input style
                                Text(viewModel.fullName)
                                    .frame(maxWidth: .infinity, alignment: .leading) // Ensure it fills the width
                                    // Apply input style using manual modifiers for display
                                    .padding()
                                    .background(inputBg)// Use opacity to show it's disabled
                                    .cornerRadius(12)
                                    .foregroundColor(.gray)
                
                // --- START NEW DEMOGRAPHIC SECTION ---
                
                // MARK: - DEMOGRAPHIC ROW 1: GENDER & TANGGAL LAHIR (Display Only)
                HStack(spacing: 20) {
                    // GENDER (Left Half) - Remains the same, using inputStyle
                    VStack(alignment: .leading, spacing: 6) {
                        InputLabel(title: "Gender", darkTeal: darkTeal)
                        Menu {
                            // ...
                        } label: {
                            HStack {
                                Text(viewModel.gender)
                                    .foregroundColor(.gray)
                                Spacer()
                            }
                        }
                        .inputStyle(background: inputBg, cornerRadius: 12, tint: darkTeal)
                        .disabled(true)
                    }
                    .frame(maxWidth: .infinity) // Ensures Gender takes half the space
                    
                    // TANGGAL LAHIR (Right Half) - Custom Styling
                    VStack(alignment: .leading, spacing: 6) {
                        InputLabel(title: "Date of Birth", darkTeal: darkTeal)
                        
                        // 🚨 FIX: Using a formatter to force the numeric short date style
                        Text(viewModel.dateOfBirth, formatter: shortDateFormatter)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            
                            // Explicitly set foreground style to gray
                            .foregroundStyle(.gray)
                            
                            // Apply input field styling manually
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(inputBg)
                            )
                    }
                    .frame(maxWidth: .infinity)// Ensures Date of Birth takes the other half
                }
                
                // MARK: - PLACE OF BIRTH (Display Only)
                InputLabel(title: "Place of Birth", darkTeal: darkTeal)

                // 🚨 REPLACED TextField with Text view for controlled display
                Text(viewModel.placeOfResidence)
                    .frame(maxWidth: .infinity, alignment: .leading) // Ensure it fills the width
                    
                    // 1. Explicitly set foreground style to gray
                    .foregroundStyle(.gray)
                    
                    // 2. Apply input field styling manually
                    .padding() // Using .padding() to match other input fields
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(inputBg) // Use the consistent inputBg color
                    )
                
//                // MARK: - PLACE OF RESIDENCE (Editable)
//                InputLabel(title: "Place of Residence", darkTeal: darkTeal)
//                TextField("Enter your place of residence", text: $viewModel.placeOfResidence)
//                    .foregroundStyle(.black)
//                    .inputStyle(background: inputBg, cornerRadius: 12, tint: darkTeal)
                
                // MARK: - PHONE NUMBER (Editable)
                InputLabel(title: "Phone Number", darkTeal: darkTeal)
                TextField("Enter your phone number", text: $viewModel.phoneNumber)
                    .keyboardType(.numberPad)
                    .foregroundStyle(.black)
                    .inputStyle(background: inputBg, cornerRadius: 12, tint: darkTeal)
                
                // MARK: - UPLOAD KTM (Display/Preview Only)
                
                // --- END NEW DEMOGRAPHIC SECTION ---
                
                
                // MARK: - INTERESTS SECTION
//                VStack(alignment: .leading, spacing: 10) {
//                    InputLabel(title: "Interests", darkTeal: darkTeal)
//                    
//                    Text("Select categories you are interested in")
//                        .font(.caption)
//                        .foregroundColor(.gray)
//                    
//                    // List Kategori Custom
//                    ScrollView {
//                        VStack(spacing: 10) {
//                            // ... (Existing category list logic) ...
//                            if viewModel.allCategories.isEmpty {
//                                Text("No categories available")
//                                    .font(.caption)
//                                    .foregroundColor(.gray)
//                                    .padding()
//                            } else {
//                                ForEach(viewModel.allCategories, id: \.self) { category in
//                                    CategoryRowItem(
//                                        title: category.category_name ?? "Unknown",
//                                        isSelected: viewModel.selectedCategories.contains(category),
//                                        darkTeal: darkTeal,
//                                        brandOrange: brandOrange,
//                                        inputBg: inputBg
//                                    )
//                                    .onTapGesture {
//                                        viewModel.toggleCategory(category)
//                                    }
//                                }
//                            }
//                        }
//                    }
//                    .frame(maxHeight: 250) // Constrain height for ScrollView
//                }
                
                // MARK: - SAVE BUTTON
                Button(action: {
                    viewModel.saveChanges()
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Save Changes")
                        .font(.headline.bold())
                        .foregroundColor(brandOrange)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(darkTeal)
                        .cornerRadius(16)
                        .padding(.top, 10)
                }
                .padding(.bottom, 10)
            }
            .padding(.horizontal, 30) // Padding kiri-kanan untuk seluruh halaman
            .onAppear {
                viewModel.fetchData()
            }
            .navigationBarTitle("", displayMode: .inline)
            .alert(isPresented: $viewModel.showAlert) {
                Alert(
                    title: Text("Limit Reached"),
                    message: Text(viewModel.alertMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
}

// MARK: - SUBVIEW: Category Row (Tidak Berubah)

struct CategoryRowItem: View {
    
    let title: String
    let isSelected: Bool
    let darkTeal: Color
    let brandOrange: Color
    let inputBg: Color
    
    
    var body: some View {
        
        HStack {
            
            Text(title)
            
                .font(.body)
            
                .fontWeight(.medium)
            
                .foregroundColor(isSelected ? darkTeal : .gray)
            
            
            
            Spacer()
            
            
            
            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
            
                .font(.title3)
            
                .foregroundColor(isSelected ? brandOrange : .gray)
            
        }
        
        .padding()
        
        .background(
            
            RoundedRectangle(cornerRadius: 12)
            
                .fill(isSelected ? brandOrange.opacity(0.1) : inputBg)
            
                .overlay(
                    
                    RoundedRectangle(cornerRadius: 12)
                    
                        .stroke(isSelected ? brandOrange : Color.clear, lineWidth: 1)
                    
                )
            
        )
        
    }
    
}

// Helper for input titles
struct InputLabel: View {
    let title: String
    let darkTeal: Color
    
    var body: some View {
        Text(title)
            .font(.subheadline.bold())
            .foregroundColor(darkTeal)
            .padding(.top, 10)
    }
}

// Helper for consistent input field styling
extension View {
    func inputStyle(background: Color, cornerRadius: CGFloat, tint: Color) -> some View {
        self.padding()
            .background(background)
            .cornerRadius(cornerRadius)
            .foregroundColor(.black)
            .tint(tint)
    }
}

// MARK: - SUBVIEW: Category Row (No Change)
// ... (Your existing CategoryRowItem struct remains here) ...

#Preview {
    // You need to ensure PersistenceController.shared.container.viewContext is available
    let context = PersistenceController.shared.container.viewContext
    NavigationStack {
        EditProfileView(context: context)
    }
}
