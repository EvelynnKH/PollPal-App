//
//  SurveyQuestionView.swift
//  PollPal
//
//  Created by student on 08/12/25.
//

import CoreData
import SwiftUI

struct SurveyQuestionView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel: SurveyQuestionViewModel

    // Colors
    let darkTeal = Color(hex: "0C4254")
    let brandOrange = Color(hex: "FE982A")
    let lightGray = Color.gray.opacity(0.1)

    init(context: NSManagedObjectContext, survey: Survey) {
        _viewModel = StateObject(
            wrappedValue: SurveyQuestionViewModel(
                context: context,
                survey: survey
            )
        )
    }

    var body: some View {
        VStack(spacing: 20) {

            // MARK: - Progress Header
            VStack(spacing: 8) {
                HStack {
                    Text("Question \(viewModel.progressString)")
                        .font(.subheadline.bold())
                        .foregroundColor(darkTeal)
                    Spacer()
                }

                // Progress Bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 5)
                            .frame(height: 6)
                            .foregroundColor(lightGray)

                        RoundedRectangle(cornerRadius: 5)
                            .frame(
                                width: geometry.size.width
                                    * CGFloat(viewModel.progressFraction),
                                height: 6
                            )
                            .foregroundColor(darkTeal)
                            .animation(
                                .linear,
                                value: viewModel.progressFraction
                            )
                    }
                }
                .frame(height: 6)
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)

            Divider()

            // MARK: - Question Content
            if let question = viewModel.currentQuestion {
                ScrollView {
                    VStack(alignment: .leading, spacing: 25) {
                        // Teks Pertanyaan
                        Text(question.question_text ?? "Unknown Question")
                            .font(.title3.bold())
                            .foregroundColor(darkTeal)
                            .fixedSize(horizontal: false, vertical: true)

                        // Gambar Pertanyaan (Jika ada)
                        if let imgUrl = question.question_img_url,
                            !imgUrl.isEmpty
                        {
                            // Placeholder logic gambar (nanti diganti SmartImageView jika sudah implementasi)
                            Image(systemName: "photo")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 150)
                                .foregroundColor(.gray)
                        }

                        let _ = print(
                            "DEBUG: Question Text: \(question.question_text ?? "NIL")"
                        )
                        let _ = print(
                            "DEBUG: Tipe: \(question.question_type ?? "NIL")"
                        )
                        let _ = print(
                            "DEBUG: Jumlah Option: \((question.has_option as? Set<Option>)?.count ?? 0)"
                        )

                        // --- LOGIC TAMPILAN BERDASARKAN TIPE ---

                        if question.question_type == "Multiple Choice" {
                            // TAMPILAN PILIHAN GANDA
                            if let optionsSet = question.has_option
                                as? Set<Option>, !optionsSet.isEmpty
                            {
                                let sortedOptions = optionsSet.sorted {
                                    ($0.option_text ?? "")
                                        < ($1.option_text ?? "")
                                }

                                ForEach(sortedOptions, id: \.option_id) {
                                    option in
                                    OptionRowView(
                                        text: option.option_text ?? "",
                                        isSelected: viewModel.selectedOptions[
                                            question.question_id!
                                        ] == option.option_id,
                                        darkTeal: darkTeal,
                                        brandOrange: brandOrange
                                    )
                                    .onTapGesture {
                                        if let qId = question.question_id,
                                            let oId = option.option_id
                                        {
                                            viewModel.selectOption(
                                                questionId: qId,
                                                optionId: oId
                                            )
                                        }
                                    }
                                }
                            } else {
                                Text("No options configured.").font(.caption)
                                    .foregroundColor(.gray)
                            }

                        } else {
                            // TAMPILAN ESSAY / LONG ANSWER
                            VStack(alignment: .leading) {
                                Text("Your Answer")
                                    .font(.caption)
                                    .foregroundColor(.gray)

                                TextEditor(
                                    text: viewModel.bindingForText(
                                        questionId: question.question_id!
                                    )
                                )
                                .frame(height: 150)
                                .padding(8)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(
                                            Color.gray.opacity(0.3),
                                            lineWidth: 1
                                        )
                                )
                            }
                        }
                        // ----------------------------------------
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 10)
                }
            } else {
                Spacer()
                Text("Loading questions...")
                Spacer()
            }

            Spacer()

            // MARK: - Navigation Buttons
            HStack(spacing: 15) {
                // Tombol Previous
                if viewModel.currentIndex > 0 {
                    Button(action: { viewModel.prevPage() }) {
                        Text("Previous")
                            .fontWeight(.semibold)
                            .foregroundColor(darkTeal)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(darkTeal, lineWidth: 1)
                            )
                            .cornerRadius(12)
                    }
                }

                // Tombol Next / Submit
                Button(action: { viewModel.nextPage() }) {
                    Text(viewModel.isLastQuestion ? "Submit" : "Next")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            viewModel.canGoNext ? darkTeal : Color.gray
                        )
                        .cornerRadius(12)
                }
                .disabled(!viewModel.canGoNext)  // Matikan jika belum dijawab
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 30)

        }
        .navigationBarTitleDisplayMode(.inline)
        // Navigasi ke Halaman Sukses
        .navigationDestination(isPresented: $viewModel.showSuccessScreen) {
            SurveySuccessView(pointsEarned: Int(viewModel.survey.survey_points))
        }
    }
}

// Subview: Tampilan Baris Opsi
struct OptionRowView: View {
    let text: String
    let isSelected: Bool
    let darkTeal: Color
    let brandOrange: Color

    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: isSelected ? "circle.inset.filled" : "circle")
                .font(.title3)
                .foregroundColor(
                    isSelected ? brandOrange : Color.gray.opacity(0.5)
                )

            Text(text)
                .font(.body)
                .foregroundColor(darkTeal)
                .fixedSize(horizontal: false, vertical: true)

            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isSelected ? brandOrange.opacity(0.1) : Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            isSelected ? brandOrange : Color.gray.opacity(0.2),
                            lineWidth: 1
                        )
                )
        )
        .contentShape(Rectangle())
    }
}
