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
                                SurveyDetailView(survey: survey.originEntity)
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
    
    let item: AvailableSurvey
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            
            // MARK: - Header (Category & Deadline)
            HStack {
                // Kategori (Kiri)
                Text(item.category)
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Spacer()
                
                // Deadline (Kanan Atas) - PERUBAHAN DISINI
                if let _ = item.deadline {
                    HStack(spacing: 4) {
                        Text("Until: \(item.formattedDeadline)")
                            .font(.caption2)
                            .fontWeight(.medium)
                    }
                    // Jika expired warnanya merah, jika tidak abu-abu
                    .foregroundColor(item.isExpired ? .red : .gray)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.gray.opacity(0.1)) // Background tipis biar rapi
                    .cornerRadius(8)
                }
            }
            
            // Title
            Text(item.title)
                .font(.headline)
                .foregroundColor(Color(hex: "#0C4254"))
                .multilineTextAlignment(.leading)
                .lineLimit(2)
                .padding(.bottom, 5) // Jarak sedikit dikurangi biar compact
            
            // MARK: - Footer (Points, Time, Button)
            HStack(spacing: 20) {
                
                // Reward Points (Dari Core Data)
                if let reward = item.reward, reward > 0 {
                    HStack(spacing: 6) {
                        Image(systemName: "star.fill")
                            .foregroundColor(Color(hex: "#FE982A"))
                        Text("\(reward) pts")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(Color(hex: "#FE982A"))
                    }
                }
                
                // Estimated Time (Tidak Dihapus)
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
                
                // Start Button Label
                Text("Start Now →")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(Color(hex: "#FE982A"))
                    .underline()
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
        .padding(.horizontal)
    }
}
