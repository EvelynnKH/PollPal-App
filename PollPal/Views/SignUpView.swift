//
//  SignUpView.swift
//  PollPal
//
//  Created by student on 05/12/25.
//

import SwiftUI

struct SignUpView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var fullName = ""
    @State private var isPasswordVisible = false
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Spacer().frame(height: 30)
            // MARK: - Title
            Text("Sign Up")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(Color(hex: "1F3A45"))
            Text("Fill in your information below")
                .font(.system(size: 16))
                .foregroundColor(.gray)
            // MARK: - Email
            VStack(alignment: .leading, spacing: 8) {
                Text("Email Address")
                    .font(.subheadline.bold())
                    .foregroundColor(Color(hex: "1F3A45"))
                TextField("hello@example.com", text: $email)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
            }
            // MARK: - Password
            VStack(alignment: .leading, spacing: 8) {
                Text("Password")
                    .font(.subheadline.bold())
                    .foregroundColor(Color(hex: "1F3A45"))
                HStack {
                    if isPasswordVisible {
                        TextField("••••••••", text: $password)
                    } else {
                        SecureField("••••••••", text: $password)
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
                    .foregroundColor(Color(hex: "1F3A45"))
                TextField("Budi Budi", text: $fullName)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
            }
            // MARK: - Terms
            Text(
                "By Signing up, you agree to our **Terms & Conditions** and **Privacy Policy**."
            )
            .font(.system(size: 12))
            .foregroundColor(.gray)
            // MARK: - Button
            Button(action: {}) {
                Text("Sign Up")
                    .font(.system(.headline, weight: .bold))
                    .foregroundColor(.orange)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(hex: "1F3A45"))
                    .cornerRadius(16)
            }
            .padding(.top, 8)
            Spacer()
            // MARK: - Login link
            HStack {
                Text("Joined Us Before?")
                    .foregroundColor(Color(hex: "1F3A45"))
                NavigationLink(destination: LoginView()) {
                    Text("Login")
                        .font(.headline.bold())
                        .foregroundColor(Color(hex: "1F3A45"))
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.bottom, 20)
        }
        .padding(.horizontal, 24)
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    SignUpView()
}
