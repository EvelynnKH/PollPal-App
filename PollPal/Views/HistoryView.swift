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
            
            // Search Bar Placeholder (Sesuai kode aslimu)
            // TextField("Search...", text: .constant("")) ...
            
            ScrollView {
                VStack(spacing: 16) {
                    
                    if viewModel.historyItems.isEmpty {
                        // Empty State
                        VStack {
                            Image(systemName: "clock.arrow.circlepath")
                                .font(.system(size: 50))
                                .foregroundColor(.gray)
                                .padding()
                            Text("Belum ada riwayat survei")
                                .foregroundColor(.gray)
                        }
                        .padding(.top, 50)
                    } else {
                        // Data dari ViewModel
                        ForEach(viewModel.historyItems) { item in
                            SurveyCard(item: item)
                        }
                    }
                }
                .padding()
            }
            
            Spacer()
        }
        .background(Color(hex: "#EFEFEF"))
        .ignoresSafeArea(edges: .bottom)
        .onAppear {
            viewModel.fetchHistory() // Refresh data saat muncul
        }
    }
}

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
                .foregroundColor(Color(hex:"#0C4254"))
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
