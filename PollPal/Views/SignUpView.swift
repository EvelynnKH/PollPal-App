//
//  SignUpView.swift
//  PollPal
//
//  Created by student on 05/12/25.
//

import SwiftUI

struct SignUpView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var viewModel: SignUpViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var isPasswordVisible = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Spacer atas dikurangi sedikit biar tidak terlalu turun
            Spacer().frame(height: 20)
            
            // Header
            VStack(alignment: .leading, spacing: 8) {
                Text("Set Credentials")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(Color(hex: "0C4254"))
                Text("Create your account login details")
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
            }
            
            // Email Input
            VStack(alignment: .leading, spacing: 8) {
                Text("Email Address")
                    .font(.subheadline.bold())
                    .foregroundColor(Color(hex: "0C4254"))
                TextField("Enter your email address", text: $viewModel.email)
                    .padding()
                    .background(Color.gray.opacity(0.15))
                    .cornerRadius(12)
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                    .foregroundColor(.black)
            }
            
            // Password Input
            VStack(alignment: .leading, spacing: 8) {
                Text("Password")
                    .font(.subheadline.bold())
                    .foregroundColor(Color(hex: "0C4254"))
                HStack {
                    if isPasswordVisible {
                        TextField("Enter your password", text: $viewModel.password)
                    } else {
                        SecureField("Enter your password", text: $viewModel.password)
                    }
                    Button(action: { isPasswordVisible.toggle() }) {
                        Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                            .foregroundColor(.gray)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
            }
            
            // Terms
            Text("By signing up, you agree to our **Terms & Conditions**.")
                .font(.system(size: 12))
                .foregroundColor(.gray)
            
            // Button SIGN UP
            Button(action: {
                viewModel.registerUser()
            }) {
                Text("Sign Up")
                    .font(.system(.headline, weight: .bold))
                    .foregroundColor(Color(hex: "FE982A"))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(hex: "0C4254"))
                    .cornerRadius(16)
            }
            .padding(.top, 8)
            
            Spacer()
            
            // MARK: - Login Link
            HStack {
                Text("Joined Us Before?")
                    .foregroundColor(Color(hex: "0C4254"))
                NavigationLink(destination: LoginView()) {
                    Text("Login")
                        .font(.headline.bold())
                        .foregroundColor(Color(hex: "0C4254"))
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.bottom, 20)
        }
        
        .padding(.horizontal, 20)
        
        .navigationBarBackButtonHidden(true)
        
        // DESTINATION HANDLER (Pindah ke root modifiers)
        .navigationDestination(isPresented: $viewModel.isRegistered) {
            DashboardRView(context: viewContext)
                .navigationBarBackButtonHidden(true)
        }
        
        // ERROR ALERT (Hanya satu kali di root)
        .alert(isPresented: $viewModel.showError) {
            Alert(
                title: Text("Warning"),
                message: Text(viewModel.errorMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}
