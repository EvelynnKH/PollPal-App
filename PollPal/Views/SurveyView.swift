import CoreData
import SwiftUI

struct SurveyView: View {
    @Environment(\.managedObjectContext) private var context

    @StateObject var vm: SurveyViewModel
    @State private var selectedTab = 0
    @ObservedObject var survey: Survey
    @State private var showingImagePicker = false
    @State private var selectedImage: UIImage?
    let mode: String
    @State private var tempTitle: String = ""

    // State untuk Alert Konfirmasi Finish
    @State private var showFinishAlert = false

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

                    if selectedTab == 0 {
                        editorTabContent.padding(.top, 10)
                    } else {
                        responsesTabContent
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
            if selectedTab == 0 {
                HStack {
                    Spacer()
                    NavigationLink(
                        destination: FinishingSurveyView(
                            vm: vm,
                            survey: survey,
                            questions: vm.questions
                        )
                    ) {
                        Text("Next")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 20)
                            .background(Color(hex: "003F57"))
                            .cornerRadius(10)
                    }
                    .padding(.trailing, 30)
                    .padding(.bottom, 20)
                }

                HStack {

                    Button(action: {
                        vm.addQuestion(type: .shortAnswer)
                    }) {
                        Text("Add Question")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 15)
                            .background(Color(hex: "FE982A"))
                            .cornerRadius(15)
                            .shadow(color: .black.opacity(0.1), radius: 5, y: 2)
                    }

                }
                .padding(.horizontal, 30)
                .padding(.top, 20)
                //                .padding(.bottom, 30)
                //                .background(Color.white)
                //                .shadow(radius: 10)

            } else {
                HStack {
                    // Cek apakah survei masih publik (aktif)
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
                                .padding(.vertical, 15)
                                .background(Color.red)  // Warna Merah untuk stop
                                .cornerRadius(15)
                                .shadow(
                                    color: .black.opacity(0.1),
                                    radius: 5,
                                    y: 2
                                )
                        }
                        .disabled(!canFinish)  // Matikan tombol jika 0 response


                    } else {
                        // Jika sudah finish/close (opsional)
                        Text("Survey Closed")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 15)
                            .background(Color.gray)
                            .cornerRadius(15)
                    }
                }
                .padding(.horizontal, 30)
                .padding(.top, 20)
            }

        }
        .padding(.bottom, 30)
        .background(Color.white)
        .shadow(radius: 10)
        .edgesIgnoringSafeArea(.bottom)
    }
}
