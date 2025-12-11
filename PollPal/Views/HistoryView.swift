//
//  HistoryView.swift
//  Pollpal_Respondent
//
//  Created by student on 27/11/25.
//

import SwiftUI
import CoreData

struct HistoryView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var viewModel: HistoryViewModel
    
    init(context: NSManagedObjectContext) {
        _viewModel = StateObject(wrappedValue: HistoryViewModel(context: context))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            
            if viewModel.historyItems.isEmpty {
                // --- EMPTY STATE (TIDAK BERUBAH) ---
                VStack(spacing: 20) {
                    Spacer()
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
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(hex: "#EFEFEF"))
                
            } else {
                // --- LIST ---
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(viewModel.historyItems) { item in
                            SurveyCard(item: item)
                        }
                    }
                    .padding()
                }
                .background(Color(hex: "#EFEFEF"))
            }
        }
        .background(Color(hex: "#EFEFEF"))
        .onAppear {
            viewModel.fetchHistory()
        }
    }
}

// MARK: - UPDATED SURVEY CARD
struct SurveyCard: View {
    let item: HistoryItem

    var body: some View {
        VStack(alignment: .leading, spacing: 10) { // Spacing sedikit diperbesar

            // MARK: HEADER (Owner & Points)
            HStack {
                // Owner Info
                HStack(spacing: 6) {
                    Image(systemName: "person.crop.circle")
                        .foregroundColor(.gray)
                    Text(item.owner)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .fontWeight(.medium)
                }

                Spacer()

                // BARU: Reward Points Badge
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.caption2)
                    Text("+\(item.points) pts")
                        .font(.caption)
                        .fontWeight(.bold)
                }
                .foregroundColor(Color(hex: "FE982A")) // Warna Orange Brand
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color(hex: "FE982A").opacity(0.1))
                .cornerRadius(8)
            }

            // MARK: TITLE
            Text(item.title)
                .font(.body) // Sedikit lebih besar
                .foregroundColor(Color(hex: "#0C4254"))
                .fixedSize(horizontal: false, vertical: true)
                .fontWeight(.bold)
                .lineLimit(2)

            // MARK: FOOTER (Category, Date, Status)
            HStack(alignment: .bottom) {
                // Category Loop (Maksimal 2 biar ga penuh, sisanya +N)
                HStack {
                    ForEach(item.categories.prefix(2), id: \.self) { cat in
                        Text(cat)
                            .font(.caption2)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color(hex: "#B5C7D1").opacity(0.5))
                            .foregroundColor(Color(hex: "0C4254"))
                            .cornerRadius(6)
                    }
                    if item.categories.count > 2 {
                        Text("+\(item.categories.count - 2)")
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                }

                Spacer()

                // BARU: Status & Tanggal
                VStack(alignment: .trailing, spacing: 4) {
                    if item.status == .finished {
                        // Tampilkan Tanggal
                        Text(item.formattedDate)
                            .font(.caption2)
                            .foregroundColor(.gray)
                        
                        Text("Finished")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                    } else {
                        Text("Continue..")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(Color(hex: "FE982A"))
                            .underline()
                    }
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16) // Lebih rounded
        .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 3) // Shadow lebih soft
    }
}
