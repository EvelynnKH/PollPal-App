import SwiftUI

struct QuestionEditorCard: View {
    @Binding var question: Question
    @State private var expandedTypePicker = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            // MARK: - Title
            TextField(
                "Judul Pertanyaan",
                text: Binding(
                    get: { question.question_text ?? "" },
                    set: { question.question_text = $0 }
                )
            )
            .font(.system(size: 20, weight: .semibold))
            .font(.system(size: 20, weight: .semibold))

            // MARK: - Description
            TextField("Deskripsi singkat...", text: Binding(
                get: { question.description ?? "" },
                set: { question.question_text = $0 }
            ))
            .font(.system(size: 14))
            .foregroundColor(.gray)

            // MARK: - Type Picker
            HStack {
                Text(question.type.rawValue.capitalized)
                    .font(.system(size: 14, weight: .medium))

                Spacer()

                Menu {
                    ForEach(QuestionType.allCases) { type in
                        Button(type.rawValue.capitalized) {
                            question.type = type

                            // RESET options when type changes
                            if type == .multipleChoice || type == .checkboxes || type == .dropdown {
                                if question.options.isEmpty {
                                    question.options = [""]
                                }
                            } else {
                                question.options = []
                            }
                        }
                    }
                } label: {
                    Label("Type", systemImage: "chevron.down")
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .foregroundColor(.white)
                        .background(
                            Capsule()
                                .fill(Color.themeOrange)
                        )
                }
            }
            .padding(.vertical, 6)
            .padding(.horizontal, 10)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)

            // MARK: - Options Editor (Only for MC / Checkbox / Dropdown)
            if question.type == .multipleChoice ||
                question.type == .checkboxes ||
                question.type == .dropdown {

                VStack(alignment: .leading, spacing: 10) {
                    Text("Opsi Jawaban:")
                        .font(.subheadline)
                        .fontWeight(.bold)

                    ForEach(question.options.indices, id: \.self) { idx in
                        HStack {
                            TextField("Isi opsi...", text: $question.options[idx])
                                .textFieldStyle(.roundedBorder)

                            Button {
                                question.options.remove(at: idx)
                            } label: {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                        }
                    }

                    // ADD OPTION BUTTON
                    Button {
                        question.options.append("")
                    } label: {
                        Label("Tambah Opsi", systemImage: "plus.circle.fill")
                            .foregroundColor(.blue)
                    }
                    .padding(.top, 4)
                }
            }

            // MARK: - Preview
            VStack(alignment: .leading, spacing: 4) {
                Text("Preview:")
                    .font(.subheadline)
                    .foregroundColor(.gray)

                QuestionRenderer(question: $question)
                    .padding(.top, 4)
            }

        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.1), radius: 5, y: 2)
        )
    }
}
