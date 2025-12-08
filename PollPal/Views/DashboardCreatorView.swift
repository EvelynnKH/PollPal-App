import CoreData
////
////  DashboardCreatorView.swift
////  PollPal
////
////  Created by student on 01/12/25.
////
//
import SwiftUI

struct DashboardCreatorView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var vm: DashboardCreatorViewModel
    @State private var navigationPath: [String] = []
    @ObservedObject private var viewModel: DashboardViewModel
    @State private var tempSurvey: Survey?
    init(context: NSManagedObjectContext) {
        // StateObject
        _vm = StateObject(
            wrappedValue: DashboardCreatorViewModel(context: context)
        )
        // default values untuk property lain:
        _navigationPath = State(initialValue: [])
        // viewModel HARUS di-init juga
        self.viewModel = DashboardViewModel(context: context)
    }
    var body: some View {
        NavigationStack(path: $navigationPath) {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // MARK: - HEADER
                    Text("Hello, \(viewModel.userName ?? "Creator")")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(Color(hex: "1F3A45"))
                    // MARK: - STATS ROW
                    HStack(spacing: 5) {
                        StatCardView(
                            number: "\(vm.totalResponses)",
                            label: "Responses"
                        )
                        StatCardView(
                            number: "\(vm.allSurveys)",
                            label: "All Surveys",
                            showMore: true,
                            onMoreTap: {
                                navigationPath.append("AllSurveyCreatorView")
                            }
                        )
                        StatCardView(
                            number: "\(vm.points)",
                            label: "Points",
                            showMore: true,
                            onMoreTap: {
                                navigationPath.append("pointsPage")
                            }
                        )
                    }
                    // MARK: - ACTION BUTTONS
                    HStack(spacing: 10) {
                        NavigationLink(
                            destination: {
                                if let s = tempSurvey {
                                    SurveyView(
                                        mode: "create",
                                        survey: s,
                                        context: viewContext
                                    )
                                } else {
                                    EmptyView()
                                }
                            }
                        ) {
                            ActionButton(
                                icon: "plus",
                                text: "Create New Survey"
                            )
                        }
                        .simultaneousGesture(
                            TapGesture().onEnded {
                                let s = Survey(context: viewContext)
                                s.survey_id = UUID()
                                s.survey_created_at = Date()
                                s.survey_status_del = false
                                s.is_public = false
                                tempSurvey = s
                            }
                        )
                        ActionButton(icon: "bell", text: "Notifications (23)")
                    }
                    // MARK: - ACTIVE SURVEYS
                    Text("Active Surveys")
                        .font(.title2.bold())
                        .foregroundColor(Color(hex: "1F3A45"))
                    VStack(spacing: 16) {
                        ForEach(vm.activeSurveys, id: \.self) { survey in
                            ActiveSurveyCard(
                                title: survey.survey_title ?? "Untitled",
                                responses: vm.totalResponses ?? 0
                            )
                        }
                    }
                    .padding()
                    .background(Color.orange)
                    .cornerRadius(28)
                    // MARK: - DRAFTS
                    Text("Drafts")
                        .font(.title2.bold())
                        .foregroundColor(Color(hex: "1F3A45"))
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(vm.draftSurveys, id: \.self) { survey in
                                DraftCard(
                                    title: survey.survey_title ?? "Untitled",
                                    subtitle: "(Draft)"
                                )
                            }
                        }
                    }
                    Spacer()
                }
                .padding(.horizontal)
            }
            .navigationDestination(for: String.self) { route in
                switch route {
                case "AllSurveyCreatorView":
                    AllSurveyCreatorView(
                        context: viewContext,
                        currentUser: vm.user!
                    )
                case "pointsPage":
                    Text("Points Detail Page")  // <-- ganti nanti
                default:
                    EmptyView()
                }
            }
        }
    }
}
// MARK: - COMPONENTS
//
// STAT CARD
struct StatCardView: View {
    var number: String
    var label: String
    var showMore: Bool = false
    var onMoreTap: (() -> Void)? = nil
    var body: some View {
        VStack(spacing: 6) {
            Text(label)
                .font(.system(size: 16))
                .foregroundColor(.gray)
            Text(number)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(Color(hex: "1F3A45"))
            // only appears for All Survey & Points
            if showMore {
                Button(action: {
                    onMoreTap?()
                }) {
                    Text("View More..")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color.blue)
                        .underline()
                }
                .padding(.top, 2)
            }
        }
        .frame(width: 120, height: 110)
        .background(Color(.systemGray5))
        .cornerRadius(16)
    }
}
// ACTION BUTTON
struct ActionButton: View {
    var icon: String
    var text: String
    var body: some View {
        VStack(alignment: .leading) {
            HStack(spacing: 25) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                Text(text)
                    .font(.system(size: 18, weight: .semibold))
            }
            .foregroundColor(.white)
            .padding(.vertical, 14)
            .padding(.horizontal, 12)
            .background(Color(hex: "1F3A45"))
            .cornerRadius(18)
        }
    }
}
// ACTIVE SURVEY CARD
struct ActiveSurveyCard: View {
    var title: String
    var responses: Int
    var body: some View {
        HStack {
            Image(systemName: "doc.text.fill")
                .foregroundColor(Color(hex: "1F3A45"))
            Text(title)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(Color(hex: "1F3A45"))
            Spacer()
            Text("\(responses) Responses")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(Color(hex: "1F3A45"))
        }
        .padding()
        .background(Color.white)
        .cornerRadius(22)
    }
}
// DRAFT CARD
struct DraftCard: View {
    var title: String
    var subtitle: String
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 22, weight: .semibold))
                .foregroundColor(Color(hex: "1F3A45"))
            Text(subtitle)
                .font(.system(size: 16))
                .foregroundColor(.gray)
        }
        .padding(24)
        .frame(width: 175, height: 140, alignment: .topLeading)
        .background(Color.white)
        .cornerRadius(22)
        .shadow(color: .gray.opacity(0.3), radius: 6, x: 2, y: 4)
    }
}
