import CoreData
import SwiftUI

struct QuestionEditorCard: View {
    @ObservedObject var question: Question  // Core Data object
    @Binding var qtype: QuestionType
    @Environment(\.managedObjectContext) private var context
    @ObservedObject var vm: SurveyViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 0) { // Spacing 0 agar Header menempel rapi ke atas
            
            // MARK: - 1. HEADER AREA (Judul & Delete)
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Question Title")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    TextField("Write your question...", text: Binding(
                        get: { question.safeText },
                        set: { question.safeText = $0 }
                    ))
                    .font(.system(size: 18, weight: .semibold))
                }
                
                Spacer()
                
                Button {
                    vm.deleteQuestion(question)
                } label: {
                    Image(systemName: "trash.fill") // Pakai .fill biar lebih solid
                        .font(.subheadline)
                        .foregroundColor(.red.opacity(0.8))
                        .padding(8)
                        .background(Color.red.opacity(0.1)) // Background tombol biar jelas area sentuhnya
                        .clipShape(Circle())
                }
            }
            .padding(16) // Padding khusus header
            .background(Color(hex: "#F4F6F8")) // Warna header sedikit abu/biru muda (beda dari body)
            
            Divider() // Garis pemisah tegas
            
            // MARK: - 2. CONTENT BODY
            VStack(alignment: .leading, spacing: 20) {
                
                // Section: Tipe & Opsi
                VStack(alignment: .leading, spacing: 12) {
                    Text("Question Type")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.secondary)
                        .textCase(.uppercase)
                    
                    typePickerSection
                    optionsEditorSection
                }
                
                Divider()
                    .padding(.horizontal, -16) // Hack biar divider mentok kiri-kanan
                
                // Section: Preview
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "eye")
                            .font(.caption)
                        Text("Preview")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(.secondary)
                    
                    previewSection
                        .padding()
                        .background(Color.gray.opacity(0.05)) // Preview dikasih kotak tipis sendiri
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        )
                }
            }
            .padding(16) // Padding body
            
        }
        // MARK: - 3. CONTAINER CARD STYLE
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4) // Shadow lebih soft
        .overlay(
            // Opsional: Border tipis biar makin rapi
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.15), lineWidth: 1)
        )// Jarak kiri kanan dari layar
        .padding(.bottom, 16) // Jarak antar kartu
        .onDisappear {
            try? context.save()
        }
        
    }

    // --------------------------
    // Type picker section
    // --------------------------
    private var typePickerSection: some View {
        HStack {
            Text(qtype.title)
                .font(.system(size: 14, weight: .medium))

            Spacer()

            Menu {
                ForEach(QuestionType.allCases, id: \.rawValue) { type in
                    Button(type.title) {
                        // PANGGIL FUNGSI LOGIC DISINI
                        changeQuestionType(to: type)
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

    private func changeQuestionType(to type: QuestionType) {
        // 1. Ubah Tipe di UI Binding & Core Data Object
        qtype = type
        question.safeType = type

        // 2. LOGIKA KHUSUS: LINEAR SCALE
        // Jika user pilih Linear Scale, otomatis buat opsi 1-5 jika belum ada
        if type == .linearscale {
            let currentCount = question.optionsArray.count
            if currentCount == 0 {
                for i in 1...5 {
                    let opt = Option(context: context)
                    opt.option_id = UUID()
                    opt.option_text = "\(i)"
                    question.addToHas_option(opt)  // Link ke question
                }
                try? context.save()
            }
        }

        // 3. LOGIKA KHUSUS: MULTIPLE CHOICE dkk (Opsional)
        // Tambah 1 opsi kosong jika user pilih PG tapi belum ada opsi
        else if [.multipleChoice, .checkboxes, .dropdown].contains(type) {
            if question.optionsArray.isEmpty {
                question.addOption(text: "Option 1", context: context)
                try? context.save()
            }
        }
    }

    // --------------------------
    // Options editor (relationship-based)
    // --------------------------
    private var optionsEditorSection: some View {
        Group {
            if qtype == .multipleChoice || qtype == .checkboxes
                || qtype == .dropdown
            {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Option:")
                        .font(.subheadline)
                        .fontWeight(.bold)

                    // iterate over Option entities
                    ForEach(question.optionsArray, id: \.option_id) { option in
                        HStack {
                            // edit option text directly on the Option object
                            TextField(
                                "Fill in your option(s)",
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
                        question.addOption(
                            text: "Option \(nextIndex)",
                            context: context
                        )
                        try? context.save()
                    } label: {
                        Label("Add more option", systemImage: "plus.circle.fill")
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
// create a temporary response for preview (creator mode)
            let tempResponse = DResponse(context: context)
            // note: do NOT save tempResponse here (preview only)

            QuestionRenderer(
                question: question,
                response: tempResponse,
                qtype: $qtype,
                vm: vm,
                isPreview: true
            )
            .padding(.top, 4)
        }
    }
}
