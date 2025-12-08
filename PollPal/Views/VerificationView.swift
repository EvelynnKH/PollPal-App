//
//  VerificationView.swift
//  PollPal
//
//  Created by student on 08/12/25.
//

import SwiftUI

struct VerificationView: View {
    // Terima Email dari halaman sebelumnya (ForgotPasswordView)
    let email: String
    
    @StateObject private var viewModel = VerificationViewModel()
    @FocusState private var isFocused: Bool
    
    let maxDigits = 4
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.white.edgesIgnoringSafeArea(.all)
                
                VStack(alignment: .leading, spacing: 50) {
                    
                    // MARK: Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Verify Code")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(Color(hex: "0C4254"))
                        
                        Text("Code sent to \(email)") // Tampilkan email user
                            .font(.body)
                            .foregroundColor(.gray)
                        
                        if viewModel.isLoading {
                            Text("Sending code...")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                    }
                    
                    // MARK: OTP Blocks
                    VStack(spacing: 30) {
                        ZStack {
                            // Tap area to focus keyboard
                            Color.clear
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    isFocused = true
                                }
                            
                            // VISUAL LAYER (Kotak-kotak)
                            HStack(spacing: 15) {
                                ForEach(0..<maxDigits, id: \.self) { index in
                                    OTPBoxView(digit: getDigit(at: index))
                                }
                            }
                            .allowsHitTesting(false)
                            
                            // INPUT LAYER (Hidden TextField)
                            TextField("", text: $viewModel.inputCode)
                                .keyboardType(.numberPad)
                                .focused($isFocused)
                                .onChange(of: viewModel.inputCode) { oldValue, newValue in
                                    if newValue.count > maxDigits {
                                        viewModel.inputCode = String(newValue.prefix(maxDigits))
                                    }
                                }
                                .foregroundColor(.clear)
                                .accentColor(.clear)
                                .opacity(0.01) // Transparan
                        }
                        .frame(height: 60)
                    }
                    .onAppear {
                        // Set email ke ViewModel saat layar muncul
                        viewModel.targetEmail = email
                        // Kirim kode otomatis
                        viewModel.sendOTP()
                        
                        // Focus keyboard
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            isFocused = true
                        }
                    }
                    
                    Spacer()
                    
                    // MARK: Verify Button
                    Button(action: {
                        viewModel.verifyOTP()
                    }) {
                        if viewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Verify")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundStyle(viewModel.inputCode.count == maxDigits ? Color(hex: "FE982A") : Color.white.opacity(0.8))
                        }
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    // Warna berubah jika digit belum lengkap
                    .background(viewModel.inputCode.count == maxDigits ? Color(hex: "0C4254") : Color.gray)
                    .cornerRadius(18)
                    .disabled(viewModel.inputCode.count != maxDigits || viewModel.isLoading)
                    .padding(.bottom, 20)
                }
                .padding(.horizontal, 30)
                .padding(.top, 50)
                
                // MARK: - Navigation Destination
                // Jika isVerified == true, pindah ke Reset Password
                .navigationDestination(isPresented: $viewModel.isVerified) {
                    // Kita kirim email lagi ke layar Reset Password
                    // Agar layar Reset Password tahu User mana yang harus diupdate di CoreData
                    ResetPasswordView(targetEmail: email)
                }
            }
            // Alert Error
            .alert(isPresented: $viewModel.showAlert) {
                Alert(title: Text("Error"), message: Text(viewModel.errorMessage), dismissButton: .default(Text("Try Again")))
            }
        }
    }
    
    // Helper to show each digit
    func getDigit(at index: Int) -> String {
        guard index < viewModel.inputCode.count else { return "" }
        let charIndex = viewModel.inputCode.index(viewModel.inputCode.startIndex, offsetBy: index)
        return String(viewModel.inputCode[charIndex])
    }
}

// MARK: - Reusable OTP Box (Tidak berubah)
struct OTPBoxView: View {
    var digit: String
    
    var body: some View {
        Text(digit)
            .font(.title2)
            .fontWeight(.bold)
            .frame(width: 60, height: 60)
            .background(Color.white)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color(hex: "#0C4254"), lineWidth: 1)
            )
            .shadow(color: .gray.opacity(0.2), radius: 2, x: 0, y: 2)
    }
}

#Preview {
    VerificationView(email: "test@gmail.com")
}
