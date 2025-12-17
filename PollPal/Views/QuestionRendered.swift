import Foundation
import SwiftUI

struct QuestionRenderer: View {
    @ObservedObject var question: Question
    @ObservedObject var response: DResponse
    @Binding var qtype: QuestionType
    @State private var showingImagePicker = false
    @State private var selectedImage: UIImage?
    @ObservedObject var vm: SurveyViewModel

    var isPreview: Bool = false  // <–– added safely, tidak ubah var lain

    @Environment(\.managedObjectContext) private var context

    // Colors
    let darkTeal = Color(hex: "0C4254")
    let brandOrange = Color(hex: "FE982A")
    let lightGray = Color.gray.opacity(0.1)

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            HStack {
                Text(question.question_text ?? "Add Your Question Here")
                    .font(.headline)
                Spacer()

                if isPreview == true {
                    Button {
                        showingImagePicker = true
                    } label: {
                        Image(systemName: "photo.on.rectangle")
                            .font(.title3)
                            .foregroundColor(.blue)
                    }
                }
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(image: $selectedImage)
            }
            // ✅ MODIFIKASI 2: Simpan otomatis saat gambar dipilih
            .onChange(of: selectedImage) { newImage in
                if newImage != nil {
                    saveSelectedImage()
                }
            }

            if let urlString = question.question_img_url {
                AsyncLocalImage(path: urlString)
                    .frame(maxHeight: 200)
                    .cornerRadius(8)
            }

