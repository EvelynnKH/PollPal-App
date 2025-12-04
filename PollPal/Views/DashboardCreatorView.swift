////
////  DashboardCreatorView.swift
////  PollPal
////
////  Created by student on 01/12/25.
////
//
//import SwiftUI
//struct DashboardCreatorView: View {
//    var body: some View {
//        ScrollView {
//            VStack(alignment: .leading, spacing: 24) {
//                
//                // MARK: - HEADER
//                Text("Hello, Feli")
//                    .font(.system(size: 36, weight: .bold))
//                    .foregroundColor(Color(hex: "1F3A45"))
//                
//                
//                // MARK: - STATS ROW
//                HStack(spacing: 5) {
//                    StatCardView(number: "200", label: "Responses")
//                    StatCardView(number: "2", label: "Active Surveys")
//                    StatCardView(number: "4500", label: "Points")
//                }
//                
//                // MARK: - ACTION BUTTONS
//                HStack(spacing: 10) {
//                    NavigationLink(destination: SurveyView()) {
//                            ActionButton(icon: "plus", text: "Create New Survey")
//                        }
//                    ActionButton(icon: "bell", text: "Notifications (23)")
//                }
//                
//                
//                // MARK: - ACTIVE SURVEYS
//                Text("Active Surveys")
//                    .font(.title2.bold())
//                    .foregroundColor(Color(hex: "1F3A45"))
//                
//                VStack(spacing: 16) {
//                    ActiveSurveyCard(title: "Nostimo Feedback...", responses: 120)
//                    ActiveSurveyCard(title: "Nostimo Feedback...", responses: 45)
//                }
//                .padding()
//                .background(Color.orange)
//                .cornerRadius(28)
//                
//                
//                // MARK: - DRAFTS
//                Text("Drafts")
//                    .font(.title2.bold())
//                    .foregroundColor(Color(hex: "1F3A45"))
//                
//                HStack(spacing: 16) {
//                    DraftCard(title: "Gen-Z Favorite Food",
//                              subtitle: "(Cost: 1000 pts)")
//                    
//                    DraftCard(title: "Cooking Mama Survey",
//                              subtitle: "(Draft)")
//                }
//                
//                Spacer()
//            }
//            .padding(.horizontal)
//        }
//    }
//}
////
//// MARK: - COMPONENTS
////
//// STAT CARD
//struct StatCardView: View {
//    var number: String
//    var label: String
//    
//    var body: some View {
//        VStack(spacing: 4) {
//            Text(number)
//                .font(.system(size: 28, weight: .bold))
//                .foregroundColor(Color(hex: "1F3A45"))
//            Text(label)
//                .font(.system(size: 16))
//                .foregroundColor(.gray)
//        }
//        .frame(width: 120, height: 85)
//        .background(Color(.systemGray5))
//        .cornerRadius(16)
//    }
//}
//// ACTION BUTTON
//struct ActionButton: View {
//    var icon: String
//    var text: String
//    
//    var body: some View {
//        VStack (alignment: .leading){
//            HStack(spacing: 25) {
//                Image(systemName: icon)
//                    .font(.system(size: 18, weight: .semibold))
//                Text(text)
//                    .font(.system(size: 18, weight: .semibold))
//            }
//            .foregroundColor(.white)
//            .padding(.vertical, 14)
//            .padding(.horizontal, 12)
//            .background(Color(hex: "1F3A45"))
//            .cornerRadius(18)
//        }
//        }
//}
//// ACTIVE SURVEY CARD
//struct ActiveSurveyCard: View {
//    var title: String
//    var responses: Int
//    
//    var body: some View {
//        HStack {
//            Image(systemName: "doc.text.fill")
//                .foregroundColor(Color(hex: "1F3A45"))
//            
//            Text(title)
//                .font(.system(size: 18, weight: .semibold))
//                .foregroundColor(Color(hex: "1F3A45"))
//            
//            Spacer()
//            
//            Text("\(responses) Responses")
//                .font(.system(size: 18, weight: .semibold))
//                .foregroundColor(Color(hex: "1F3A45"))
//        }
//        .padding()
//        .background(Color.white)
//        .cornerRadius(22)
//    }
//}
//// DRAFT CARD
//struct DraftCard: View {
//    var title: String
//    var subtitle: String
//    
//    var body: some View {
//        VStack(alignment: .leading, spacing: 6) {
//            Text(title)
//                .font(.system(size: 22, weight: .semibold))
//                .foregroundColor(Color(hex: "1F3A45"))
//            
//            Text(subtitle)
//                .font(.system(size: 16))
//                .foregroundColor(.gray)
//        }
//        .padding(24)
//        .frame(width: 175, height: 140, alignment: .topLeading)
//        .background(Color.white)
//        .cornerRadius(22)
//        .shadow(color: .gray.opacity(0.3), radius: 6, x: 2, y: 4)
//    }
//}
//#Preview {
//    NavigationStack{
//        DashboardCreatorView()
//    }
//}
