//
//  SignUpView.swift
//  PollPal
//
//  Created by student on 05/12/25.
//

import SwiftUI

struct SignUpView: View {
    // 1. Hubungkan ViewModel & Context
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var viewModel: SignUpViewModel
    
    // State UI Lokal (hanya untuk mata/password visibility)
    @State private var isPasswordVisible = false
    
    init() {
        // Init ViewModel dengan context sementara (akan di-inject via onAppear/Environment di app flow nyata)
        // Cara aman untuk StateObject di init:
        let context = PersistenceController.shared.container.viewContext
        _viewModel = StateObject(wrappedValue: SignUpViewModel(context: context))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Spacer().frame(height: 30)
            
            // MARK: - Title
            Text("Sign Up")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(Color(hex: "0C4254"))
            Text("Fill in your information below")
                .font(.system(size: 16))
                .foregroundColor(.gray)
            
            // MARK: - Email
            VStack(alignment: .leading, spacing: 8) {
                Text("Email Address")
                    .font(.subheadline.bold())
                    .foregroundColor(Color(hex: "0C4254"))
                
                // Binding ke viewModel.email
                TextField("Enter your email address", text: $viewModel.email)
                    .padding()
                    .background(Color.gray.opacity(0.15))
                    .cornerRadius(12)
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                    .foregroundColor(.black)
            }
            
            // MARK: - Password
            VStack(alignment: .leading, spacing: 8) {
                Text("Password")
                    .font(.subheadline.bold())
                    .foregroundColor(Color(hex: "0C4254"))
                HStack {
                    // Binding ke viewModel.password
                    if isPasswordVisible {
                        TextField("Enter your password", text: $viewModel.password)
                    } else {
                        SecureField("Enter your password", text: $viewModel.password)
                    }
                    Button(action: { isPasswordVisible.toggle() }) {
                        Image(
                            systemName: isPasswordVisible ? "eye.slash" : "eye"
                        )
                        .foregroundColor(.gray)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
            }
            
            // MARK: - Full Name
            VStack(alignment: .leading, spacing: 8) {
                Text("Full Name")
                    .font(.subheadline.bold())
                    .foregroundColor(Color(hex: "0C4254"))
                
                // Binding ke viewModel.fullName
                TextField("Enter your full name", text: $viewModel.fullName)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
            }
            
            // MARK: - Terms
            Text(
                "By signing up, you agree to our **Terms & Conditions** and **Privacy Policy**."
            )
            .font(.system(size: 12))
            .foregroundColor(.gray)
            
            // MARK: - Button Register
            Button(action: {
                // Panggil fungsi register di ViewModel
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
            
            // MARK: - Navigation Link (Otomatis ke Dashboard jika sukses)
            // Ini trik untuk pindah halaman secara programmatik
            .navigationDestination(isPresented: $viewModel.isRegistered) {
                DashboardRView(context: viewContext)
                    .navigationBarBackButtonHidden(true) // Supaya gak bisa back ke Sign up
            }
            
            Spacer()
            
            // MARK: - Login link
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
        .padding(.horizontal, 24)
        .navigationBarBackButtonHidden(true)
        // Alert Error
        .alert(isPresented: $viewModel.showError) {
            Alert(title: Text("Warning"), message: Text(viewModel.errorMessage), dismissButton: .default(Text("OK")))
        }
    }
}
