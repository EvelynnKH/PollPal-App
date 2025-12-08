//
//  HistoryView.swift
//  Pollpal_Respondent
//
//  Created by student on 27/11/25.
//

import SwiftUI
import CoreData

struct HistoryView: View {
    // Inject Context & ViewModel
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var viewModel: HistoryViewModel
    
    // Custom Init
    init(context: NSManagedObjectContext) {
        _viewModel = StateObject(wrappedValue: HistoryViewModel(context: context))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            
            // LOGIKA UTAMA: Cek apakah data kosong?
            if viewModel.historyItems.isEmpty {
                
                // --- TAMPILAN FULL SCREEN EMPTY STATE ---
                VStack(spacing: 20) {
                    Spacer()
                    
                    // 1. Ilustrasi Ikon
                    ZStack {
                        Circle()
                            .fill(Color(hex: "0C4254").opacity(0.1))
                            .frame(width: 150, height: 150)
                        
                        Image(systemName: "list.clipboard")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 70, height: 70)
                            .foregroundColor(Color(hex: "0C4254"))
                    }
                    .padding(.bottom, 10)
                    
                    // 2. Teks Informatif
                    Text("No History Yet")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(Color(hex: "0C4254"))
                    
                    Text("You haven't participated in any surveys.\nStart now to earn points!")
                        .font(.body)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                    
                    Spacer()
                }
                // KUNCI PERUBAHAN DISINI:
                .frame(maxWidth: .infinity, maxHeight: .infinity) // Paksa memenuhi layar
                .background(Color(hex: "#EFEFEF")) // Warna background diaplikasikan disini
                
            } else {
                
                // --- TAMPILAN LIST (JIKA ADA DATA) ---
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(viewModel.historyItems) { item in
                            SurveyCard(item: item)
                        }
                    }
                    .padding()
                }
                .background(Color(hex: "#EFEFEF")) // Background untuk list juga sama
            }
        }
        .background(Color(hex: "#EFEFEF")) // Safety net: Background container utama
        .onAppear {
            viewModel.fetchHistory()
        }
    }
}

// ... (Struct SurveyCard tetap sama) ...

// Komponen Card dipisah agar rapi
struct SurveyCard: View {
    let item: HistoryItem

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {

            // User owner
            HStack {
                Image(systemName: "person.crop.circle")
                    .foregroundColor(.orange)
                Text(item.owner)
                    .foregroundColor(.orange)
                    .fontWeight(.semibold)
            }

            // Survey Title
            Text(item.title)
                .font(.body)
                .foregroundColor(Color(hex: "#0C4254"))
                .fixedSize(horizontal: false, vertical: true)
                .fontWeight(.bold)
                .padding(.vertical)

            // Status section
            HStack {
                // Category Loop
                ForEach(item.categories, id: \.self) { cat in
                    Text(cat)
                        .font(.caption)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color(hex: "#B5C7D1"))
                        .foregroundColor(.black)
                        .cornerRadius(10)
                }

                Spacer()

                // Status Logic
                if item.status == .inProgress {
                    Text("Continue..")
                        .foregroundColor(.orange)
                        .font(.footnote)
                        .fontWeight(.semibold)
                        .underline()
                } else {
                    Text("Finished")
                        .foregroundColor(.gray)
                        .font(.footnote)
                        .fontWeight(.semibold)
                        .underline()
                }
            }
            .padding(.top, 4)

        }
        .padding()
        .background(Color.white)
        .cornerRadius(14)
        .shadow(color: Color.black.opacity(0.1), radius: 4, y: 2)
    }
}
