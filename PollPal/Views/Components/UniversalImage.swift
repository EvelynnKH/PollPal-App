//
//  UniversalImage.swift
//  PollPal
//
//  Created by student on 17/12/25.
//

import SwiftUI

struct UniversalImage: View {
    let imageName: String
    
    var body: some View {
        // 1. Cek apakah ini File URL (dari upload user)
        if imageName.hasPrefix("file://") {
            
            // Panggil fungsi loader pintar
            if let uiImage = loadLocalImage(from: imageName) {
                Image(uiImage: uiImage)
                    .resizable()
            } else {
                // GAGAL TOTAL: File benar-benar tidak ada
                ZStack {
                    Color.gray.opacity(0.1)
                    VStack(spacing: 8) {
                        Image(systemName: "photo.badge.exclamationmark")
                            .font(.largeTitle)
                            .foregroundColor(.gray)
                        Text("Image Not Found")
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                }
            }
            
        } else {
            // 2. Jika bukan file://, berarti Asset Dummy (misal "mountain")
            Image(imageName)
                .resizable()
        }
    }
    
    // --- FUNGSI PINTAR: LOAD & PERBAIKI PATH ---
    func loadLocalImage(from path: String) -> UIImage? {
        // A. Coba load path apa adanya (siapa tau masih valid)
        if let url = URL(string: path),
           let data = try? Data(contentsOf: url),
           let image = UIImage(data: data) {
            return image
        }
        
        // B. Jika GAGAL, coba perbaiki Path (Simulator Issue Fix)
        // Ambil nama filenya saja (misal: "E2EF7ADC...jpg")
        let fileName = (path as NSString).lastPathComponent
        
        // Cari nama file itu di Folder Documents yang SEKARANG aktif
        let currentDocs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let newURL = currentDocs.appendingPathComponent(fileName)
        
        // Coba load lagi dari alamat baru
        if let data = try? Data(contentsOf: newURL),
           let image = UIImage(data: data) {
            print("✅ Path diperbaiki otomatis! Gambar ditemukan.")
            return image
        }
        
        return nil // Menyerah, gambar memang hilang
    }
}
