import Foundation
import SwiftUI

struct QuestionRenderer: View {
    @ObservedObject var question: Question
    @ObservedObject var response: DResponse
    @Binding var qtype: QuestionType

    var isPreview: Bool = false      // <–– added safely, tidak ubah var lain

    @Environment(\.managedObjectContext) private var context

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            Text(question.question_text ?? "")
                .font(.headline)

            switch qtype {

            case .shortAnswer:
                TextField("Answer...", text: Binding(
                    get: { response.dresponse_answer_text ?? "" },
                    set: { if !isPreview { response.dresponse_answer_text = $0 } }
                ))
                .textFieldStyle(.roundedBorder)
                .disabled(isPreview)

            case .paragraph:
                TextEditor(text: Binding(
                    get: { response.dresponse_answer_text ?? "" },
                    set: { if !isPreview { response.dresponse_answer_text = $0 } }
                ))
                .frame(minHeight: 100)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(.gray.opacity(0.3)))
                .disabled(isPreview)

            case .multipleChoice, .checkboxes:
                VStack(alignment: .leading, spacing: 10) {

                    ForEach(question.optionsArray, id: \.self) { option in
                        HStack(spacing: 12) {

                            if qtype == .multipleChoice {

                                RadioButton(
                                    selected: Binding(
                                        get: { response.dresponse_answer_text ?? "" },
                                        set: { if !isPreview { response.dresponse_answer_text = $0 } }
                                    ),
                                    value: option.option_text ?? ""
                                )

                                Text(option.option_text ?? "")

                            } else {

                                Toggle(isOn: Binding(
                                    get: {
                                        let arr = (response.dresponse_answer_text ?? "")
                                            .components(separatedBy: ",")
                                        return arr.contains(option.option_text ?? "")
                                    },
                                    set: { checked in
                                        if isPreview { return }
                                        var arr = (response.dresponse_answer_text ?? "")
                                            .components(separatedBy: ",")
                                        if checked {
                                            arr.append(option.option_text ?? "")
                                        } else {
                                            arr.removeAll { $0 == option.option_text }
                                        }
                                        response.dresponse_answer_text = arr.joined(separator: ",")
                                    }
                                )) {
                                    Text(option.option_text ?? "")
                                }
                                .disabled(isPreview)
                            }

                            Spacer()

                            if !isPreview {
                                Button {
                                    question.deleteOption(option, context: context)
                                    try? context.save()
                                } label: {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
                                }
                            }
                        }
                    }

                    if !isPreview {
                        Button {
                            question.addOption(
                                text: "Option \(question.optionsArray.count + 1)",
                                context: context
                            )
                            try? context.save()
                        } label: {
                            Label("Add Option", systemImage: "plus.circle.fill")
                                .foregroundColor(.blue)
                        }
                        .padding(.top, 4)
                    }
                }

            case .dropdown:
                Picker("Choose", selection: Binding(
                    get: { response.dresponse_answer_text ?? "" },
                    set: { if !isPreview { response.dresponse_answer_text = $0 } }
                )) {
                    ForEach(question.optionsArray, id: \.self) { option in
                        Text(option.option_text ?? "")
                            .tag(option.option_text ?? "")
                    }
                }
                .pickerStyle(.menu)
                .disabled(isPreview)
            }
        }
        .padding(.vertical, 8)
    }
}
