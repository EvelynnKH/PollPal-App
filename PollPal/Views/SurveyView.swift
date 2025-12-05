import SwiftUI
import CoreData

struct SurveyView: View {
    @Environment(\.managedObjectContext) private var context

    @StateObject var vm: SurveyViewModel
    @State private var selectedTab = 0
    @State var survey: Survey

    init(context: NSManagedObjectContext, survey: Survey) {
        _vm = StateObject(wrappedValue: SurveyViewModel(context: context, survey: survey))
        self._survey = State(initialValue: survey)
    }

    var body: some View {
        ZStack(alignment: .bottom) {

            VStack(spacing: 0) {

                // MARK: Header
                VStack(alignment: .leading) {
                    VStack(alignment: .leading) {
                        Text((survey.survey_title ?? "").isEmpty ? "Untitled Survey" : (survey.survey_title ?? ""))
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)

                        Text("Please Add Your Question...")
                            .font(.caption)
                            .foregroundColor(.white)

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
                        editorTabContent
                    } else {
                        Text("cmn bs dibuka klo udh ada yg ngisi")
                    }

                }

            }
            .padding(.bottom, 100)

            bottomStickyBar

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
                        .fill(selectedTab == index ? Color.themeBlue : Color.white)
                        .shadow(
                            color: selectedTab == index ? Color.black.opacity(0.25) : .clear,
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

                TextEditor(text: Binding(
                    get: { survey.survey_title ?? "" },
                    set: { survey.survey_title = $0 }
                ))
                    .font(.title)
                    .fontWeight(.semibold)
                    .frame(minHeight: 40, maxHeight: 120)
                    .padding(4)
                    .background(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.3)))

                ZStack(alignment: .topLeading) {
                    if (survey.survey_description ?? "").isEmpty {
                        Text("What is your survey about?")
                            .foregroundColor(.gray)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 12)
                    }
                    TextEditor(text: Binding(
                        get: { survey.survey_description ?? "" },
                        set: { survey.survey_description = $0 }
                    ))
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
                        )
                    )
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 40)

        }
    }

    // MARK: Sticky Bottom Bar
    private var bottomStickyBar: some View {
        VStack(spacing: 0) {

            HStack {
                Spacer()
                NavigationLink(
                    destination: FinishingSurveyView(survey: survey, questions: vm.questions)
                ) {
                    Text("Publish")
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

                Button(action: {}) {
                    Text("Add Image")
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
            .padding(.bottom, 30)
            .background(Color.white)
            .shadow(radius: 10)

        }
        .edgesIgnoringSafeArea(.bottom)
    }
}

