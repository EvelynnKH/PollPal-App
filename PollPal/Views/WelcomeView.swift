//
//  WelcomeView.swift
//  PollPal
//
//  Created by student on 05/12/25.
//

import SwiftUI

struct WelcomeView: View {
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            // MARK: - LOGO
            Circle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 220, height: 220)
                .overlay(
                    Text("Logo")
                        .font(.title2.bold())
                        .foregroundColor(.black.opacity(0.6))
                )
            // MARK: - TEXT
            VStack(spacing: 10) {
                Text("Welcome to PollPal !")
                    .font(.largeTitle.bold())
                    .foregroundColor(Color(hex: "1F3A45"))
                Text(
                    "Find Respondents, Build Surveys, Earn Money! All in One Reliable App."
                )
                .font(.subheadline)
                .foregroundColor(Color(hex: "1F3A45").opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            }
            // MARK: - LOGIN BUTTON
            //            NavigationLink(destination: LoginView()) {
            //                Text("Login")
            //                    .font(.headline.bold())
            //                    .foregroundColor(.white)
            //                    .frame(maxWidth: .infinity)
            //                    .padding()
            //                    .background(Color(hex: "1F3A45"))
            //                    .cornerRadius(16)
            //                    .padding(.horizontal, 40)
            //            }
            NavigationStack {
                // isi welcome
                NavigationLink(destination: LoginView()) {
                    Text("Login")
                        .font(.headline.bold())
                        .foregroundColor(.orange)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(hex: "1F3A45"))
                        .cornerRadius(16)
                        .padding(.horizontal, 35)
                }
            }
            // MARK: - SIGNUP TEXT
            VStack(spacing: 8) {
                Text("Don’t have an account?")
                    .foregroundColor(Color(hex: "1F3A45"))

                NavigationLink(destination: SignUpView()) {
                    Text("Sign Up")
                        .font(.headline.bold())
                        .foregroundColor(Color(hex: "1F3A45"))
                }
            }
            Spacer()
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    WelcomeView()
}
