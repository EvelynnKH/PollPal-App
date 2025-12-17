//
//  DashboardRView.swift
//  PollPal
//
//  Created by student on 01/12/25.
//

import CoreData
import SwiftUI

struct DashboardRView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var viewModel: DashboardViewModel
    
    init(context: NSManagedObjectContext) {
        _viewModel = StateObject(
            wrappedValue: DashboardViewModel(context: context)
        )
    }
    
    // MARK: - MAIN BODY
    // Sekarang body jadi sangat bersih dan mudah dibaca compiler
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                
                headerSection
                
                searchBarSection
                
                // Logic Ganti Layar: Search vs Dashboard Normal
                if !viewModel.searchText.isEmpty {
                    searchResultsList
                } else {
                    dashboardContent
                }
            }
            .onAppear {
                viewModel.fetchAllData()
            }
        }
    }
}

// MARK: - SUBVIEWS EXTENSION
// Kita pecah komponen UI di sini agar compiler tidak error "Time Out"
extension DashboardRView {
    
    // 1. Header (Hello, Name)
    private var headerSection: some View {
        HStack {
            Text("Hello, \(viewModel.userName)")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(Color(hex: "#003F57"))
                .padding(.top)
            Spacer()
        }
        .padding(.horizontal)
        .padding(.top)
    }
    
    // 2. Search Bar
    private var searchBarSection: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                
                // 2. TextField
                TextField("Search survey...", text: $viewModel.searchText)
                    .font(.subheadline)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                
                Spacer()
                
