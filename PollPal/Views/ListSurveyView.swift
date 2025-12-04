import SwiftUI
import CoreData

struct ListSurveyView: View {
    
    // StateObject akan menampung ViewModel
    @StateObject private var viewModel: ListSurveyViewModel
    
    let pageTitle: String
    
    // Custom Init untuk Inject Context
    init(category: String? = nil, searchText: String? = nil) {
            // Tentukan judul halaman
            if let cat = category {
                self.pageTitle = cat // Misal: "Technology"
            } else if let search = searchText {
                self.pageTitle = "Search: \(search)"
            } else {
                self.pageTitle = "All Surveys"
            }
            
            // Siapkan ViewModel dengan filter
            let context = PersistenceController.shared.container.viewContext
            _viewModel = StateObject(wrappedValue: ListSurveyViewModel(
                context: context,
                category: category,
                searchText: searchText
            ))
        }
    
    var body: some View {
        VStack(alignment: .leading) {
            
            Text("Available Surveys")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(Color(hex: "#0C4254"))
                .padding(.leading)
                .padding(.top)
            
            ScrollView {
                VStack(spacing: 18) {
                    
                    if viewModel.surveys.isEmpty {
                        // Tampilan Kosong (Empty State)
                        ContentUnavailableView(
                            "Belum ada Survey",
                            systemImage: "list.clipboard",
                            description: Text("Cek kembali nanti untuk survey terbaru.")
                        )
                        .padding(.top, 50)
                    } else {
                        // Looping Data Core Data
                        ForEach(viewModel.surveys) { survey in
                            NavigationLink {
                                // Nanti arahkan ke detail survey / pengerjaan survey
                                Text("Detail Survey: \(survey.title)")
                            } label: {
                                SurveyAvailableRow(item: survey)
                            }
                        }
                    }
                }
                .padding(.vertical)
            }
            // Fitur tarik ke bawah untuk refresh
            .refreshable {
                viewModel.fetchSurveys()
            }
        }
        .navigationBarBackButtonHidden(false)
        .onAppear {
            // Memastikan data ter-update saat kembali ke halaman ini
            viewModel.fetchSurveys()
        }
    }
}

struct SurveyAvailableRow: View {
    
    // Pastikan ini menggunakan struct AvailableSurvey yang sudah kita update
    let item: AvailableSurvey
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            
            // Category
            Text(item.category)
                .font(.caption)
                .foregroundColor(.gray)
            
            // Title
            Text(item.title)
                .font(.headline)
                // Pastikan extension Color(hex:) ada di project kamu
                .foregroundColor(Color(hex: "#0C4254"))
                .multilineTextAlignment(.leading)
                .lineLimit(2)
                .padding(.bottom, 15)
            
            HStack(spacing: 20) {
                
                // Unwrapping Optional Reward
                if let reward = item.reward, reward > 0 {
                    HStack(spacing: 6) {
                        Image(systemName: "star.fill")
                            .foregroundColor(Color(hex: "#FE982A"))
                        Text("\(reward) pts")
                            .font(.caption)
                            .foregroundColor(Color(hex: "#FE982A"))
                    }
                }
                
                // Unwrapping Optional Estimated Time
                if let time = item.estimatedTime, time > 0 {
                    HStack(spacing: 6) {
                        Image(systemName: "clock")
                            .foregroundColor(.gray)
                        Text("\(time) min")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                
                Spacer()
                
                Text("Start Now →")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(Color(hex: "#FE982A"))
                    .padding(.horizontal)
                    .underline()
            }
        }
        .padding()
        // Mengatur lebar agar konsisten, sesuaikan dengan desainmu
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
        .padding(.horizontal)
    }
}
