//
//  LoginView.swift
//  PollPal
//
//  Created by student on 05/12/25.
//

import SwiftUI

struct LoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isPasswordHidden: Bool = true
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Spacer().frame(height: 30)
            // MARK: - TITLE
            Text("Login")
                .font(.largeTitle.bold())
                .foregroundColor(Color(hex: "1F3A45"))
            Text("Welcome back to the app")
                .foregroundColor(Color(hex: "1F3A45").opacity(0.7))
            // MARK: - EMAIL FIELD
            VStack(alignment: .leading, spacing: 6) {
                Text("Email Address")
                    .font(.subheadline.bold())
                    .foregroundColor(Color(hex: "1F3A45"))
                TextField("hello@example.com", text: $email)
                    .padding()
                    .background(Color.gray.opacity(0.15))
                    .cornerRadius(12)
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
            }
            // MARK: - PASSWORD FIELD
            VStack(alignment: .leading, spacing: 6) {
                Text("Password")
                    .font(.subheadline.bold())
                    .foregroundColor(Color(hex: "1F3A45"))
                HStack {
                    if isPasswordHidden {
                        SecureField(".................", text: $password)
                    } else {
                        TextField("Password", text: $password)
                    }
                    Button(action: {
                        isPasswordHidden.toggle()
                    }) {
                        Image(
                            systemName: isPasswordHidden ? "eye.slash" : "eye"
                        )
                        .foregroundColor(Color(hex: "1F3A45"))
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.15))
                .cornerRadius(12)
            }
            // MARK: - FORGOT PASSWORD
            HStack {
                Spacer()
                Button("Forget Password?") {}
                    .font(.footnote.bold())
                    .foregroundColor(Color(hex: "1F3A45"))
            }
            // MARK: - LOGIN BUTTON
            Button(action: {}) {
                Text("Login")
                    .font(.headline.bold())
                    .foregroundColor(.orange)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(hex: "1F3A45"))
                    .cornerRadius(16)
            }
            .padding(.top, 10)
            Spacer()
            // MARK: - SIGNUP TEXT
            HStack {
                Spacer()
                Text("Don’t have an account?")
                    .foregroundColor(Color(hex: "1F3A45"))
                NavigationLink(destination: SignUpView()) {
                    Text("Sign Up")
                        .font(.headline.bold())
                        .foregroundColor(Color(hex: "1F3A45"))
                }
                Spacer()
            }
            .padding(.bottom)
        }
        .padding(.horizontal, 30)
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    LoginView()
}
