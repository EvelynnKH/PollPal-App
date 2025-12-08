//
//  VerificationViewModel.swift
//  PollPal
//
//  Created by student on 08/12/25.
//

import Foundation
import SwiftUI

class VerificationViewModel: ObservableObject {
    // Input dari View sebelumnya
    var targetEmail: String = ""
    
    // Input User di layar ini
    @Published var inputCode: String = ""
    
    // Logic Internal
    @Published var generatedCode: String = "" // Kode asli yang benar
    @Published var isLoading: Bool = false
    @Published var errorMessage: String = ""
    @Published var showAlert: Bool = false
    @Published var isVerified: Bool = false // Pemicu navigasi ke Reset Password
    
    // MARK: - 1. Simulasi Kirim Kode
    func sendOTP() {
        self.isLoading = true
        
        // Simulasi delay jaringan (biar terasa loading)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            // Generate 4 angka acak
            let randomInt = Int.random(in: 1000...9999)
            self.generatedCode = String(randomInt)
            
            self.isLoading = false
            
            // --- SIMULASI PENGIRIMAN EMAIL ---
            print("=========================================")
            print("📧 EMAIL SIMULATION TO: \(self.targetEmail)")
            print("🔑 YOUR OTP CODE IS: \(self.generatedCode)")
            print("=========================================")
            // -------------------------------------
        }
    }
    
    // MARK: - 2. Verifikasi Kode
    func verifyOTP() {
        if inputCode == generatedCode {
            print("✅ Code Matched! Proceed to Reset Password.")
            self.isVerified = true
        } else {
            print("❌ Wrong Code.")
            self.errorMessage = "Invalid code. Please check your console/email."
            self.showAlert = true
            self.inputCode = "" // Reset input biar user ngetik ulang
        }
    }
}
