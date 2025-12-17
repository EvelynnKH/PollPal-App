//
//  SurveyQuestionView.swift
//  PollPal
//
//  Created by student on 08/12/25.
//

import CoreData
import SwiftUI

struct SurveyQuestionView: View {
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
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        // Background abu-abu
                        RoundedRectangle(cornerRadius: 5)
                            .fill(lightGray)
                            .frame(height: 6)

                        // Isi Progress (SEKARANG DARK TEAL)
                        RoundedRectangle(cornerRadius: 5)
                            .fill(darkTeal)  // <--- PERUBAHAN DISINI
                            .frame(
                                width: geo.size.width
                                    * CGFloat(viewModel.progressFraction),
                                height: 6
                            )
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
                        // Teks Soal
                        Text(question.question_text ?? "")
                            .font(.title3.bold())
                            .foregroundColor(darkTeal)
                        
                        if let imageName = viewModel.currentQuestionImage {
                            UniversalImage(imageName: imageName) // ✅ Pakai komponen baru ini
                                .scaledToFit()
                                .frame(maxHeight: 200)
                                .cornerRadius(12)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.bottom, 8)
                        }

                        // --- UI SWITCHER ---
                        let type = question.question_type ?? ""
                        let qID = question.question_id!

                        let options =
                            (question.has_option as? Set<Option>)?
                            .sorted {
                                ($0.option_text ?? "") < ($1.option_text ?? "")
                            } ?? []

                        switch type {
                        case "Multiple Choice":
                            ForEach(options, id: \.option_id) { option in
                                OptionRow(
                                    text: option.option_text ?? "",
                                    isSelected:
                                        viewModel.singleSelectionAnswers[qID]
                                        == option.option_id,
                                    iconName: "circle",
                                    selectedIconName: "circle.inset.filled",
                                    color: darkTeal  // Opsional: Bisa diubah ke darkTeal juga jika mau konsisten
                                )
                                .onTapGesture {
                                    viewModel.selectSingleOption(
                                        questionId: qID,
                                        optionId: option.option_id!
                                    )
                                }
                            }

                        case "Check Box":
                            ForEach(options, id: \.option_id) { option in
                                let isSelected =
                                    viewModel.multiSelectionAnswers[qID]?
                                    .contains(option.option_id!) ?? false
                                OptionRow(
                                    text: option.option_text ?? "",
                                    isSelected: isSelected,
                                    iconName: "square",
                                    selectedIconName: "checkmark.square.fill",
                                    color: darkTeal
                                )
                                .onTapGesture {
                                    viewModel.toggleMultiOption(
                                        questionId: qID,
                                        optionId: option.option_id!
                                    )
                                }
                            }

                        case "Drop Down":
                            Menu {
                                ForEach(options, id: \.option_id) { option in
                                    Button(option.option_text ?? "") {
                                        viewModel.selectSingleOption(
                                            questionId: qID,
                                            optionId: option.option_id!
                                        )
                                    }
                                }
                            } label: {
                                HStack {
                                    if let selectedID =
                                        viewModel.singleSelectionAnswers[qID],
                                        let selectedOpt = options.first(where: {
                                            $0.option_id == selectedID
                                        })
                                    {
                                        Text(selectedOpt.option_text ?? "")
                                            .foregroundColor(darkTeal)
                                    } else {
                                        Text("Select an option")
                                            .foregroundColor(.gray)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.down")
                                        .foregroundColor(darkTeal)
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12).stroke(
                                        Color.gray.opacity(0.3),
                                        lineWidth: 1
                                    )
                                )
                            }

                        case "Linear Scale":
                            // PENTING: Urutkan opsi berdasarkan Angka (Int), bukan String
                            // Ini memastikan "10" tidak muncul sebelum "2" jika ada.
                            let scaleOptions = options.sorted {
                                (Int($0.option_text ?? "0") ?? 0)
                                    < (Int($1.option_text ?? "0") ?? 0)
                            }

                            HStack(spacing: 12) {  // Spacing antar lingkaran
                                if scaleOptions.isEmpty {
                                    // Fallback jika opsi kosong (misal data lama belum diupdate)
                                    Text("No scale options available")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                } else {
                                    ForEach(scaleOptions, id: \.option_id) {
                                        option in
                                        let isSelected =
                                            viewModel.singleSelectionAnswers[
                                                qID
                                            ] == option.option_id

                                        VStack(spacing: 8) {
                                            // Lingkaran Angka
                                            ZStack {
                                                Circle()
                                                    .stroke(
                                                        isSelected
                                                            ? darkTeal
                                                            : Color.gray
                                                                .opacity(0.3),
                                                        lineWidth: 2
                                                    )
                                                    .background(
                                                        Circle().fill(
                                                            isSelected
                                                                ? darkTeal
                                                                : Color.white
                                                        )
                                                    )
                                                    .frame(
                                                        width: 44,
                                                        height: 44
                                                    )  // Ukuran sedikit diperbesar

                                                Text(option.option_text ?? "?")
                                                    .font(.headline)
                                                    .fontWeight(.bold)
                                                    .foregroundColor(
                                                        isSelected
                                                            ? .white : darkTeal
                                                    )
                                            }
                                        }
                                        .onTapGesture {
                                            viewModel.selectSingleOption(
                                                questionId: qID,
                                                optionId: option.option_id!
                                            )
                                        }
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)

                        case "Short Answer":
                            TextField(
                                "Your answer...",
                                text: viewModel.bindingForText(questionId: qID)
                            )
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)

                        case "Paragraph":
                            TextEditor(
                                text: viewModel.bindingForText(questionId: qID)
                            )
                            .frame(height: 120)
                            .padding(8)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10).stroke(
                                    Color.gray.opacity(0.2),
                                    lineWidth: 1
                                )
                            )

                        default:
                            Text("Unknown question type: \(type)")
                        }
                    }
                    .padding(.horizontal, 24)
                }
            } else {
                Spacer()
            }

            Spacer()

            // MARK: - Navigation Buttons
            HStack(spacing: 15) {
                if viewModel.currentIndex > 0 {
                    Button("Previous") { viewModel.prevPage() }
                        .buttonStyle(SecondaryButtonStyle(color: darkTeal))
                }

                Button(viewModel.isLastQuestion ? "Submit" : "Next") {
                    viewModel.nextPage()
                }
                // SEKARANG TOMBOL NEXT JUGA DARK TEAL
                .buttonStyle(
                    PrimaryButtonStyle(
                        color: viewModel.canGoNext ? darkTeal : .gray
                    )
                )  // <--- PERUBAHAN DISINI
                .disabled(!viewModel.canGoNext)
            }
            .padding(24)
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $viewModel.showSuccessScreen) {
            SurveySuccessView(pointsEarned: Int(viewModel.survey.survey_rewards_points))
        }
    }
}

// MARK: - Styles

struct OptionRow: View {
    let text: String
    let isSelected: Bool
    let iconName: String
    let selectedIconName: String
    let color: Color

    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: isSelected ? selectedIconName : iconName)
                .font(.title3)
                .foregroundColor(isSelected ? color : .gray.opacity(0.5))
            Text(text)
                .font(.body)
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isSelected ? color.opacity(0.1) : Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 12).stroke(
                        isSelected ? color : Color.gray.opacity(0.2),
                        lineWidth: 1
                    )
                )
        )
        .contentShape(Rectangle())
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    let color: Color
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(color)
            .cornerRadius(12)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    let color: Color
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .fontWeight(.semibold)
            .foregroundColor(color)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 12).stroke(color, lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
    }
}
