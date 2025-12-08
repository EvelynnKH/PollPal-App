//
//  ResetPasswordView.swift
//  PollPal
//
//  Created by student on 08/12/25.
//

import SwiftUI

// MARK: - Reset Password View
struct ResetPasswordView: View {
    // 1. Terima Email dari halaman sebelumnya
    let targetEmail: String
    
    // 2. Hubungkan ViewModel
    @StateObject private var viewModel: ResetPasswordViewModel
    
    // Custom Init untuk menyuntikkan email ke ViewModel
    init(targetEmail: String) {
        self.targetEmail = targetEmail
        let context = PersistenceController.shared.container.viewContext
        _viewModel = StateObject(wrappedValue: ResetPasswordViewModel(context: context, email: targetEmail))
    }
    
    // State lokal untuk visibilitas (UI only)
    @State private var isNewPasswordVisible = false
    @State private var isConfirmPasswordVisible = false
    
    var body: some View {
        ZStack {
            Color.white.edgesIgnoringSafeArea(.all)
            
            VStack(alignment: .leading, spacing: 30) {
                
                // MARK: Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Reset Password")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(Color(hex:"0C4254"))
                    
                    Text("Set new password for \(targetEmail)") // Tampilkan email agar user yakin
                        .font(.body)
                        .foregroundColor(.gray)
                }
                
                // MARK: New Password Input
                VStack(alignment: .leading, spacing: 10) {
                    Text("Enter New Password")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(Color(hex:"0C4254"))
                    
                    CustomSecureField(text: $viewModel.newPassword, isVisible: $isNewPasswordVisible)
                }
                
                // MARK: Confirm New Password Input
                VStack(alignment: .leading, spacing: 10) {
                    Text("Confirm New Password")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(Color(hex:"0C4254"))
                    
                    CustomSecureField(text: $viewModel.confirmPassword, isVisible: $isConfirmPasswordVisible)
                }
                
                // MARK: Submit Button
                Button(action: {
                    viewModel.resetPassword()
                }) {
                    Text("Submit")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(Color(hex:"FE982A"))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(Color(hex:"0C4254"))
                        .cornerRadius(18)
                }
                
                Spacer()
            }
            .padding(.horizontal, 30)
            .padding(.top, 50)
            
            // MARK: - Navigation Success
            // Jika sukses, lempar user kembali ke LoginView
            .navigationDestination(isPresented: $viewModel.isSuccess) {
                LoginView()
                    .navigationBarBackButtonHidden(true) // Cegah user back ke halaman reset
            }
        }
        // Alert Error
        .alert(isPresented: $viewModel.showError) {
            Alert(title: Text("Error"), message: Text(viewModel.errorMessage), dismissButton: .default(Text("OK")))
        }
    }
}

// MARK: - Custom Secure Field (Helper Tetap Sama)
struct CustomSecureField: View {
    @Binding var text: String
    @Binding var isVisible: Bool
    
    var body: some View {
        HStack {
            if isVisible {
                TextField("Enter your password", text: $text)
            } else {
                SecureField("Enter your password", text: $text)
            }
            
            Button(action: {
                isVisible.toggle()
            }) {
                Image(systemName: isVisible ? "eye.slash.fill" : "eye.fill")
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}
