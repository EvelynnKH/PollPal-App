import CoreData
import PhotosUI
import SwiftUI

struct FinishingSurveyView: View {
    @Environment(\.managedObjectContext) private var context
    @ObservedObject var vm: SurveyViewModel
    @Environment(\.dismiss) var dismiss

    // MARK: - Color theme
    let orange = Color(red: 254 / 255, green: 152 / 255, blue: 42 / 255)
    let DarkTeal = Color(red: 12 / 255, green: 66 / 255, blue: 84 / 255)

    var onCompletion: (() -> Void)?

    // MARK: - Incoming survey data
    var survey: Survey
    var questions: [Question]

    // MARK: - Category State
    @State private var categoryText: String = ""
    @State private var addedCategories: [String] = []
    @State private var existingCategories: [String] = []

    // MARK: - Image Picker State
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedImage: Image? = nil

    // MARK: - NEW: Target Audience State
    @State private var hasDeadline: Bool = false
    @State private var deadlineDate: Date = Date()

    @State private var selectedGender: String = "All"  // Default
    let genderOptions = ["All", "Male", "Female"]

    @State private var minAge: String = ""
    @State private var maxAge: String = ""

    @State private var domicile: String = ""

    @State private var targetRespondents: String = ""

    // MARK: - Validation Message
    @State private var showValidationError: Bool = false
    @State private var validationMessage: String = ""

    let indonesianProvinces = [
        "All",
        "Aceh", "Sumatera Utara", "Sumatera Barat", "Riau", "Jambi",
        "Sumatera Selatan", "Bengkulu", "Lampung", "Kepulauan Bangka Belitung",
        "Kepulauan Riau",
        "DKI Jakarta", "Jawa Barat", "Jawa Tengah", "DI Yogyakarta",
        "Jawa Timur", "Banten",
        "Bali", "Nusa Tenggara Barat", "Nusa Tenggara Timur",
        "Kalimantan Barat", "Kalimantan Tengah", "Kalimantan Selatan",
        "Kalimantan Timur", "Kalimantan Utara",
        "Sulawesi Utara", "Sulawesi Tengah", "Sulawesi Selatan",
        "Sulawesi Tenggara", "Gorontalo", "Sulawesi Barat",
        "Maluku", "Maluku Utara",
        "Papua Barat", "Papua", "Papua Tengah", "Papua Pegunungan",
        "Papua Selatan", "Papua Barat Daya",
    ].sorted()

    // MARK: - Helpers
    func addCategory() {
        let trimmed = categoryText.trimmingCharacters(
            in: .whitespacesAndNewlines
        )
        if !trimmed.isEmpty && !addedCategories.contains(trimmed) {
            addedCategories.append(trimmed)
            categoryText = ""
        }
    }

    func calculateTotalBaseCost() -> Int {
        var totalCost = 0

        // Iterate through all Question objects associated with the survey
        for question in questions {
            if let typeString = question.question_type,
                // Safely initialize QuestionType using the rawValue (the String from Core Data)
                let type = QuestionType(rawValue: typeString)
            {
                // Add the specific pointCost for that question type
                totalCost += type.pointCost
            } else {
                // Handle error or use a default cost if type is missing/invalid
                print(
                    "⚠️ Unknown question type for question: \(question.question_text ?? "No Text"). Using default cost 10."
                )
                totalCost += 10  // Fallback cost
            }
        }
        return totalCost
    }

    func fetchCategories() {
        let request = NSFetchRequest<NSFetchRequestResult>(
            entityName: "Category"
        )
        do {
            let result = try context.fetch(request) as! [Category]
            existingCategories = result.compactMap { $0.category_name }
        } catch {
            print("Failed to fetch categories:", error)
        }
    }

    func loadExistingData() {
        // 1. Load Categories
        addedCategories =
            survey.has_category?
            .compactMap { ($0 as? Category)?.category_name } ?? []

        // 2. Load Deadline
        if let existingDeadline = survey.survey_deadline {
            hasDeadline = true
            deadlineDate = existingDeadline
        } else {
            hasDeadline = false
        }

        // 3. Load Demographics
        // Pastikan atribut gender tidak nil, jika nil default ke "All"
        selectedGender = survey.survey_gender ?? "All"
        domicile = survey.survey_residence ?? ""

        // Convert Int16/32/64 to String for TextFields (handle 0 as empty)
        if survey.survey_usia_min > 0 {
            minAge = String(survey.survey_usia_min)
        }
        if survey.survey_usia_max > 0 {
            maxAge = String(survey.survey_usia_max)
        }

        selectedGender = survey.survey_gender ?? "All"
        domicile = survey.survey_residence ?? ""

        if survey.survey_usia_min > 0 {
            minAge = String(survey.survey_usia_min)
        }
        if survey.survey_usia_max > 0 {
            maxAge = String(survey.survey_usia_max)
        }

        // TAMBAHAN BARU
        if survey.survey_target_responden > 0 {
            targetRespondents = String(survey.survey_target_responden)
        }
    }

