//
//  SmartImageView.swift
//  PollPal
//
//  Created by student on 08/12/25.
//

import SwiftUI

struct SmartImageView: View {
    let imageName: String?
    let fallbackImage: String
    
    var body: some View {
        if let name = imageName,
           let fileImage = loadImageFromDisk(named: name) {
            // 1. Prioritas: Load dari File System (Foto User)
            Image(uiImage: fileImage)
                .resizable()
                .scaledToFill()
        }
        else if let name = imageName, !name.isEmpty, UIImage(named: name) != nil {
            // 2. Jika gagal, Load dari Assets (Gambar Bawaan)
            Image(name)
                .resizable()
                .scaledToFill()
        }
        else {
            // 3. Terakhir: Gambar Default
            Image(fallbackImage)
                .resizable()
                .scaledToFill()
        }
    }
    
    // Helper Internal (Pengganti ImageFileManager.loadImage)
    private func loadImageFromDisk(named fileName: String) -> UIImage? {
        let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(fileName)
        return UIImage(contentsOfFile: fileURL.path)
    }
}
