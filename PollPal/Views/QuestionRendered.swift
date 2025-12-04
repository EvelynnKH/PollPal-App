import Foundation
import SwiftUI

struct QuestionRenderer: View {
    @Binding var question: Question

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            // Title
            Text(question.title)
                .font(.headline)

            // Render per tipe
            switch question.type {

            // MARK: - Short Answer
            case .shortAnswer:
                TextField("Jawaban...", text: Binding(
                    get: { question.answer?.value as? String ?? "" },
                    set: { question.answer = AnyCodable($0) }
                ))
                .textFieldStyle(.roundedBorder)

            // MARK: - Paragraph
            case .paragraph:
                TextEditor(text: Binding(
                    get: { question.answer?.value as? String ?? "" },
                    set: { question.answer = AnyCodable($0) }
                ))
                .frame(minHeight: 100)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.3)))

            // MARK: - Multiple Choice & Checkboxes
            case .multipleChoice, .checkboxes:
                VStack(alignment: .leading, spacing: 10) {

                    ForEach(question.options.indices, id: \.self) { idx in
                        HStack(spacing: 12) {

                            // Radio vs Checkbox Toggle
                            if question.type == .multipleChoice {
                                RadioButton(
                                    selected: Binding(
                                        get: { question.answer?.value as? String },
                                        set: { question.answer = AnyCodable($0) }
                                    ),
                                    value: question.options[idx]
                                )
                            } else {
                                Toggle(isOn: Binding(
                                    get: {
                                        let arr = question.answer?.value as? [String] ?? []
                                        return arr.contains(question.options[idx])
                                    },
                                    set: { checked in
                                        var arr = question.answer?.value as? [String] ?? []
                                        if checked { arr.append(question.options[idx]) }
                                        else { arr.removeAll { $0 == question.options[idx] } }
                                        question.answer = AnyCodable(arr)
                                    }
                                )) {
                                    Text(question.options[idx])
                                }
                            }

                            // Option text
                            if question.type == .multipleChoice {
                                Text(question.options[idx])
                            }

                            Spacer()

                            Button(action: {
                                question.options.remove(at: idx)
                            }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                        }
                    }

                    Button(action: {
                        question.options.append("Option \(question.options.count + 1)")
                    }) {
                        Label("Add Option", systemImage: "plus.circle.fill")
                            .foregroundColor(.blue)
                    }
                    .padding(.top, 4)
                }

            // MARK: - Dropdown
            case .dropdown:
                Picker("Choose", selection: Binding(
                    get: { question.answer?.value as? String ?? "" },
                    set: { question.answer = AnyCodable($0) }
                )) {
                    ForEach(question.options, id: \.self) { option in
                        Text(option).tag(option)
                    }
                }
                .pickerStyle(MenuPickerStyle())

            // MARK: - Linear Scale
            case .linearScale:
                if let range = question.scaleRange {
                    HStack(spacing: 6) {
                        ForEach(range, id: \.self) { num in
                            Button(action: {
                                question.answer = AnyCodable(num)
                            }) {
                                Text("\(num)")
                                    .padding(8)
                                    .background(
                                        (question.answer?.value as? Int == num)
                                        ? Color.blue.opacity(0.8)
                                        : Color.gray.opacity(0.2)
                                    )
                                    .foregroundColor(.white)
                                    .cornerRadius(6)
                            }
                        }
                    }
                }
            }
        }
        .padding(.vertical, 8)
    }
}
