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
                .foregroundColor(.black)
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
    
    // 7. Baris Popular Survey
    private var popularSurveysRow: some View {
        VStack {
            HStack {
                Text("Popular Survey")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(Color(hex: "#0C4254"))
                    .padding(.horizontal)
                Spacer()
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(viewModel.popularSurveys, id: \.self) { survey in
                        NavigationLink(destination: SurveyDetailView(survey: survey)) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(survey.survey_title ?? "No Title")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .padding()
                                    .multilineTextAlignment(.leading)
                                    .lineLimit(2)
                                    .truncationMode(.tail)
                                    .fixedSize(
                                        horizontal: false,
                                        vertical: true
                                    )
                            }
                            .padding(10)
                            .foregroundColor(Color(hex: "#0C4254"))
                            .frame(
                                maxWidth: 250,
                                minHeight: 100,
                                alignment: .leading
                            )
                            .background(Color.white)
                            .cornerRadius(14)
                            .shadow(color: .black.opacity(0.2), radius: 5, y: 3)
                            .padding(.vertical)
                        }
                    }
                }
                .padding(.horizontal)
            }
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
