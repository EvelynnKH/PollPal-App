import SwiftUI
import CoreData

struct QuestionEditorCard: View {
    @ObservedObject var question: Question          // Core Data object
    @Binding var qtype: QuestionType
    @Environment(\.managedObjectContext) private var context

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            // MARK: - Title (safeText)
            TextField(
                "Judul Pertanyaan",
                text: Binding(
                    get: { question.safeText },
                    set: { question.safeText = $0 }
                )
            )
            .font(.system(size: 20, weight: .semibold))


            // MARK: - Sections
            typePickerSection
            optionsEditorSection
            previewSection
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.1), radius: 5, y: 2)
        )
        .onDisappear {
            try? context.save()
        }
    }

    // --------------------------
    // Type picker section
    // --------------------------
    private var typePickerSection: some View {
        HStack {
            Text(qtype.rawValue.capitalized)
                .font(.system(size: 14, weight: .medium))

            Spacer()

            Menu {
                ForEach(QuestionType.allCases, id: \.rawValue) { type in
                    Button(type.rawValue.capitalized) {
                        qtype = type

                        // persist type on question
                        question.safeType = type

                        // reset options if needed
                        if type == .multipleChoice || type == .checkboxes || type == .dropdown {
                            if question.optionsArray.isEmpty {
                                question.addOption(text: "Option 1", context: context)
                                try? context.save()
                            }
                        } else {
                            // if switching away from options-based type, optionally delete options
                            // (we keep existing options in DB so user can switch back)
                        }
                    }
                }
            } label: {
                Label("Type", systemImage: "chevron.down")
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .foregroundColor(.white)
                    .background(Capsule().fill(Color.themeOrange))
            }
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 10)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }

    // --------------------------
    // Options editor (relationship-based)
    // --------------------------
    private var optionsEditorSection: some View {
        Group {
            if qtype == .multipleChoice || qtype == .checkboxes || qtype == .dropdown {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Opsi Jawaban:")
                        .font(.subheadline)
                        .fontWeight(.bold)

                    // iterate over Option entities
                    ForEach(question.optionsArray, id: \.option_id) { option in
                        HStack {
                            // edit option text directly on the Option object
                            TextField(
                                "Isi opsi...",
                                text: Binding(
                                    get: { option.option_text ?? "" },
                                    set: { newText in
                                        option.option_text = newText
                                        try? context.save()
                                    }
                                )
                            )
                            .textFieldStyle(.roundedBorder)

                            Button {
                                // delete option entity
                                question.deleteOption(option, context: context)
                                try? context.save()
                            } label: {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                        }
                    }

                    // Add option button -> uses relation helper
                    Button {
                        let nextIndex = question.optionsArray.count + 1
                        question.addOption(text: "Option \(nextIndex)", context: context)
                        try? context.save()
                    } label: {
                        Label("Tambah Opsi", systemImage: "plus.circle.fill")
                            .foregroundColor(.blue)
                    }
                    .padding(.top, 4)
                }
            }
        }
    }

    // --------------------------
    // Preview (uses QuestionRenderer; keep signature)
    // --------------------------
    private var previewSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Preview:")
                .font(.subheadline)
                .foregroundColor(.gray)

            // create a temporary response for preview (creator mode)
            let tempResponse = DResponse(context: context)
            // note: do NOT save tempResponse here (preview only)

            QuestionRenderer(
                question: question,
                response: tempResponse,
                qtype: $qtype
            )
            .padding(.top, 4)
        }
    }
}
