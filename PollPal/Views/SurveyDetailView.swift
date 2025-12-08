//
//  SurveyDetailView.swift
//  PollPal
//
//  Created by student on 08/12/25.
//

import SwiftUI

struct SurveyDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var viewModel: SurveyDetailViewModel
    @State private var navigateToQuestions = false
    
    // Colors
    let darkTeal = Color(hex: "0C4254")
    let brandOrange = Color(hex: "FE982A")
    
    init(survey: Survey) {
        _viewModel = StateObject(wrappedValue: SurveyDetailViewModel(survey: survey))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header Image (Placeholder)
            Image("mountain") // Ganti dengan gambar header default app Anda
                .resizable()
                .scaledToFill()
                .frame(height: 200)
                .clipped()
            
            VStack(alignment: .leading, spacing: 20) {
                // Points Badge
                Text("+\(viewModel.points) Points")
                    .font(.subheadline.bold())
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(brandOrange)
                    .cornerRadius(20)
                
                // Title
                Text(viewModel.title)
                    .font(.title.bold())
                    .foregroundColor(darkTeal)
                
                if !viewModel.categoryNames.isEmpty {
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 8) {
                                            ForEach(viewModel.categoryNames, id: \.self) { category in
                                                Text(category)
                                                    .font(.caption.weight(.medium))
                                                    .foregroundColor(darkTeal)
                                                    .padding(.horizontal, 12)
                                                    .padding(.vertical, 6)
                                                    .background(darkTeal.opacity(0.1)) // Background transparan
                                                    .cornerRadius(8)
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 8)
                                                            .stroke(darkTeal.opacity(0.2), lineWidth: 1)
                                                    )
                                            }
                                        }
                                    }
                                }
                
                // Metadata Row (Duration & Count)
                HStack(spacing: 20) {
                    HStack {
                        Image(systemName: "clock")
                        Text(viewModel.durationString)
                    }
                    HStack {
                        Image(systemName: "list.bullet.clipboard")
                        Text("\(viewModel.questionCount) Questions")
                    }
                }
                .font(.footnote)
                .foregroundColor(.gray)
                
                Divider()
                
                // Description
                Text("Description")
                    .font(.headline)
                    .foregroundColor(darkTeal)
                
                Text(viewModel.description)
                    .font(.body)
                    .foregroundColor(.gray)
                    .lineLimit(nil)
            }
            .padding(.horizontal, 24)
            
            Spacer()
            
            // Start Button
            Button(action: {
                navigateToQuestions = true
            }) {
                Text("Start Survey")
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
        .ignoresSafeArea(edges: .top)
        // Navigasi ke halaman pertanyaan
        .navigationDestination(isPresented: $navigateToQuestions) {
            SurveyQuestionView(context: viewContext, survey: viewModel.survey)
        }
    }
}
