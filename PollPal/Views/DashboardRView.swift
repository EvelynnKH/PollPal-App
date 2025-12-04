////
////  DashboardRView.swift
////  PollPal
////
////  Created by student on 01/12/25.
////
//
//import SwiftUI
//
//struct DashboardRView: View {
//    //aku simpan category dan judul survey disini dulu
//    let categories = [
//        ("Psychology", ListSurveyView()),
//        ("Design", ListSurveyView()),
//        ("Marketing", ListSurveyView()),
//        ("Technology", ListSurveyView()),
//        ("Daily Life", ListSurveyView())
//    ]
//    
//    let surveys = [
//        "Kepuasan Pelayanan",
//        "Survey Pengalaman Pengguna",
//        "Penilaian Fasilitas Publik",
//        "Survey Edukasi Masyarakat",
//        "Laporan Masalah Infrastruktur"
//    ]
//    
//    //utk progress bar
//    let progressSurveys = [
//        ("Kepuasan Pelayanan", 0.3),
//        ("Survey Pengalaman Pengguna yang Panjang Sekali", 0.6),
//        ("Penilaian Fasilitas Publik", 0.9)
//    ]
//    
//    
//    var body: some View {
//        VStack(alignment: .leading){
//            HStack{
//                Text("Hello, Feli")
//                    .font(.largeTitle)
//                    .fontWeight(.bold)
//                    .foregroundColor(.black)
//                    .padding(.top)
//                Spacer()
//            }
//            .padding(.horizontal)
//            .padding(.top)
//        }
//        ScrollView{
//            VStack{
//                // Search bar
//                VStack(alignment: .leading){
//                    HStack{
//                        Text("Search...")
//                            .font(.subheadline)
//                        Spacer()
//                        Text("🔍")
//                    }
//                    .padding()
//                    .background(Color(hex: "#D9D9D9"))
//                    .frame(maxWidth: 370)
//                    .clipShape(Capsule())
//                }
//                .padding(.horizontal)
//                .padding(.bottom)
//                
//                //Bagian my points
//                VStack(alignment: .leading){
//                    Text("My Points")
//                        .font(.title)
//                        .foregroundStyle(.white)
//                        .padding(.horizontal)
//                        .padding(.top)
//                        .fontWeight(.bold)
//                    Text("50,000")
//                        .font(.title)
//                        .foregroundStyle(Color(hex: "#FE982A"))
//                        .padding(.horizontal)
//                        .fontWeight(.bold)
//                    Spacer()
//                    Text("View Points")
//                        .font(.title3)
//                        .underline()
//                        .foregroundStyle(Color(hex: "#FE982A"))
//                        .padding()
//                }
//                .padding()
//                .frame(width:370, height: 200, alignment: .leading)
//                .background(Color(hex: "#0C4254"))
//                .cornerRadius(12)
//                
//                
//                //Bagian categories
//                ScrollView(.horizontal, showsIndicators: false) {
//                    HStack(spacing: 12){
//                        ForEach(categories, id: \.0) { item in
//                            NavigationLink(destination: item.1) {
//                                Text(item.0)
//                                    .padding(.horizontal, 18)
//                                    .padding(.vertical, 10)
//                                    .background(Color(hex: "#99B2BE"))
//                                    .foregroundColor(Color(hex: "#0C4254"))
//                                    .font(.subheadline)
//                                    .cornerRadius(18)
//                            }
//                        }
//                    }
//                    .padding(.horizontal)
//                }
//                .padding(.vertical)
//                
//                //Bagian popular survey
//                HStack{
//                    Text("Popular Survey")
//                        .font(.title)
//                        .fontWeight(.bold)
//                        .foregroundStyle(Color(hex: "#0C4254"))
//                        .padding(.horizontal)
//                    Spacer()
//                }
//                
//                ScrollView(.horizontal, showsIndicators: false) {
//                    HStack(spacing: 12) {
//                        ForEach(surveys, id: \.self) { title in
//                            NavigationLink(destination: ListSurveyView()) {
//                                VStack(alignment: .leading, spacing: 4) {
//                                    Text(title)
//                                        .font(.headline)
//                                        .fontWeight(.bold)
//                                        .padding()
//                                        .multilineTextAlignment(.leading)
//                                        .lineLimit(2)
//                                        .truncationMode(.tail)
//                                        .fixedSize(horizontal: false, vertical: true)
//                                }
//                                .padding(10)
//                                .foregroundColor(Color(hex: "#0C4254"))
//                                .frame(maxWidth: 250, minHeight: 100, alignment: .leading)
//                                .background(Color.white)
//                                .cornerRadius(14)
//                                .shadow(color: .black.opacity(0.2), radius: 5, y: 3)
//                                .padding(.vertical)
//                            }
//                        }
//                    }
//                    .padding(.horizontal)
//                }
//                
//                //Bagian ongoing survey
//                HStack{
//                    Text("Ongoing Survey")
//                        .font(.title)
//                        .fontWeight(.bold)
//                        .foregroundStyle(Color(hex: "#0C4254"))
//                        .padding(.horizontal)
//                    Spacer()
//                }
//                .padding(.vertical)
//                
//                VStack(alignment: .leading, spacing: 16) {
//                    ForEach(progressSurveys, id: \.0) { survey in
//                        VStack{
//                            HStack(spacing: 12) {
//                                // Title
//                                Text(survey.0)
//                                    .font(.headline)
//                                    .lineLimit(1)
//                                    .truncationMode(.tail)
//                                    .frame(maxWidth: 350, alignment: .leading)
//                            }
//                            
//                            HStack(spacing: 12){
//                                // Progress bar
//                                GeometryReader { geo in
//                                    ZStack(alignment: .leading) {
//                                        RoundedRectangle(cornerRadius: 4)
//                                            .fill(Color.gray.opacity(0.3))
//                                            .frame(height: 8)
//                                        
//                                        RoundedRectangle(cornerRadius: 4)
//                                            .fill(Color(hex: "#FE982A"))
//                                            .frame(width: geo.size.width * CGFloat(survey.1), height: 8)
//                                    }
//                                }
//                                .frame(height: 8)
//                                
//                                // Percentage
//                                Text("\(Int(survey.1 * 100))%")
//                                    .font(.system(size: 14, weight: .semibold))
//                                    .frame(width: 40, alignment: .trailing)
//                            }
//                        }
//                        .padding()
//                        .frame(width: 370)
//                        .background(Color(hex: "#D9D9D9"))
//                        .cornerRadius(12)
//                    }
//                }
//            }
//            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
//        }
//    }
//}
//
//#Preview {
//    DashboardRView()
//}
