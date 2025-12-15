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
        _viewModel = StateObject(
            wrappedValue: SurveyDetailViewModel(survey: survey)
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header Image (Placeholder)
            Image("mountain")
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

                // Categories
                if !viewModel.categoryNames.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(viewModel.categoryNames, id: \.self) {
                                category in
                                Text(category)
                                    .font(.caption.weight(.medium))
                                    .foregroundColor(darkTeal)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(darkTeal.opacity(0.1))
                                    .cornerRadius(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(
                                                darkTeal.opacity(0.2),
                                                lineWidth: 1
                                            )
                                    )
                            }
                        }
                    }
                }

                // MARK: - Metadata Row (Deadline, Duration, Count)
                // PERUBAHAN DISINI: Saya ubah jadi ScrollView horizontal agar muat di HP kecil
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {

                        // 1. DEADLINE (Baru)
                        if viewModel.hasDeadline {
                            HStack(spacing: 4) {
                                Text("Until: \(viewModel.deadlineString)")
                                    .foregroundColor(
                                        viewModel.isExpired ? .red : .gray
                                    )
                            }
                            // Divider kecil pemisah
                            Text("|").foregroundColor(Color.gray.opacity(0.3))
                        }

                        // 2. DURATION
                        HStack(spacing: 4) {
                            Image(systemName: "clock")
                            Text(viewModel.durationString)
                        }
                        .foregroundColor(.gray)

                        Text("|").foregroundColor(Color.gray.opacity(0.3))

                        // 3. QUESTION COUNT
                        HStack(spacing: 4) {
                            Image(systemName: "list.bullet.clipboard")
                            Text("\(viewModel.questionCount) Questions")
                        }
                        .foregroundColor(.gray)
                    }
                    .font(.footnote)
                }

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
                viewModel.validateAndStart()
            }) {
                Text("Start Survey")
                    .font(.headline.bold())
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(viewModel.isExpired ? Color.gray : darkTeal)  // Disable warna jika expired
                    .cornerRadius(16)
            }
            .disabled(viewModel.isExpired)  // Disable klik jika expired
            .padding(.horizontal, 24)
            .padding(.bottom, 30)
        }
        .ignoresSafeArea(edges: .top)
        .navigationDestination(isPresented: $viewModel.canNavigate) {
            SurveyQuestionView(context: viewContext, survey: viewModel.survey)
        }
        .alert(isPresented: $viewModel.showError) {
            Alert(
                title: Text("Cannot Start"),
                message: Text(viewModel.errorMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}