            switch qtype {

            case .shortAnswer:
                TextField(
                    "Answer...",
                    text: Binding(
                        get: { response.dresponse_answer_text ?? "" },
                        set: {
                            if !isPreview {
                                response.dresponse_answer_text = $0
                            }
                        }
                    )
                )
                .textFieldStyle(.roundedBorder)
                .disabled(isPreview)

            case .paragraph:
                TextEditor(
                    text: Binding(
                        get: { response.dresponse_answer_text ?? "" },
                        set: {
                            if !isPreview {
                                response.dresponse_answer_text = $0
                            }
                        }
                    )
                )
                .frame(minHeight: 100)
                .overlay(
                    RoundedRectangle(cornerRadius: 8).stroke(.gray.opacity(0.3))
                )
                .disabled(isPreview)

            case .multipleChoice, .checkboxes:
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(question.optionsArray, id: \.self) { option in
                        // Logic Seleksi
                        let isSelected: Bool = {
                            if qtype == .multipleChoice {
                                return response.dresponse_answer_text
                                    == option.option_text
                            } else {
                                let current =
                                    (response.dresponse_answer_text ?? "")
                                    .components(separatedBy: ",")
                                return current.contains(
                                    option.option_text ?? ""
                                )
                            }
                        }()

                        // Tampilan Row
                        HStack(spacing: 12) {
                            Image(systemName: iconName(for: isSelected))
                                .foregroundColor(
                                    isSelected
                                        ? brandOrange : .gray.opacity(0.5)
                                )
                                .font(.system(size: 20))

                            Text(option.option_text ?? "")
                                .font(.body)
                                .foregroundColor(isSelected ? .black : .primary)

                            Spacer()
                        }
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(
                                    isSelected
                                        ? brandOrange.opacity(0.1) : Color.white
                                )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(
                                    isSelected
                                        ? brandOrange : Color.gray.opacity(0.2),
                                    lineWidth: 1
                                )
                        )
                        .onTapGesture {
                            if !isPreview {
                                handleOptionTap(option: option)
                            }
                        }
                    }
                }

            case .dropdown:
                HStack {
                    Text("Select Answer")
                        .foregroundColor(.secondary)
                    Spacer()
                    Picker(
                        "Choose",
                        selection: Binding(
                            get: { response.dresponse_answer_text ?? "" },
                            set: {
                                if !isPreview {
                                    response.dresponse_answer_text = $0
                                }
                            }
                        )
                    ) {
                        Text("Select...").tag("")
                        ForEach(question.optionsArray, id: \.self) { option in
                            Text(option.option_text ?? "").tag(
                                option.option_text ?? ""
                            )
                        }
                    }
                    .pickerStyle(.menu)
                    .accentColor(brandOrange)
                    .disabled(isPreview)
                }
                .padding()
                .background(Color.gray.opacity(0.05))
                .cornerRadius(8)

            case .linearscale:
                //                VStack(alignment: .leading, spacing: 12) {
                //
                //                    let range = 1...5  // bisa kamu ganti ke 1...10
                //                    let value = Binding<Double>(
                //                        get: {
                //                            Double(response.dresponse_answer_text ?? "") ?? 0
                //                        },
                //                        set: { newVal in
                //                            if !isPreview {
                //                                response.dresponse_answer_text =
                //                                    "\(Int(newVal))"
                //                            }
                //                        }
                //                    )
                //
                //                    Text("Choose a value:")
                //                    Slider(
                //                        value: value,
                //                        in: Double(range.lowerBound)...Double(range.upperBound),
                //                        step: 1
                //                    )
                //                    .disabled(isPreview)
                //
                //                    Text("Selected: \(Int(value.wrappedValue))")
                //                        .foregroundColor(.gray)
                //                }
                let options =
                    (question.has_option as? Set<Option>)?
                    .sorted {
                        ($0.option_text ?? "") < ($1.option_text ?? "")
                    } ?? []

                // Urutkan opsi berdasarkan angka (bukan string)
                let scaleOptions = options.sorted {
                    (Int($0.option_text ?? "0") ?? 0)
                        < (Int($1.option_text ?? "0") ?? 0)
                }

                HStack(spacing: 12) {
                    if scaleOptions.isEmpty {
                        Text("No scale options available")
                            .font(.caption)
                            .foregroundColor(.gray)
                    } else {
                        ForEach(scaleOptions, id: \.option_id) { option in
                            VStack(spacing: 8) {
                                ZStack {
                                    Circle()
                                        .stroke(
                                            Color.gray.opacity(0.4),
                                            lineWidth: 2
                                        )
                                        .background(
                                            Circle().fill(Color.white)
                                        )
                                        .frame(width: 44, height: 44)

                                    Text(option.option_text ?? "?")
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .foregroundColor(darkTeal)
                                }
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)

            }
        }
        .padding(.vertical, 8)

    }

    private func iconName(for isSelected: Bool) -> String {
        if qtype == .multipleChoice {
            return isSelected ? "circle.inset.filled" : "circle"
        } else {
            return isSelected ? "checkmark.square.fill" : "square"
        }
    }

    private func handleOptionTap(option: Option) {
        guard let text = option.option_text else { return }

        if qtype == .multipleChoice {
            response.dresponse_answer_text = text
        } else {
            // Checkbox logic: Comma separated string
            var current = (response.dresponse_answer_text ?? "").components(
                separatedBy: ","
            ).filter { !$0.isEmpty }

            if current.contains(text) {
                current.removeAll { $0 == text }
            } else {
                current.append(text)
            }
            response.dresponse_answer_text = current.joined(separator: ",")
        }
    }

    private func saveSelectedImage() {
        if let img = selectedImage,
            let data = img.jpegData(compressionQuality: 0.8)
        {

            let filename = UUID().uuidString + ".jpg"
            let url = FileManager.default.urls(
                for: .documentDirectory,
                in: .userDomainMask
            )[0]
            .appendingPathComponent(filename)

            do {
                try data.write(to: url)
                question.question_img_url = url.absoluteString
                try context.save()
                print("Image saved!")
            } catch {
                print("Failed saving image: \(error)")
            }
        }
    }

}

struct AsyncLocalImage: View {
    let path: String
    
    var body: some View {
        if let url = URL(string: path),
           let data = try? Data(contentsOf: url),
           let uiImage = UIImage(data: data) {
            
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFit()
        } else {
            // Placeholder jika gagal load
            Rectangle()
                .fill(Color.gray.opacity(0.1))
                .overlay(
                    Image(systemName: "photo")
                        .foregroundColor(.gray)
                )
        }
    }
}
