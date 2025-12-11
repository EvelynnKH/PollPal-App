//
//  WelcomeView.swift
//  PollPal
//
//  Created by student on 05/12/25.
//

import SwiftUI
import CoreData // 1. Wajib import ini

struct WelcomeView: View {
    // 2. Ambil context dari Environment
    @Environment(\.managedObjectContext) private var viewContext
    
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
                Text("Welcome to PollPal!")
                    .font(.largeTitle.bold())
                    .foregroundColor(Color(hex: "0C4254"))
                Text("Find Respondents, Build Surveys, Earn Money! All in One Reliable App.")
                    .font(.subheadline)
                    .foregroundColor(Color(hex: "0C4254").opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            // MARK: - LOGIN BUTTON
            // 3. Hapus NavigationStack disini! Cukup langsung NavigationLink
            NavigationLink(destination: LoginView()) {
                Text("Login")
                    .font(.headline.bold())
                    .foregroundColor(Color(hex: "FE982A"))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(hex: "0C4254"))
                    .cornerRadius(16)
                    .padding(.horizontal, 35)
            }
            
            // MARK: - SIGNUP TEXT
            VStack(spacing: 8) {
                Text("Don’t have an account?")
                    .foregroundColor(Color(hex: "0C4254"))
                
                // 4. Masukkan parameter context disini
                NavigationLink(destination: SignUpPersonalView(context: viewContext)) {
                    Text("Sign Up")
                        .font(.headline.bold())
                        .foregroundColor(Color(hex: "0C4254"))
                }
            }
            
            Spacer()
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    // Inject context untuk preview agar tidak crash
    let context = PersistenceController.shared.container.viewContext
    WelcomeView()
        .environment(\.managedObjectContext, context)
}
