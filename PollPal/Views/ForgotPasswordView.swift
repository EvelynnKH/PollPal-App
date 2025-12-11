//
//  ForgotPasswordView.swift
//  PollPal
//
//  Created by student on 05/12/25.
//

import SwiftUI

// MARK: - Forgot Password View
struct ForgotPasswordView: View {
    // 1. Hubungkan ViewModel
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var viewModel: ForgotPasswordViewModel
    
    // Environment untuk tombol Back (Opsional, jika mau tombol back custom)
    @Environment(\.presentationMode) var presentationMode
    
    init() {
        let context = PersistenceController.shared.container.viewContext
        _viewModel = StateObject(wrappedValue: ForgotPasswordViewModel(context: context))
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.white.edgesIgnoringSafeArea(.all)
                
                VStack(alignment: .leading, spacing: 40) {
                    
                    // MARK: Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Forgot Password")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(Color(hex: "0C4254")) // Dark Teal
                        
                        Text("Enter your email address used")
                            .font(.body)
                            .foregroundColor(.gray)
                    }
                    
                    // MARK: Email Input
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Email Address")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(Color(hex: "0C4254"))
                        
                        // Binding ke ViewModel
                        TextField("Enter your email address", text: $viewModel.email)
                            .padding()
                            .background(Color.gray.opacity(0.15))
                            .cornerRadius(12)
                            .autocapitalization(.none)
                            .keyboardType(.emailAddress)
                            .foregroundColor(.black)
                    }
                    
                    // MARK: Send Code Button
                    Button(action: {
                        // Panggil fungsi di ViewModel
                        viewModel.sendCode()
                    }) {
                        Text("Send Code")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(Color(hex: "FE982A")) // Brand Orange
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(Color(hex: "0C4254")) // Dark Teal
                            .cornerRadius(18)
                    }
                    
                    Spacer()
                    
                    // MARK: Sign Up Link
                    VStack {
                        Text("Don't have an account?")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        NavigationLink(destination: SignUpPersonalView(context: viewContext)) {
                            Text("Sign Up")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(Color(hex: "0C4254"))
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 20)
                }
                .padding(.horizontal, 30)
                .padding(.top, 50)
                
                // MARK: - NAVIGASI JIKA SUKSES
                // Jika email ditemukan, pindah ke layar Verification/Reset Password
                .navigationDestination(isPresented: $viewModel.navigateToVerify) {
                    VerificationView(email: viewModel.email)
                            .navigationBarBackButtonHidden(false)
                }
            }
            // Alert Error jika email tidak ketemu
            .alert(isPresented: $viewModel.showError) {
                Alert(title: Text("Error"), message: Text(viewModel.errorMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
}

#Preview {
    ForgotPasswordView()
}
