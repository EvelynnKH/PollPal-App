//
//  AllSurveyCreatorView.swift
//  PollPal
//
//  Created by student on 08/12/25.
//

import CoreData
import SwiftUI

struct AllSurveyCreatorView: View {
    //    @State private var selectedFilter: FilterType = .all
    //    @State private var search = ""

    @Environment(\.managedObjectContext) private var context
    @StateObject var vm: AllSurveyCreatorViewModel

    init(context: NSManagedObjectContext, currentUser: User) {
        _vm = StateObject(
            wrappedValue: AllSurveyCreatorViewModel(
                context: context,
                currentUser: currentUser
            )
        )
    }

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()

            VStack(spacing: 0) {

                TextField("Search...", text: $vm.searchText)
                    .padding(.horizontal)
                    .frame(height: 44)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.gray.opacity(0.15))
                    )
                    .padding(.horizontal)
                    .padding(.top, 12)

                // MARK: - Filter Tabs
                HStack(spacing: 12) {
                    FilterButton(
                        title: "All",
                        isActive: vm.selectedFilter == .all
                    ) {
                        vm.selectedFilter = .all
                    }
                    FilterButton(
                        title: "Published",
                        isActive: vm.selectedFilter == .published
                    ) {
                        vm.selectedFilter = .published
                    }
                    FilterButton(
                        title: "Finished",
                        isActive: vm.selectedFilter == .finished
                    ) {
                        vm.selectedFilter = .finished
                    }
                    FilterButton(
                        title: "Draft",
                        isActive: vm.selectedFilter == .draft
                    ) {
                        vm.selectedFilter = .draft
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 16)

                // MARK: - List Cards
                ScrollView {
                    VStack(spacing: 20) {
                        ForEach(vm.filteredSurveys, id: \.self) { survey in
                            SurveyCardView(
                                //                                status: surveyStatus(survey),
                                //                                title: survey.survey_title ?? "Untitled",
                                //                                description: survey.survey_description ?? "-",
                                //                                date: formatDate(survey.survey_created_at),
                                //                                tags: survey.categories.map { $0.category_name ?? "" },
                                //                                actionText: "View More..",
                                //                                isDisabled: false

                                status: surveyStatus(survey),
                                title: survey.survey_title ?? "Untitled",
                                description: survey.survey_description ?? "-",
                                date: formatDate(survey.survey_created_at),
                                tags: (survey.has_category?.allObjects
                                    as? [Category])?.compactMap {
                                        $0.category_name
                                    } ?? [],
                                actionText: "View More..",
                                isDisabled: false
                            )
                        }
                    }
                    .padding(.horizontal)
                }

                Spacer()
            }
        }
    }
    // Helpers
    func surveyStatus(_ survey: Survey) -> String {
        survey.survey_status_del ? "Finished" : "Published"
    }

    //      func surveyTags(_ survey: Survey) -> [String] {
    //          if let categories = survey.has_category as? Set<Category> {
    //              return categories.map { $0.category_name ?? "" }
    //          }
    //          return []
    //      }

    func surveyTags(_ survey: Survey) -> [String] {
        (survey.has_category?.allObjects as? [Category])?.compactMap {
            $0.category_name
        } ?? []
    }

    func formatDate(_ date: Date?) -> String {
        guard let date else { return "-" }
        let f = DateFormatter()
        f.dateFormat = "dd MMM yyyy"
        return f.string(from: date)
    }

}

// MARK: - Components
struct FilterButton: View {
    let title: String
    let isActive: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.bold())
                .foregroundColor(isActive ? .white : Color.orange)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(isActive ? Color.orange : Color.white)
                        .shadow(
                            color: .black.opacity(0.15),
                            radius: 4,
                            x: 0,
                            y: 2
                        )
                )
        }
    }
}
struct SurveyCardView: View {
    let status: String
    let title: String
    let description: String
    let date: String
    let tags: [String]
    let actionText: String
    let isDisabled: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {

            HStack {
                Text(status)
                    .font(.subheadline.bold())
                    .foregroundColor(.orange)
                Spacer()
                Text(date)
                    .font(.subheadline)
                    .foregroundColor(.orange)
            }

            Text(title)
                .font(.title3.bold())
                .foregroundColor(Color(hex: "1F3A45"))

            Text(description)
                .font(.subheadline)
                .foregroundColor(Color(hex: "1F3A45").opacity(0.9))

            // Tags
            HStack {
                ForEach(tags, id: \.self) { tag in
                    Text(tag)
                        .font(.caption.bold())
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Capsule().fill(Color(hex: "1F3A45")))
                }
            }

            HStack {
                Text("👁 5000")
                    .font(.caption)
                    .foregroundColor(.orange)
                Text("✅ 1293")
                    .font(.caption)
                    .foregroundColor(.green)

                Spacer()

                Text(actionText)
                    .font(.headline)
                    .foregroundColor(isDisabled ? .gray : .orange)
                    .underline()
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.15), radius: 6, x: 0, y: 4)
        )
    }
}
struct TabBarItem: View {
    let icon: String
    let title: String
    let isActive: Bool

    var body: some View {
        VStack {
            Image(systemName: icon)
                .font(.title2)
            Text(title)
                .font(.caption)
        }
        .foregroundColor(isActive ? Color(hex: "1F3A45") : .white)
    }
}
// MARK: - Filter Enum
enum FilterType {
    case all
    case published
    case finished
    case draft
}

//#Preview {
//    AllSurveyCreatorView()
//}
