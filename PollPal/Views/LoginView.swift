//
//  LoginView.swift
//  PollPal
//
//  Created by student on 05/12/25.
//

import SwiftUI

struct LoginView: View {
    // 1. Hubungkan ViewModel
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var viewModel: LoginViewModel
    
    // State lokal hanya untuk visibilitas password
    @State private var isPasswordHidden: Bool = true
    
    init() {
        let context = PersistenceController.shared.container.viewContext
        _viewModel = StateObject(wrappedValue: LoginViewModel(context: context))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Spacer().frame(height: 30)
            
            // MARK: - TITLE
            Text("Login")
                .font(.largeTitle.bold())
                .foregroundColor(Color(hex: "0C4254"))
            Text("Welcome back to the app")
                .foregroundColor(Color(hex: "0C4254").opacity(0.7))
            
            // MARK: - EMAIL FIELD
            VStack(alignment: .leading, spacing: 6) {
                Text("Email Address")
                    .font(.subheadline.bold())
                    .foregroundColor(Color(hex: "0C4254"))
                
                // Binding ke viewModel
                TextField("Enter your email address", text: $viewModel.email)
                    .padding()
                    .background(Color.gray.opacity(0.15))
                    .cornerRadius(12)
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                    .foregroundColor(.black)
            }
            
            // MARK: - PASSWORD FIELD
            VStack(alignment: .leading, spacing: 6) {
                Text("Password")
                    .font(.subheadline.bold())
                    .foregroundColor(Color(hex: "0C4254"))
                
                HStack {
                    // Binding ke viewModel
                    if isPasswordHidden {
                        SecureField("Enter your password", text: $viewModel.password)
                    } else {
                        TextField("Enter your password", text: $viewModel.password)
                    }
                    
                    Button(action: {
                        isPasswordHidden.toggle()
                    }) {
                        Image(
                            systemName: isPasswordHidden ? "eye.slash" : "eye"
                        )
                        .foregroundColor(Color(hex: "0C4254"))
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.15))
                .cornerRadius(12)
            }
            
            // MARK: - FORGOT PASSWORD
            HStack {
                Spacer()
                NavigationLink(destination: ForgotPasswordView()) {
                                    Text("Forgot Password?")
                                        .font(.footnote.bold())
                                        .foregroundColor(Color(hex: "0C4254"))
                                }
            }
            
            // MARK: - LOGIN BUTTON
            Button(action: {
                // Panggil fungsi login di ViewModel
                viewModel.login()
            }) {
                Text("Login")
                    .font(.headline.bold())
                    .foregroundColor(Color(hex: "FE982A"))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(hex: "0C4254"))
                    .cornerRadius(16)
            }
            .padding(.top, 10)
            
            // MARK: - NAVIGASI OTOMATIS KE DASHBOARD
            .navigationDestination(isPresented: $viewModel.isLoggedIn) {
                DashboardRView(context: viewContext)
                    .navigationBarBackButtonHidden(true) // Supaya gak bisa back ke Login
            }
            
            Spacer()
            
            // MARK: - SIGNUP TEXT
            HStack {
                Spacer()
                Text("Don’t have an account?")
                    .foregroundColor(Color(hex: "0C4254"))
                NavigationLink(destination: SignUpView()) {
                    Text("Sign Up")
                        .font(.headline.bold())
                        .foregroundColor(Color(hex: "0C4254"))
                }
                Spacer()
            }
            .padding(.bottom)
        }
        .padding(.horizontal, 30)
        .navigationBarBackButtonHidden(true)
        // Alert Error
        .alert(isPresented: $viewModel.showError) {
            Alert(title: Text("Login Failed"), message: Text(viewModel.errorMessage), dismissButton: .default(Text("OK")))
        }
    }
}

#Preview {
    LoginView()
}
