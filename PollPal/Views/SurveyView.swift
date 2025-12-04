//import SwiftUI
//
//struct SurveyView: View {
//    @StateObject var vm = SurveyViewModel()
//    @State private var selectedTab = 0
//    @State var survey = Survey()
//
//    var body: some View {
//        ZStack(alignment: .bottom) {
//            VStack(spacing: 0) {
//                // MARK: Header (sticky)
//                VStack(alignment: .leading) {
////                    Button(action: {
////                        print("Back button tapped")
////                    }) {
////                        Text("<< Back")
////                            .font(.headline)
////                            .foregroundColor(Color(hex: "003F57"))
////                    }
////                    .padding(.horizontal)
////                    
//                    VStack(alignment: .leading) {
//                        Text(survey.survey_title.isEmpty ? "Untitled Survey" : survey.survey_title)
//                            .font(.title)
//                            .fontWeight(.bold)
//                            .foregroundColor(.white)
//                        Text("Please Add Your Question...")
//                           .font(.caption)
//                           .foregroundColor(.white)
//                        HStack{
//                            Button(action: { selectedTab = 0 }) {
//                                Text("Questions")
//                                    .padding(.vertical, 6)
//                                    .padding(.horizontal, 14)
//                                    .foregroundColor(selectedTab == 0 ? .white : .themeOrange)
//                                    .fontWeight(.bold)
//                                    .background(
//                                        RoundedRectangle(cornerRadius: 12)
//                                            .fill(selectedTab == 0 ? Color.themeBlue : Color.white)
//                                            .shadow(
//                                                color: selectedTab == 0 ? Color.black.opacity(0.25) : .clear,
//                                                radius: selectedTab == 0 ? 6 : 0,
//                                                x: 0,
//                                                y: 3
//                                            )
//                                    )
//                            }
//                            Button(action: { selectedTab = 1 }) {
//                                Text("Responses")
//                                    .padding(.vertical, 6)
//                                    .padding(.horizontal, 14)
//                                    .foregroundColor(selectedTab == 1 ? .white : .themeOrange)
//                                    .fontWeight(.bold)
//                                    .background(
//                                        RoundedRectangle(cornerRadius: 12)
//                                            .fill(selectedTab == 1 ? Color.themeBlue : Color.white)
//                                            .shadow(
//                                                color: selectedTab == 1 ? Color.black.opacity(0.25) : .clear,
//                                                radius: selectedTab == 1 ? 6 : 0,
//                                                x: 0,
//                                                y: 3
//                                            )
//                                    )
//                            }
//                        }
//                        .padding(.bottom, 10)
//                    }
//                    .padding([.horizontal])
//                    .padding(.top, 2)
//                }
//                .frame(maxWidth: .infinity, alignment: .leading)
//                .background(Color(hex: "FF9F1C"))
//                
//                // MARK: Scrollable content (white background)
//                ScrollView {
//                    if (selectedTab == 0){
//                        VStack(alignment: .leading, spacing: 20) {
//                            VStack(alignment: .leading, spacing: 5) {
//                                // Survey title editor
//                                ZStack(alignment: .topLeading) {
//                                    TextEditor(text: $survey.survey_title)
//                                        .font(.title)
//                                        .fontWeight(.semibold)
//                                        .frame(minHeight: 40, maxHeight: 120)
//                                        .padding(4)
//                                        .background(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.3)))
//                                        .onChange(of: survey.survey_title) { newValue in
//                                            if newValue.count > 50 {
//                                                survey.survey_title = String(newValue.prefix(50))
//                                            }
//                                        }
//                                }
//                                .padding(.top, 10)
//                                
//                                // Survey description editor
//                                ZStack(alignment: .topLeading) {
//                                    if survey.survey_description.isEmpty {
//                                        Text("What is your survey about?")
//                                            .foregroundColor(.gray)
//                                            .padding(.horizontal, 4)
//                                            .padding(.vertical, 12)
//                                    }
//                                    TextEditor(text: $survey.survey_description)
//                                        .font(.subheadline)
//                                        .padding(4)
//                                }
//                                .frame(minHeight: 120)
//                                .background(
//                                    RoundedRectangle(cornerRadius: 12)
//                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
//                                )
//                            }
//                            .padding(.horizontal)
//                            VStack(spacing: 0) {
//                                ForEach($vm.questions) { $q in
//                                    QuestionEditorCard(question: $q)
//                                
//                                }
//                                .padding(5)
//                            }
//                            .padding(.vertical, 20)
//                            .padding(.horizontal, 10)
//                            .background(Color.white)
//                        }
//                    }
//                    else {
//                        Text("cmn bs dibuka klo udh ada yg ngisi")
//                    }
//                }
//                
//            }.padding(.bottom, 100)
//            
//            // MARK: Bottom sticky bar
//            VStack(spacing: 0) {
//                HStack {
//                    Spacer()
//                    NavigationLink(destination: FinishingSurveyView(survey: survey, questions: vm.questions)) {
//                        Text("Publish")
//                            .fontWeight(.bold)
//                            .foregroundColor(.white)
//                            .padding(.vertical, 10)
//                            .padding(.horizontal, 20)
//                            .background(Color(hex: "003F57"))
//                            .cornerRadius(10)
//                    }
//                    .padding(.trailing, 30)
//                    .padding(.bottom, 20)
//                }
//
//
//                HStack {
//                    Button(action: { vm.addQuestion(type: .shortAnswer) }) {
//                        Text("Add Question")
//                            .fontWeight(.bold)
//                            .foregroundColor(.white)
//                            .frame(maxWidth: .infinity)
//                            .padding(.vertical, 15)
//                            .background(Color(hex: "FE982A"))
//                            .cornerRadius(15)
//                            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
//                    }
//                    
//                    Button(action: {}) {
//                        Text("Add Image")
//                            .fontWeight(.bold)
//                            .foregroundColor(.white)
//                            .frame(maxWidth: .infinity)
//                            .padding(.vertical, 15)
//                            .background(Color(hex: "FE982A"))
//                            .cornerRadius(15)
//                            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
//                    }
//                }
//                .padding(.horizontal, 30)
//                .padding(.top, 20)
//                .padding(.bottom, 30)
//                .background(Color.white)
//                .shadow(radius: 10)
//            }
//            .frame(maxWidth: .infinity)
//            .edgesIgnoringSafeArea(.bottom)
//        }
//    }
//}
//
//
//
//#Preview {
//    NavigationStack {
//        SurveyView()
//    }
//}