                // 3. Tombol Clear (X) - Muncul cuma kalau ada ketikan
                if !viewModel.searchText.isEmpty {
                    Button(action: {
                        viewModel.searchText = ""  // Hapus text
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding()
            .background(Color(hex: "#D9D9D9"))
            .frame(maxWidth: 370)
            .clipShape(Capsule())
        }
        .padding(.horizontal)
        .padding(.bottom)
    }
    
    // 3. List Hasil Pencarian
    private var searchResultsList: some View {
        List(viewModel.searchResults, id: \.self) { survey in
            NavigationLink(
                destination: ListSurveyView(searchText: survey.survey_title)
            ) {
                Text(survey.survey_title ?? "No Title")
            }
        }
        .listStyle(.plain)
    }
    
    // 4. Konten Dashboard Utama (ScrollView)
    private var dashboardContent: some View {
        ScrollView {
            VStack {
                pointsCard
                categoriesRow
                popularSurveysRow
                ongoingSurveysList
            }
            .padding(.bottom, 50)  // Spacer bawah
        }
    }
    
    // 5. Kartu Poin
    private var pointsCard: some View {
        VStack(alignment: .leading) {
            Text("My Points")
                .font(.title)
                .foregroundStyle(.white)
                .padding(.horizontal)
                .padding(.top)
                .fontWeight(.bold)
            
            Text("\(viewModel.userPoints)")
                .font(.title)
                .foregroundStyle(Color(hex: "#FE982A"))
                .padding(.horizontal)
                .fontWeight(.bold)
            
            Spacer()
            
            NavigationLink(destination: ViewPointView()) {
                Text("View Points")
                    .font(.title3)
                    .underline()
                    .foregroundStyle(Color(hex: "#FE982A"))
                    .padding()
            }
        }
        .padding()
        .frame(width: 370, height: 200, alignment: .leading)
        .background(Color(hex: "#0C4254"))
        .cornerRadius(12)
    }
    
    // 6. Baris Kategori
    private var categoriesRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(viewModel.categories, id: \.self) { category in
                    NavigationLink(
                        destination: ListSurveyView(
                            category: category.category_name
                        )
                    ) {
                        Text(category.category_name ?? "Unknown")
                            .padding(.horizontal, 18)
                            .padding(.vertical, 10)
                            .background(Color(hex: "#99B2BE"))
                            .foregroundColor(Color(hex: "#0C4254"))
                            .font(.subheadline)
                            .cornerRadius(18)
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical)
    }
    
    private var popularSurveysRow: some View {
        VStack {
            // Header
            HStack {
                Text("Active Survey")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(Color(hex: "#0C4254"))
                    .padding(.horizontal)
                Spacer()
            }
            
            // Horizontal Scroll
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(viewModel.popularSurveys, id: \.self) { survey in
                        NavigationLink(destination: SurveyDetailView(survey: survey)) {
                            // Memanggil Subview Card
                            PopularSurveyCard(survey: survey)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 10) // Tambah padding biar shadow ga kepotong
            }
        }
    }

    // MARK: - COMPONENT CARD (Refactored)
    struct PopularSurveyCard: View {
        let survey: Survey
        
        // Helper simple untuk cek apakah ada URL gambar
        var hasImage: Bool {
            return survey.survey_img_url != nil
        }
        
        var body: some View {
            ZStack {
                // LAYER 1: BACKGROUND (Logic Universal Image)
                if let path = survey.survey_img_url {
                    // ✅ Pakai UniversalImage di sini
                    UniversalImage(imageName: path)
                        .scaledToFill() // Agar gambar memenuhi kotak
                        .frame(width: 240, height: 130) // Paksa ukuran frame di sini juga untuk gambar
                        .clipped()
                } else {
                    // Jika tidak ada URL sama sekali, background putih
                    Color.white
                }
                
                // LAYER 2: DIMMED OVERLAY (Hanya jika ada URL gambar)
                if hasImage {
                    Color.black.opacity(0.45)
                }
                
                // LAYER 3: CONTENT TEXT
                VStack(alignment: .leading, spacing: 8) {
                    Text(survey.survey_title ?? "No Title")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        // Logic Warna Text: Putih kalau ada gambar, Biru kalau polosan
                        .foregroundColor(hasImage ? .white : Color(hex: "#003F57"))
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                    
                    Spacer()
                    
                    // BARU: Reward Points Badge
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.caption2)
                        Text("+\(survey.survey_rewards_points ?? 0) pts")
                            .font(.caption)
                            .fontWeight(.bold)
                    }
                    .foregroundColor(hasImage ? .white : Color(hex: "#FE982A"))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(hex: "FE982A").opacity(0.1))
                    .cornerRadius(8)
                }
                .padding(14)
            }
            // MARK: - CONTAINER STYLING
            .frame(width: 240, height: 130)
            .background(Color.white) // Fallback background agar shadow tetap muncul walau image loading
            .clipShape(RoundedRectangle(cornerRadius: 16)) // Potong sudut tumpul
            .shadow(color: .black.opacity(0.15), radius: 6, y: 4)
        }
    }



    // 8. List Ongoing Survey
    private var ongoingSurveysList: some View {
        VStack {
            if !viewModel.ongoingSurveys.isEmpty {
                HStack {
                    Text("Ongoing Survey")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(Color(hex: "#0C4254"))
                        .padding(.horizontal)
                    Spacer()
                }
                .padding(.vertical)
                
                VStack(alignment: .leading, spacing: 16) {
                    ForEach(viewModel.ongoingSurveys, id: \.0) { item in
                        VStack {
                            HStack(spacing: 12) {
                                Text(item.0)
                                    .font(.headline)
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                                    .frame(maxWidth: 350, alignment: .leading)
                            }
                            
                            HStack(spacing: 12) {
                                GeometryReader { geo in
                                    ZStack(alignment: .leading) {
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(Color.gray.opacity(0.3))
                                            .frame(height: 8)
                                        
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(Color(hex: "#FE982A"))
                                            .frame(
                                                width: geo.size.width
                                                * CGFloat(item.1),
                                                height: 8
                                            )
                                    }
                                }
                                .frame(height: 8)
                                
                                Text("\(Int(item.1 * 100))%")
                                    .font(.system(size: 14, weight: .semibold))
                                    .frame(width: 40, alignment: .trailing)
                            }
                        }
                        .padding()
                        .frame(width: 370)
                        .background(Color(hex: "#D9D9D9"))
                        .cornerRadius(12)
                    }
                }
                .padding(.bottom, 20)
            }
        }
    }
}
