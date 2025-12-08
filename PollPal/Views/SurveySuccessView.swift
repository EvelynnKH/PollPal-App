//
//  SurveySuccessView.swift
//  PollPal
//
//  Created by student on 08/12/25.
//

import SwiftUI

struct SurveySuccessView: View {
    let pointsEarned: Int
    
    // Colors
    let darkTeal = Color(hex: "0C4254")
    let brandOrange = Color(hex: "FE982A")
    
    // Untuk kembali ke Root (Dashboard)
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // Success Illustration (Menggunakan Shape SwiftUI mirip gambar)
            ZStack {
                // Blob shape background (disederhanakan)
                Circle()
                    .fill(darkTeal.opacity(0.1))
                    .frame(width: 250, height: 250)
                    .overlay(
                        Circle()
                            .fill(darkTeal.opacity(0.1))
                            .frame(width: 180, height: 180)
                            .offset(x: -40, y: -40)
                    )
                
                // Checkmark Icon
                Circle()
                    .fill(darkTeal)
                    .frame(width: 120, height: 120)
                    .overlay(
                        Image(systemName: "checkmark")
                            .font(.system(size: 60, weight: .bold))
                            .foregroundColor(.white)
                    )
            }
            
            // Text Info
            VStack(spacing: 10) {
                Text("Survey Submitted!")
                    .font(.title.bold())
                    .foregroundColor(darkTeal)
                
                Text("+\(pointsEarned) Points")
                    .font(.title2.bold())
                    .foregroundColor(brandOrange)
                
                Text("Thanks for your participation.\nPoints have been added to your wallet.")
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.top, 5)
            }
            
            Spacer()
            
            // OK Button (Back to Dashboard)
            Button(action: {
                // Trik untuk kembali ke root view di NavigationStack
                // Ini akan menutup semua view yang di-push sebelumnya
                UIApplication.shared.windows.first?.rootViewController?.dismiss(animated: true)
            }) {
                Text("OK")
                    .font(.headline.bold())
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(darkTeal)
                    .cornerRadius(16)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 30)
        }
        .navigationBarBackButtonHidden(true) // Sembunyikan tombol back di halaman sukses
    }
}
