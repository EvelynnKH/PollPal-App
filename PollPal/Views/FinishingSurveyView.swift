import CoreData
import PhotosUI
import SwiftUI

struct FinishingSurveyView: View {
    @Environment(\.managedObjectContext) private var context
    @ObservedObject var vm: SurveyViewModel
    @Environment(\.dismiss) var dismiss

    // MARK: - Color theme
    let orange = Color(red: 254/255, green: 152/255, blue: 42/255)
    let DarkTeal = Color(red: 12/255, green: 66/255, blue: 84/255)

    // MARK: - Incoming survey data
    var survey: Survey
    var questions: [Question]

    // MARK: - Category State
    @State private var categoryText: String = ""
    @State private var addedCategories: [String] = []
    @State private var existingCategories: [String] = []

    // MARK: - Image Picker
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedImage: Image? = nil

    @State private var expandToTen = false

    // MARK: - Helpers
    func addCategory() {
        let trimmed = categoryText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty && !addedCategories.contains(trimmed) {
            addedCategories.append(trimmed)
            categoryText = ""
        }
    }

    func fetchCategories() {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Category")
        do {
            let result = try context.fetch(request) as! [Category]
            existingCategories = result.compactMap { $0.category_name }
        } catch {
            print("Failed to fetch categories:", error)
        }
    }
    
    func loadExistingCategoriesForEdit() {
        addedCategories = survey.has_category?
            .compactMap { ($0 as? Category)?.category_name } ?? []
    }


    // MARK: - Body
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                headerSection

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        contentDetail
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)   // ⬅ FULL WIDTH
                    .padding(.horizontal)                               // ⬅ PADDING DI SINI
                    .padding(.top, 15)
                    .padding(.bottom, 120)                              // ⬅ SUPAYA TIDAK KETUTUP STICKY BAR
                }
            }
            bottomStickyBar
        }
        .edgesIgnoringSafeArea(.top)
        .onAppear {
            fetchCategories()
            loadExistingCategoriesForEdit() }
    }

    // MARK: - Header
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 6) {

            Text(
                (survey.survey_title ?? "").isEmpty
                    ? "Untitled Survey"
                    : (survey.survey_title ?? "")
            )
            .font(.title)
            .fontWeight(.bold)
            .foregroundColor(.white)

            Text("Please Fill In The Remaining Information...")
                .font(.caption)
                .foregroundColor(.white)

        }
        .padding(.horizontal)
        .padding(.top, 150)
        .padding(.bottom, 15)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(hex: "FF9F1C"))   // sama persis seperti SurveyView
    }


    // MARK: - Content
    private var contentDetail: some View {
        VStack(alignment: .leading, spacing: 20) {

//            // MARK: PREVIEW SECTION
//            VStack(alignment: .leading, spacing: 5) {
//                Text((survey.survey_title ?? "").isEmpty ? "Untitled Survey" : (survey.survey_title ?? ""))
//                    .font(.title)
//                    .fontWeight(.semibold)
//
//                Text("Preview")
//                    .foregroundColor(.gray)
//                    .font(.subheadline)
//
//                let initialLimit = 5
//                let expandedLimit = 10
//                let currentLimit = expandToTen ? expandedLimit : initialLimit
//
//                let limitedQuestions = Array(questions.prefix(currentLimit))
//
//                ForEach(Array(limitedQuestions.enumerated()), id: \.element.objectID) { index, q in
//                    Text("\(index + 1). \(q.question_text ?? "Untitled Question")")
//                        .fontWeight(.bold)
//                }
//
//                if !expandToTen && questions.count > initialLimit {
//                    Button("See more…") {
//                        withAnimation { expandToTen = true }
//                    }
//                    .font(.caption)
//                    .foregroundColor(.blue)
//                }
//
//            }
//            .padding(.horizontal)

            // MARK: - CATEGORY SECTION
            VStack(alignment: .leading, spacing: 10) {
                Text("Category")
                    .font(.headline)
                    .fontWeight(.bold)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(addedCategories, id: \.self) { cat in
                            HStack(spacing: 5) {
                                Text(cat)
                                    .font(.subheadline)
                                    .foregroundColor(.white)

                                Image(systemName: "xmark")
                                    .resizable()
                                    .frame(width: 8, height: 8)
                                    .foregroundColor(.white)
                            }
                            .padding(.horizontal, 15)
                            .padding(.vertical, 8)
                            .background(DarkTeal)
                            .cornerRadius(10)
                            .onTapGesture {
                                addedCategories.removeAll { $0 == cat }
                            }
                        }
                    }
                }

                // Input + Add button
                HStack {
                    TextField("Search For Available Category...", text: $categoryText)
                        .font(.subheadline)

                    Button("Add") { addCategory() }
                        .font(.subheadline.bold())
                        .foregroundColor(.white)
                        .padding(.horizontal, 15)
                        .padding(.vertical, 8)
                        .background(orange)
                        .cornerRadius(10)
                }

                // Auto suggestion
                if !categoryText.isEmpty {
                    let filtered = existingCategories.filter {
                        $0.lowercased().contains(categoryText.lowercased())
                    }

                    if !filtered.isEmpty {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 5) {
                                ForEach(filtered, id: \.self) { item in
                                    Text(item)
                                        .padding(8)
                                        .background(Color.gray.opacity(0.1))
                                        .cornerRadius(5)
                                        .onTapGesture {
                                            if !addedCategories.contains(item) {
                                                addedCategories.append(item)
                                            }
                                            categoryText = ""
                                        }
                                }
                            }
                        }
                        .frame(maxHeight: 120)
                    }
                }

                Divider()

            }
            .padding()
            .background(Color.white)
            .cornerRadius(20)
            .shadow(radius: 5)

            // MARK: IMAGE PICKER SECTION
            HStack(spacing: 15) {
                if let img = selectedImage {
                    img.resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 230, height: 150)
                        .cornerRadius(10)
                        .shadow(radius: 3)
                }

                Spacer()

                PhotosPicker(selection: $selectedItem, matching: .images) {
                    Text(selectedImage == nil ? "Add Image" : "Change")
                        .font(.caption.bold())
                        .padding(.vertical, 8)
                        .padding(.horizontal, 15)
                        .background(DarkTeal)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .onChange(of: selectedItem) {
                    Task {
                        guard let item = selectedItem,
                              let data = try? await item.loadTransferable(type: Data.self),
                              let uiImage = UIImage(data: data)
                        else { return }

                        selectedImage = Image(uiImage: uiImage)
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.top, 10)
    }

    // MARK: - Sticky Bottom Bar
    private var bottomStickyBar: some View {
        HStack(spacing: 15) {

            // SAVE
            Button {
                survey.survey_updated_at = Date()
                vm.saveCategories(addedCategories, for: survey)
                vm.saveSurvey()
                try? context.save()
                vm.reset()
                dismiss()
            } label: {
                Text("Save")
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                    .background(orange)
                    .cornerRadius(15)
            }

            // PUBLISH
            Button {
                survey.is_public = true
                survey.survey_updated_at = Date()
                vm.saveCategories(addedCategories, for: survey)
                vm.publishSurvey()
                try? context.save()
                vm.reset()
                dismiss()
            } label: {
                Text("Publish")
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                    .background(orange)
                    .cornerRadius(15)
            }

        }
        .padding(.horizontal, 20)
        .padding(.vertical, 25)
        .background(Color.white)
        .shadow(radius: 10)
    }
}
