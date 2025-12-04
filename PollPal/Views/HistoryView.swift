//
//  HistoryView.swift
//  Pollpal_Respondent
//
//  Created by student on 27/11/25.
//

import SwiftUI

struct HistoryView: View {
    
    // Contoh model data
        struct SurveyItem: Identifiable {
            let id = UUID()
            let owner: String
            let title: String
            let status: SurveyStatus
            let categories: [String]
        }
        
        enum SurveyStatus {
            case inProgress
            case finished
        }
        
        let surveys: [SurveyItem] = [
            SurveyItem(owner: "Feli",
                       title: "Survey Kebiasaan dan Hobi di Rumah",
                       status: .inProgress,
                       categories: ["Psychology", "Daily Life"]),
            SurveyItem(owner: "Evelin",
                       title: "Survey Desain Karakter Game Genshin Impact",
                       status: .finished,
                       categories: ["Design", "Technology"])
        ]
    
    var body: some View {
        VStack(spacing: 0) {

                    // search bar
            
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(surveys) { survey in
                                SurveyCard(item: survey)
                            }
                        }
                        .padding()
                    }
                    
                    Spacer()
                }
                .background(Color(hex: "#EFEFEF"))
                .ignoresSafeArea(edges: .bottom)
    }
}

struct SurveyCard: View {
    let item: HistoryView.SurveyItem
    
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
            
            //Category
            
            
            // Status section
            HStack {
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
                
                // Status
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
    
#Preview {
    HistoryView()
}
