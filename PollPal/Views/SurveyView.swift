//import SwiftUI
//import CoreData
//
//struct SurveyView: View {
//    @Environment(\.managedObjectContext) private var context
//    
//    @StateObject var vm: SurveyViewModel
//    @State private var selectedTab = 0
//    
//    // Gunakan binding agar Survey bisa diedit
//    @State var survey: Survey
//    
//    init(survey: Survey, context: NSManagedObjectContext) {
//        _survey = State(initialValue: survey)
//        _vm = StateObject(wrappedValue: SurveyViewModel(context: context, survey: survey))
//    }
//    
//    var body: some View {
//        ZStack(alignment: .bottom) {
//            VStack(spacing: 0) {
//                
//                // HEADER
//                VStack(alignment: .leading) {
//                    Text((survey.survey_title ?? "").isEmpty ? "Untitled Survey" : (survey.survey_title ?? ""))
//                        .font(.title)
//                        .fontWeight(.bold)
//                        .foregroundColor(.white)
//                    
//                    Text("Please Add Your Question...")
//                        .font(.caption)
//                        .foregroundColor(.white)
//                    
//                    HStack {
//                        Button(action: { selectedTab = 0 }) {
//                            Text("Questions")
//                                .padding(.vertical, 6)
//                                .padding(.horizontal, 14)
//                                .foregroundColor(selectedTab == 0 ? .white : .themeOrange)
//                                .background(
//                                    RoundedRectangle(cornerRadius: 12)
//                                        .fill(selectedTab == 0 ? Color.themeBlue : Color.white)
//                                )
//                        }
//                        
//                        Button(action: { selectedTab = 1 }) {
//                            Text("Responses")
//                                .padding(.vertical, 6)
//                                .padding(.horizontal, 14)
//                                .foregroundColor(selectedTab == 1 ? .white : .themeOrange)
//                                .background(
//                                    RoundedRectangle(cornerRadius: 12)
//                                        .fill(selectedTab == 1 ? Color.themeBlue : Color.white)
//                                )
//                        }
//                    }
//                    .padding(.bottom, 10)
//                }
//                .padding(.horizontal)
//                .padding(.top, 2)
//                .background(Color(hex: "FF9F1C"))
//                
//                // CONTENT
//                ScrollView {
//                    if selectedTab == 0 {
//                        contentQuestions
//                    } else {
//                        Text("Responses will appear here after someone answers.")
//                    }
//                }
//            }
//            .padding(.bottom, 100)
//            
//            bottomBar
//        }
//    }
//    
//    
//    private var contentQuestions: some View {
//        VStack(alignment: .leading, spacing: 20) {
//            
//            // TITLE + DESC
//            VStack(alignment: .leading, spacing: 5) {
//                TextEditor(
//                    text: Binding(
//                        get: { survey.survey_title ?? "" },
//                        set: { survey.survey_title = $0 }
//                    )
//                )
//                    .font(.title)
//                    .frame(minHeight: 40, maxHeight: 120)
//                    .background(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.3)))
//                
//                ZStack(alignment: .topLeading) {
//                    if (survey.survey_description ?? "").isEmpty {
//                        Text("What is your survey about?")
//                            .foregroundColor(.gray)
//                            .padding(.vertical, 12)
//                    }
//                    TextEditor(
//                        text: Binding(
//                            get: { survey.survey_description ?? "" },
//                            set: { survey.survey_description = $0 }
//                        )
//                    )
//                }
//                .frame(minHeight: 120)
//                .background(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.3)))
//            }
//            .padding(.horizontal)
//            
//            // QUESTION LIST
//            VStack(spacing: 0) {
//                ForEach($vm.questions) { $q in
//                    QuestionRenderer(question: $q, mode: .creator)
//                }
//                .padding(5)
//            }
//            .padding(.vertical, 20)
//            .padding(.horizontal, 10)
//        }
//    }
//    
//    
//    private var bottomBar: some View {
//        VStack(spacing: 0) {
//            
//            HStack {
//                Spacer()
//                NavigationLink(destination: FinishingSurveyView(survey: survey, questions: vm.questions)) {
//                    Text("Publish")
//                        .fontWeight(.bold)
//                        .foregroundColor(.white)
//                        .padding(.vertical, 10)
//                        .padding(.horizontal, 20)
//                        .background(Color(hex: "003F57"))
//                        .cornerRadius(10)
//                }
//                .padding(.trailing, 30)
//                .padding(.bottom, 20)
//            }
//            
//            HStack {
//                Button(action: { vm.addQuestion(type: "short") }) {
//                    Text("Add Question")
//                        .fontWeight(.bold)
//                        .foregroundColor(.white)
//                        .frame(maxWidth: .infinity)
//                        .padding(.vertical, 15)
//                        .background(Color(hex: "FE982A"))
//                        .cornerRadius(15)
//                }
//                
//                Button(action: {}) {
//                    Text("Add Image")
//                        .fontWeight(.bold)
//                        .foregroundColor(.white)
//                        .frame(maxWidth: .infinity)
//                        .padding(.vertical, 15)
//                        .background(Color(hex: "FE982A"))
//                        .cornerRadius(15)
//                }
//            }
//            .padding(.horizontal, 30)
//            .padding(.top, 20)
//            .padding(.bottom, 30)
//            .background(Color.white)
//            .shadow(radius: 10)
//        }
//    }
//}
