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
                            // FIX: Pengganti 'UIApplication.shared.windows' untuk iOS 15+
                            // Kita mencari 'WindowScene' yang sedang aktif, lalu mengambil window utamanya.
                            let keyWindow = UIApplication.shared.connectedScenes
                                .filter { $0.activationState == .foregroundActive }
                                .compactMap { $0 as? UIWindowScene }
                                .first?.windows
                                .filter { $0.isKeyWindow }.first
                            
                            // 1. Coba Dismiss (Jika halaman ini adalah Modal/Sheet)
                            keyWindow?.rootViewController?.dismiss(animated: true)
                            
                            // 2. Coba Pop To Root (Jika halaman ini adalah Navigation Push)
                            // Kita cari NavigationController di dalam root dan minta mundur ke awal
                            if let rootVC = keyWindow?.rootViewController {
                                // Mencari Navigation Controller secara rekursif sederhana
                                func findNav(vc: UIViewController) -> UINavigationController? {
                                    if let nav = vc as? UINavigationController { return nav }
                                    for child in vc.children {
                                        if let nav = findNav(vc: child) { return nav }
                                    }
                                    return nil
                                }
                                
                                if let nav = findNav(vc: rootVC) {
                                    nav.popToRootViewController(animated: true)
                                }
                            }
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
