//
//  ChangePasswordView.swift
//  PollPal
//
//  Created by student on 08/12/25.
//

import SwiftUI
import CoreData

struct ChangePasswordView: View {
    // Environment untuk menutup halaman (Dismiss) setelah sukses
    @Environment(\.presentationMode) var presentationMode
    
    @StateObject private var viewModel: ChangePasswordViewModel
    
    // Init Context
    init(context: NSManagedObjectContext) {
        _viewModel = StateObject(wrappedValue: ChangePasswordViewModel(context: context))
    }
    
    // Visibility States
    @State private var isCurrentVisible = false
    @State private var isNewVisible = false
    @State private var isConfirmVisible = false
    
    // Colors
    let darkTeal = Color(hex: "0C4254")
    let brandOrange = Color(hex: "FE982A")
    
    var body: some View {
        ZStack {
            Color.white.edgesIgnoringSafeArea(.all)
            
            ScrollView { // Pakai ScrollView jaga-jaga kalau layar kecil
                VStack(alignment: .leading, spacing: 25) {
                    
                    // MARK: Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Change Password")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(darkTeal)
                        
                        Text("Your new password must be different from previous used passwords.")
                            .font(.body)
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 20)
                    
                    // MARK: Current Password (WAJIB ADA)
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Current Password")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(darkTeal)
                        
                        CustomSecureFieldPass(text: $viewModel.currentPassword, isVisible: $isCurrentVisible, placeholder: "Enter current password")
                    }
                    
                    Divider().padding(.vertical, 5)
                    
                    // MARK: New Password
                    VStack(alignment: .leading, spacing: 10) {
                        Text("New Password")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(darkTeal)
                        
                        CustomSecureFieldPass(text: $viewModel.newPassword, isVisible: $isNewVisible, placeholder: "Enter new password")
                    }
                    
                    // MARK: Confirm Password
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Confirm New Password")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(darkTeal)
                        
                        CustomSecureFieldPass(text: $viewModel.confirmPassword, isVisible: $isConfirmVisible, placeholder: "Re-enter new password")
                    }
                    
                    // MARK: Save Button
                    Button(action: {
                        viewModel.changePassword()
                    }) {
                        Text("Save Changes")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(brandOrange)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(darkTeal)
                            .cornerRadius(18)
                    }
                    .padding(.top, 20)
                    
                }
                .padding(.horizontal, 30)
            }
        }
        // Handle Alert Error
        .alert(isPresented: $viewModel.showAlert) {
            Alert(title: Text("Error"), message: Text(viewModel.alertMessage), dismissButton: .default(Text("OK")))
        }
        // Handle Success -> Tutup Halaman
        .onChange(of: viewModel.isSuccess) { success in
            if success {
                presentationMode.wrappedValue.dismiss()
            }
        }
        // Untuk iOS 16 ke bawah (jika onChange diatas error), gunakan ini:
        /*
        .onReceive(viewModel.$isSuccess) { success in
            if success { presentationMode.wrappedValue.dismiss() }
        }
        */
    }
}

// MARK: - Reusable Custom Secure Field
struct CustomSecureFieldPass: View {
    @Binding var text: String
    @Binding var isVisible: Bool
    
    // Tambahkan properti ini dengan nilai default
    // Nilai default penting agar ResetPasswordView (yang tidak kirim placeholder) tidak error
    var placeholder: String = "Enter password"
    
    var body: some View {
        HStack {
            if isVisible {
                // Gunakan variable placeholder disini
                TextField(placeholder, text: $text)
                    .autocapitalization(.none)
            } else {
                // Gunakan variable placeholder disini
                SecureField(placeholder, text: $text)
            }
            
            Button(action: {
                isVisible.toggle()
            }) {
                Image(systemName: isVisible ? "eye.slash.fill" : "eye.fill")
                    .foregroundColor(Color(hex: "0C4254"))
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}
