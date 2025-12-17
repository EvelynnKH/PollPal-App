import CoreData
import SwiftUI

struct SurveyView: View {
    @Environment(\.managedObjectContext) private var context
    @Environment(\.dismiss) var flowDismiss

    @StateObject var vm: SurveyViewModel
    @State private var selectedTab = 0
    @ObservedObject var survey: Survey
    @State private var showingImagePicker = false
    @State private var selectedImage: UIImage?
    let mode: String
    @State private var tempTitle: String = ""

    // State untuk Alert Konfirmasi Finish
    @State private var showFinishAlert = false

    @State private var navigateToDashboard = false
    var onFinishToDashboard: (() -> Void)?
    @State private var shouldExitToDashboard = false


    init(mode: String, survey: Survey?, context: NSManagedObjectContext) {
        self.mode = mode  // <-- SET VALUE

        let surveyToUse: Survey

        if mode == "create" {
            let newSurvey = Survey(context: context)
            newSurvey.survey_id = UUID()
            newSurvey.survey_created_at = Date()
            surveyToUse = newSurvey
        } else {
            surveyToUse = survey!  // <-- untuk edit
        }

        self.survey = surveyToUse

        _vm = StateObject(
            wrappedValue: SurveyViewModel(
                context: context,
                survey: surveyToUse
            )
        )
        self._tempTitle = State(initialValue: surveyToUse.survey_title ?? "")

    }

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {

                // MARK: Header
                VStack(alignment: .leading) {
                    VStack(alignment: .leading) {
                        Text(
                            (survey.survey_title ?? "").isEmpty
                                ? "Untitled Survey"
                                : (survey.survey_title ?? "")
                        )
                        .font(.title)
                        .lineLimit(2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                        // --- LOGIC GANTI TEXT HEADER ---
                        if selectedTab == 0 {
                            Text("Please Add Your Question...")
                                .font(.caption)
                                .foregroundColor(.white)
                        } else {
                            // Hitung total responses dari semua pertanyaan (atau logic lain sesuai kebutuhan)
                            // Disini saya ambil contoh menghitung total HResponse yang terkait survei ini
                            let totalResp = survey.has_hresponse?.count ?? 0
                            Text("Total: \(totalResp) Responses")
                                .font(.caption)
                                .foregroundColor(.white)
                        }
                        // -------------------------------

                        HStack {
                            tabButton(title: "Questions", index: 0)
                            tabButton(title: "Responses", index: 1)
                        }
                        .padding(.bottom, 10)
                    }
                    .padding([.horizontal])
                    .padding(.top, 2)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(hex: "FF9F1C"))

                // MARK: ScrollView Content
                ScrollView {
                    if mode == "published" {
                        // published: hanya boleh tab 1
                        responsesTabContent
                    } else {
                        // create & edit
                        editorTabContent
                            .padding(.top, 10)
                    }
                }.onAppear {
                    selectedTab = (mode == "published") ? 1 : 0
                }
                .onChange(of: selectedTab) { newTab in
                    if mode == "published", newTab != 1 {
                        selectedTab = 1
                    }
                    if mode != "published", newTab != 0 {
                        selectedTab = 0
                    }
                }
            }
            .padding(.bottom, 100)

            // MARK: BOTTOM BAR (Dynamic)
            bottomStickyBar
        }
        // Alert Konfirmasi Finish
        .alert("Finish Survey?", isPresented: $showFinishAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Finish", role: .destructive) {
                vm.closeSurvey()  // Pastikan fungsi ini ada di ViewModel Anda
            }
        } message: {
            Text(
                "This will close the survey. Respondents will no longer be able to submit answers."
            )

        }
        .onChange(of: shouldExitToDashboard) { value in
                if value {
                    flowDismiss()   // 🔥 TUTUP SurveyView → balik ke Dashboard
                }
            }
    }

    // MARK: Tab Button
    private func tabButton(title: String, index: Int) -> some View {
        Button(action: { selectedTab = index }) {
            Text(title)
                .padding(.vertical, 6)
                .padding(.horizontal, 14)
                .foregroundColor(selectedTab == index ? .white : .themeOrange)
                .fontWeight(.bold)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            selectedTab == index ? Color.themeBlue : Color.white
                        )
                        .shadow(
                            color: selectedTab == index
                                ? Color.black.opacity(0.25) : .clear,
                            radius: selectedTab == index ? 6 : 0,
                            y: 3
                        )
                )
        }
    }

    // MARK: Main Editor
    private var editorTabContent: some View {
        VStack(alignment: .leading, spacing: 20) {

            // TITLE + DESCRIPTION
            VStack(alignment: .leading, spacing: 5) {

                ZStack(alignment: .topLeading) {
                    if (survey.survey_title ?? "").isEmpty {
                        Text("Enter Your Survey Title")
                            .foregroundColor(.gray)
                            .lineLimit(2)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 20)
                    }

                    TextEditor(text: $tempTitle)
                        .font(.title)
                        .fontWeight(.semibold)
                        .padding(4)
                        .onChange(of: tempTitle) { newValue in
                            survey.survey_title = newValue
                        }

                }
                .frame(minHeight: 40, maxHeight: 120)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.3))
                )

                ZStack(alignment: .topLeading) {
                    if (survey.survey_description
                        ?? "What is your survey about?").isEmpty
                    {
                        Text("What is your survey about?")
                            .foregroundColor(.gray)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 12)
                    }
                    TextEditor(
                        text: Binding(
                            get: {
                                survey.survey_description
                                    ?? "What is your survey about?"
                            },
                            set: { survey.survey_description = $0 }
                        )
                    )
                    .font(.subheadline)
                    .padding(4)
                }
                .frame(minHeight: 120)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.3))
                )
            }
            .padding(.horizontal)

            // QUESTION LIST
            VStack(spacing: 12) {
                ForEach(vm.questions) { question in
                    QuestionEditorCard(
                        question: question,
                        qtype: Binding(
                            get: { question.safeType },
                            set: { question.safeType = $0 }
                        ),
                        vm: vm
                    )
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 40)

        }
    }

    // MARK: Responses Tab Content
    //    private func responses(for question: Question) -> [DResponse] {
    //        vm.responses.filter { $0.in_question == question }
    //    }

    private var responsesTabContent: some View {
        ScrollView {
            VStack(spacing: 20) {

                ForEach(vm.questions) { question in
                    ResponseRendered(
                        question: question,
                        responses: vm.responsesFor(question)
                    )
                }

            }
            .padding(.vertical)
        }
        .onAppear {
            vm.fetchResponses()  // pastikan selalu refresh
        }
    }

    // MARK: Sticky Bottom Bar
        private var bottomStickyBar: some View {
            VStack(spacing: 0) {
                
                // ---------------------------------------------------------
                // 1. BAGIAN ATAS: TOMBOL NEXT (Melayang / Transparan)
                // ---------------------------------------------------------
                if selectedTab == 0 {
                    HStack {
                        Spacer() // Dorong ke kanan
                        
                        NavigationLink(
                            destination: FinishingSurveyView(
                                vm: vm,
                                onFinishToDashboard: {
                                    shouldExitToDashboard = true
                                },
                                survey: survey,
                                questions: vm.questions
                            )
                        ) {
                            Text("Next")
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .font(.subheadline)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 20)
                                .background(Color(hex: "003F57"))
                                .cornerRadius(12) // Lebih bulat biar cantik saat melayang
                                .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2) // Tambah shadow biar pop-out
                        }
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, 10) // Jarak antara tombol Next dan Area Putih di bawahnya
                }
                
                // ---------------------------------------------------------
                // 2. BAGIAN BAWAH: AREA PUTIH (Add Question / Finish)
                // ---------------------------------------------------------
                VStack {
                    if selectedTab == 0 {
                        // --- TOMBOL ADD QUESTION ---
                        Button(action: {
                            vm.addQuestion(type: .shortAnswer)
                        }) {
                            Text("Add Question")
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color(hex: "FE982A"))
                                .cornerRadius(12)
                                .shadow(color: .black.opacity(0.1), radius: 5, y: 2)
                        }
                    } else {
                        // --- TOMBOL FINISH (Tab Responses) ---
                        if survey.is_public {
                            let responseCount = survey.has_hresponse?.count ?? 0
                            let canFinish = responseCount > 0
                            
                            Button(action: {
                                showFinishAlert = true
                            }) {
                                Text("Finish Survey")
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(Color.red)
                                    .cornerRadius(12)
                                    .shadow(color: .black.opacity(0.1), radius: 5, y: 2)
                            }
                            .disabled(!canFinish)
                        } else {
                            Text("Survey Closed")
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color.gray)
                                .cornerRadius(12)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 35)   // Padding atas di dalam kotak putih
                .padding(.bottom, 20) // Padding bawah (sebelum safe area)
                .background(Color.white) // 🔥 PINDAHKAN BACKGROUND PUTIH KE SINI
                .shadow(radius: 5, x: 0, y: -5)
            }
            .edgesIgnoringSafeArea(.bottom) // Agar kotak putih mentok sampai bawah layar
        }
}
