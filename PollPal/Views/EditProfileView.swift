//
//  EditProfileView.swift
//  PollPal
//
//  Created by student on 08/12/25.
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
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            
            // MARK: - CUSTOM HEADER (Manual Title)
            // Ini menggantikan Navigation Title standar
            VStack(alignment: .leading, spacing: 5) {
                Text("Edit Profile") // Teks saya sesuaikan konteks
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(darkTeal)
                
                Text("Update your personal details")
                    .foregroundColor(darkTeal.opacity(0.7))
            }
            .padding(.top, 20)
            
            // MARK: - FULL NAME FIELD
            VStack(alignment: .leading, spacing: 6) {
                Text("Full Name")
                    .font(.subheadline.bold())
                    .foregroundColor(darkTeal)
                
                TextField("Enter your full name", text: $viewModel.fullName)
                    .padding()
                    .background(inputBg)
                    .cornerRadius(12)
                    .foregroundColor(.black)
                    .tint(darkTeal)
            }
            
            // MARK: - INTERESTS SECTION
            VStack(alignment: .leading, spacing: 10) {
                Text("Interests")
                    .font(.subheadline.bold())
                    .foregroundColor(darkTeal)
                
                Text("Select categories you are interested in")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                // List Kategori Custom
                ScrollView {
                    VStack(spacing: 10) {
                        if viewModel.allCategories.isEmpty {
                            Text("No categories available")
                                .font(.caption)
                                .foregroundColor(.gray)
                                .padding()
                        } else {
                            ForEach(viewModel.allCategories, id: \.self) { category in
                                CategoryRowItem(
                                    title: category.category_name ?? "Unknown",
                                    isSelected: viewModel.selectedCategories.contains(category),
                                    darkTeal: darkTeal,
                                    brandOrange: brandOrange,
                                    inputBg: inputBg
                                )
                                .onTapGesture {
                                    viewModel.toggleCategory(category)
                                }
                            }
                        }
                    }
                }
                .frame(maxHeight: .infinity)
            }
            
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
            }
            .padding(.bottom, 10)
        }
        .padding(.horizontal, 30) // Padding kiri-kanan untuk seluruh halaman
        .onAppear {
            viewModel.fetchData()
        }
        // Hapus Navigation Title bawaan agar tidak double
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

#Preview {
    let context = PersistenceController.shared.container.viewContext
    NavigationStack {
        EditProfileView(context: context)
    }
}