    func isInputValid() -> Bool {
        // 1. Validasi Judul
        // Kita trim whitespace supaya user tidak cuma isi spasi "   "
        let titleToCheck = (survey.survey_title ?? "").trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        if titleToCheck.isEmpty || titleToCheck == "Untitled Survey" {
            validationMessage = "Please enter a valid survey title."
            return false
        }

        // 2. Validasi Kategori
        if addedCategories.isEmpty {
            validationMessage =
                "Please add at least one category so respondents can find your survey."
            return false
        }

        // 3. Validasi Target Responden
        // Cek apakah input kosong atau 0
        let targetCount = Int(targetRespondents) ?? 0
        if targetCount <= 0 {
            validationMessage =
                "Please specify a target number of respondents (must be > 0)."
            return false
        }

        // 4. Validasi Umur (Min > Max)
        let min = Int(minAge) ?? 0
        let max = Int(maxAge) ?? 0

        if max > 0 && min > max {
            validationMessage =
                "Minimum age cannot be greater than maximum age."
            return false
        }

        // 5. Question validation
        if finalTotalPoints <= 0 {
            validationMessage =
                "Your survey has no questions. Please add at least one question before publishing."
            return false
        }

        // Jika lolos semua pengecekan
        return true
    }

    // Fungsi pembantu update data ke object Survey sebelum save
    func updateSurveyData() {

        survey.survey_updated_at = Date()

        // Update Deadline
        survey.survey_deadline = hasDeadline ? deadlineDate : nil

        // Update Demographics
        survey.survey_gender = selectedGender

        survey.survey_usia_min = Int32(minAge) ?? 0
        survey.survey_usia_max = Int32(maxAge) ?? 0

        survey.survey_target_responden = Int32(targetRespondents) ?? 0

        // Save Categories via VM
        vm.saveCategories(addedCategories, for: survey)

        survey.survey_updated_at = Date()

        // Update Deadline
        survey.survey_deadline = hasDeadline ? deadlineDate : nil

        // Update Demographics
        // ... (omitted for brevity) ...

        survey.survey_target_responden = Int32(targetRespondents) ?? 0

        survey.survey_residence = domicile

        // 🔥 NEW/CORRECTED: SET THE FINAL CALCULATED POINTS TO THE SURVEY OBJECT 🔥
        // The Core Data property (survey_points) must hold the value of the view's calculated property (finalTotalPoints)
        survey.survey_points = Int32(finalTotalPoints)  // Assumes survey_points is Int32

        survey.survey_rewards_points = Int32(baseCostPerRespondent)

        // Save Categories via VM
        vm.saveCategories(addedCategories, for: survey)
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
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .padding(.top, 15)
                    .padding(.bottom, 120)
                }
            }
            bottomStickyBar
        }
        .edgesIgnoringSafeArea(.top)
        .onAppear {
            fetchCategories()
            loadExistingData()  // Menggabungkan load category & metadata lain
        }
    }
    // MARK: - COST CALCULATION CONSTANTS & LOGIC
    private let adminFeeRate: Double = 0.30  // 30% Admin Cost

    // 1. Base cost for ONE respondent (Total points required for all questions in the survey)
    var baseCostPerRespondent: Int {
        // Calls the function to sum points based on QuestionType enum
        calculateTotalBaseCost()
    }

    var targetRespondentCount: Int {
        Int(targetRespondents) ?? 0
    }

    // 2. Total Base Cost (Base Cost * Target Respondents)
    var totalBaseCost: Int {
        baseCostPerRespondent * targetRespondentCount
    }

    // 3. Admin Cost (Total Base Cost * 30%)
    var totalAdminCost: Int {
        Int(Double(totalBaseCost) * adminFeeRate)
    }

    // 4. Final Total Points (Base Cost + Admin Cost)
    var finalTotalPoints: Int {
        totalBaseCost + totalAdminCost
    }

    // MARK: - Header
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(
                (survey.survey_title ?? "").isEmpty
                    ? "Untitled Survey" : (survey.survey_title ?? "")
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
        .background(Color(hex: "FF9F1C"))
    }

    // MARK: - Content
    private var contentDetail: some View {
        VStack(alignment: .leading, spacing: 25) {  // Spacing antar section diperbesar sedikit

            // MARK: - CATEGORY SECTION
            VStack(alignment: .leading, spacing: 10) {
                Text("Category")
                    .font(.headline).fontWeight(.bold)

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
                    TextField(
                        "Search For Available Category...",
                        text: $categoryText
                    )
                    .font(.subheadline)
                    Button("Add") { addCategory() }
                        .font(.subheadline.bold())
                        .foregroundColor(.white)
                        .padding(.horizontal, 15)
                        .padding(.vertical, 8)
                        .background(orange)
                        .cornerRadius(10)
                }

                // Auto suggestion (unchanged logic)
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
                        }.frame(maxHeight: 120)
                    }
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(20)
            .shadow(radius: 5)

            // MARK: - TARGET AUDIENCE SECTION (NEW)
            VStack(alignment: .leading, spacing: 15) {
                Text("Target Audience")
                    .font(.headline).fontWeight(.bold)

                // 1. Deadline Toggle & Picker
                VStack(alignment: .leading) {
                    Toggle("Set Survey Deadline", isOn: $hasDeadline)
                        .tint(orange)
                        .font(.subheadline)

                    if hasDeadline {
                        DatePicker(
                            "Select Date",
                            selection: $deadlineDate,
                            in: Date()...,
                            displayedComponents: [.date, .hourAndMinute]
                        )
                        .datePickerStyle(.compact)
                        .font(.subheadline)
                        .transition(.opacity)  // Animasi halus saat muncul
                    }
                }

                Divider()

                // TAMBAHAN BARU: TARGET RESPONDEN INPUT
                VStack(alignment: .leading, spacing: 8) {
                    Text("Target Number of Respondents")  // Label
                        .font(.caption)
                        .foregroundColor(.gray)

                    HStack {
                        TextField("e.g. 100", text: $targetRespondents)
                            .keyboardType(.numberPad)  // Pastikan hanya angka
                            .padding(10)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)

                        Text("People")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }

                Divider()

                // 2. Gender Picker
                VStack(alignment: .leading, spacing: 8) {
                    Text("Target Gender").font(.caption).foregroundColor(.gray)
                    Picker("Gender", selection: $selectedGender) {
                        ForEach(genderOptions, id: \.self) { option in
                            Text(option).tag(option)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Divider()

                // 3. Age Range
                VStack(alignment: .leading, spacing: 8) {
                    Text("Age Range (Years)").font(.caption).foregroundColor(
                        .gray
                    )
                    HStack {
                        TextField("Min", text: $minAge)
                            .keyboardType(.numberPad)
                            .padding(10)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)

                        Text("-")

                        TextField("Max", text: $maxAge)
                            .keyboardType(.numberPad)
                            .padding(10)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                    }
                }

                Divider()

                // 4. Domicile
                VStack(alignment: .leading, spacing: 8) {
                    Text("Target Birth Place")
                        .font(.caption)
                        .foregroundColor(.gray)

                    Menu {
                        ForEach(indonesianProvinces, id: \.self) { province in
                            Button {
                                domicile = province
                            } label: {
                                HStack {
                                    Text(province)
                                    if domicile == province {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        HStack {
                            Text(
                                domicile.isEmpty
                                    ? "Select Birth Place Province" : domicile
                            )
                            .foregroundColor(
                                domicile.isEmpty ? .gray : .primary
                            )

                            Spacer()

                            Image(systemName: "chevron.down")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .padding(10)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                    }
                }

            }
            .padding()
            .background(Color.white)
            .cornerRadius(20)
            .shadow(radius: 5)

            Text("Upload Cover Photo")
                .font(.headline).fontWeight(.bold)
                .padding(.leading, 5)

            // MARK: IMAGE PICKER SECTION
            HStack(spacing: 10) {
                if let img = selectedImage {
                    img.resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 250, height: 150)
                        .cornerRadius(10)
                        .shadow(radius: 3)
                }
                Spacer()
                PhotosPicker(selection: $selectedItem, matching: .images) {
                    Group {
                        if selectedImage == nil {
                            // State 1: No image selected yet
                            Text("Add Image")
                        } else {
                            // State 2: Image is selected, show an icon for 'Change/Edit'
                            HStack(spacing: 5) {
                                Image(systemName: "pencil.circle.fill")  // Use an Edit Icon

                            }
                        }
                    }
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
                            let data = try? await item.loadTransferable(
                                type: Data.self
                            ),
                            let uiImage = UIImage(data: data)
                        else { return }
                        selectedImage = Image(uiImage: uiImage)
                        // TODO: Jangan lupa simpan image ini ke CoreData/Storage nanti
                    }
                }
            }
            .padding(.horizontal)

            costReceiptSection
        }
        .padding(.top, 10)
    }

    // MARK: - Sticky Bottom Bar
    private var bottomStickyBar: some View {
        HStack(spacing: 15) {
            // SAVE
            Button {
                if isInputValid() {
                    updateSurveyData()
                    vm.saveSurvey()
                    try? context.save()
                    onCompletion?()
                    vm.reset()
                    dismiss()
                } else {
                    showValidationError = true  // Munculkan alert
                }
            } label: {
                Text("Save")
                    // ... styling lama
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                    .background(orange)
                    .cornerRadius(15)
            }

            // PUBLISH
            // PUBLISH
            Button {
                if isInputValid() {
                    // 1. Simpan data UI ke CoreData Object
                    updateSurveyData()

                    let pointsRequired = Int(survey.survey_points)

                    // 2. Coba publish (HANYA status survey dan Validasi Poin)
                    let publishSuccessful = vm.publishSurvey()

                    if publishSuccessful {
                        // 🔥 3. JIKA PUBLISH BERHASIL, BARU CATAT TRANSAKSI & KURANGI POIN 🔥
                        vm.recordSurveyCostTransaction(
                            for: survey,
                            cost: pointsRequired
                        )

                        // NOTE: vm.recordSurveyCostTransaction sudah memanggil saveContext()
                        // dan memanggil refresh dashboard via closure.
                        onCompletion?()
                        vm.reset()
                        dismiss()
                    } else {
                        // Jika GAGAL (karena poin tidak cukup atau user not found)
                        let userPoints = survey.owned_by_user?.user_point ?? 0

                        validationMessage = """
                                You do not have enough points to publish this survey.
                                
                                Required: \(pointsRequired) pts
                                Your Points: \(userPoints) pts
                            """
                        showValidationError = true
                    }
                } else {
                    showValidationError = true  // Munculkan alert karena isInputValid() gagal
                }
            } label: {
                // ... (Label dan styling) ...
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
        .alert("Input Error", isPresented: $showValidationError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(validationMessage)
        }
    }

    // MARK: - Cost Receipt Section
    private var costReceiptSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Cost Breakdown")
                .font(.headline).fontWeight(.bold)
                .padding(.bottom, 10)
                .padding(.leading, 5)

            VStack(spacing: 6) {
                // Row 1: Cost per Respondent (Base Cost)

                HStack {
                    Text("Base Cost per Respondent")
                        .font(.headline)
                    Spacer()
                    Text("\(baseCostPerRespondent) pts")
                        .font(.headline).fontWeight(.medium)
                }

                Divider()

                // Row 2: Survey Cost Calculation
                HStack {
                    Text(
                        "Survey Cost (\(targetRespondentCount) x \(baseCostPerRespondent) pts)"
                    )
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    Spacer()
                    Text("\(totalBaseCost) pts")
                        .font(.subheadline).fontWeight(.medium)
                }

                // Row 3: Admin Cost
                HStack {
                    Text("Admin Fee (\(Int(adminFeeRate * 100))%)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(totalAdminCost) pts")
                        .font(.subheadline).fontWeight(.medium)
                }

                Divider()

                // Final Row: Total
                HStack {
                    Text("Total Payment Points")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(orange)
                    Spacer()
                    Text("\(finalTotalPoints) pts")
                        .font(.subheadline)
                        .fontWeight(.heavy)
                        .foregroundColor(orange)
                }
            }
            .padding()
            .padding(.top, 5)
            // *** START MODIFICATION HERE ***
            // Apply the same styling as other sections: White background, corner radius, and shadow.
            .background(Color.white)
            .cornerRadius(20)  // Use 20 for consistency with other sections
            .shadow(radius: 5)  // Use the same shadow
            // Remove the overlay/stroke and the outer orange background
            // *** END MODIFICATION HERE ***
        }
        .padding(.vertical, 10)  // Small vertical padding to separate it from the next section (which is the bottom bar)
        // Remove the outer background and corner radius to let the inner Vstack handle the card styling
    }
}
