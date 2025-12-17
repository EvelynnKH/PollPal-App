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
                ImagePickerForQuestion(selectedImage: $selectedImage)
                    .onDisappear {
                        if let img = selectedImage,
                           let data = img.jpegData(compressionQuality: 0.8) {

                            let filename = UUID().uuidString + ".jpg"
                            let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                                .appendingPathComponent(filename)

                            do {
                                try data.write(to: url)
                                question.question_img_url = url.absoluteString
                                try context.save()
                                print("Image saved to file and URL stored in Core Data")
                            } catch {
                                print("Failed saving image: \(error)")
                            }
                        }
                    }
            }
            
            if let urlString = question.question_img_url,
               let url = URL(string: urlString),
               let data = try? Data(contentsOf: url),
               let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
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
                VStack(alignment: .leading, spacing: 10) {

                    ForEach(question.optionsArray, id: \.self) { option in
                        HStack(spacing: 12) {

                            if qtype == .multipleChoice {

                                RadioButton(
                                    selected: Binding(
                                        get: {
                                            response.dresponse_answer_text ?? ""
                                        },
                                        set: {
                                            if !isPreview {
                                                response.dresponse_answer_text =
                                                    $0
                                            }
                                        }
                                    ),
                                    value: option.option_text ?? ""
                                )

                                Text(option.option_text ?? "")

                            } else {

                                Toggle(
                                    isOn: Binding(
                                        get: {
                                            let arr =
                                                (response.dresponse_answer_text
                                                ?? "")
                                                .components(separatedBy: ",")
                                            return arr.contains(
                                                option.option_text ?? ""
                                            )
                                        },
                                        set: { checked in
                                            if isPreview { return }
                                            var arr =
                                                (response.dresponse_answer_text
                                                ?? "")
                                                .components(separatedBy: ",")
                                            if checked {
                                                arr.append(
                                                    option.option_text ?? ""
                                                )
                                            } else {
                                                arr.removeAll {
                                                    $0 == option.option_text
                                                }
                                            }
                                            response.dresponse_answer_text =
                                                arr.joined(separator: ",")
                                        }
                                    )
                                ) {
                                    Text(option.option_text ?? "")
                                }
                                .disabled(isPreview)
                            }

                            Spacer()

                            if !isPreview {
                                Button {
                                    question.deleteOption(
                                        option,
                                        context: context
                                    )
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
                                text:
                                    "Option \(question.optionsArray.count + 1)",
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
                    ForEach(question.optionsArray, id: \.self) { option in
                        Text(option.option_text ?? "")
                            .tag(option.option_text ?? "")
                    }
                }
                .pickerStyle(.menu)
                .disabled(isPreview)
                
                
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
}
