//
//  ProfileUserView.swift
//  PollPal
//
//  Created by student on 01/12/25.
//

import SwiftUI
import CoreData

struct ProfileUserView: View {
    // Inject Context & ViewModel
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var viewModel: ProfileUserViewModel
    
    // Custom Init untuk menyuntikkan context
    init(context: NSManagedObjectContext) {
        _viewModel = StateObject(wrappedValue: ProfileUserViewModel(context: context))
    }
    
    let DarkTeal = Color(red: 12 / 255, green: 66 / 255, blue: 84 / 255)
    let orange = Color(red: 254 / 255, green: 152 / 255, blue: 42 / 255)
    
    // Programmatic navigation states
    @State private var navigateToHelp = false
    @State private var navigateToSetting = false
    @State private var navigateToDashboard = false
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .bottomTrailing) {
                Text(viewModel.userHeaderImage)
                Image(viewModel.userHeaderImage) // Pastikan gambar ini ada di Assets
                    .resizable()
                    .scaledToFill()
                    .frame(height: 230)
                    .clipped()
                    .opacity(0.7)
                    .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 10)
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                Button(action: {}) {
                    Image(systemName: "pencil")
                        .foregroundColor(.gray)
                        .padding(10)
                        .background(Color.white.opacity(0.8))
                        .clipShape(Circle())
                }
                .padding(.trailing, 10)
                .padding(.bottom, 10)
            }
            
            HStack {
                Spacer()
                
                Circle()
                    .stroke(DarkTeal, lineWidth: 4)
                    .frame(width: 140, height: 140)
                    .background(Color.white)
                    .clipShape(Circle())
                    .overlay(
                        // Placeholder image, nanti bisa diganti user_profile_img dari CoreData
                        Image(viewModel.userProfileImage) // Pastikan gambar ini ada di Assets
                            .resizable()
                            .scaledToFill()
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 10)
                            .frame(width: 132, height: 132)
                    )
                
                Spacer()
            }
            .offset(y: -70)
            
            VStack {
                // --- DATA DARI VIEW MODEL ---
                Text(viewModel.userName) // Nama User Dinamis
                    .font(.title)
                    .padding(.top, -60)
                    .foregroundColor(DarkTeal)
                
                Text(viewModel.userEmail) // Email User Dinamis (Opsional ditampilkan)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.top, -35)
                    .padding(.bottom, 5)

                Text("My Interest: \(viewModel.userInterests)") // Menggunakan data dinamis
                    .padding(.top, 0)
                    .foregroundColor(DarkTeal)
                // ----------------------------
                
                Button("Add More Category") {
                    // action
                }
                .font(.subheadline)
                .padding(.horizontal, 15)
                .padding(.vertical, 8)
                .background(DarkTeal)
                .foregroundColor(.white)
                .cornerRadius(20)
                
                HStack (spacing: 20){
                    // --- TOTAL POINTS ---
                    ZStack{
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white)
                            .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(DarkTeal, lineWidth: 2))
                                .frame(width: 120, height: 80)
                        
                        VStack{
                            Text("My Points")
                                .font(.subheadline)
                            
                            // Ambil dari ViewModel
                            Text("\(viewModel.userPoints)")
                                .font(.title3)
                                .foregroundColor(orange)
                        }
                    }
                    
                    // --- TOTAL SURVEY ---
                    ZStack{
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white)
                            .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(DarkTeal, lineWidth: 2))
                                .frame(width: 120, height: 80)
                        
                        VStack{
                            Text("Total Survey")
                                .font(.subheadline)
                            
                            // Ambil dari ViewModel (Count HResponse)
                            Text("\(viewModel.completedSurveysCount)")
                                .font(.title3)
                                .foregroundColor(orange)
                        }
                    }
                                            
                }
                .padding(.top, 15)
                
                Divider()
                    .padding(.horizontal, 30)
                    .padding(.vertical, 20)
                
                VStack{
                    // Help Button
                    Button(action: {
                        navigateToHelp = true
                    }) {
                        HStack(spacing: 15) {
                            Image(systemName: "questionmark.circle")
                                .resizable()
                                .frame(width: 22, height: 22)
                                .foregroundColor(DarkTeal)
                                    
                            Text("Help")
                                .font(.body)
                                .foregroundColor(DarkTeal)
                                                
                            Spacer()
                                    
                            Image(systemName: "chevron.right")
                                .foregroundColor(DarkTeal)
                        }
                    }
                    .buttonStyle(.plain)
                    .padding(.trailing, 30)
                    .padding(.bottom, 20)
                    
                    // Setting Button
                    Button(action: {
                        navigateToSetting = true
                    }) {
                        HStack(spacing: 15) {
                            Image(systemName: "gearshape")
                                .resizable()
                                .frame(width: 22, height: 22)
                                .foregroundColor(DarkTeal)
                                    
                            Text("Setting")
                                .font(.body)
                                .foregroundColor(DarkTeal)
                                                
                            Spacer()
                                    
                            Image(systemName: "chevron.right")
                                .foregroundColor(DarkTeal)
                        }
                    }
                    .buttonStyle(.plain)
                    .padding(.trailing, 30)
                    .padding(.bottom, 20)
                    
                    // Change Account Button
                    Button(action: {
                        navigateToDashboard = true
                    }) {
                        HStack(spacing: 15) {
                            Image(systemName: "person.2.circle")
                                .resizable()
                                .frame(width: 22, height: 22)
                                .foregroundColor(DarkTeal)
                                    
                            Text("Change Account")
                                .font(.body)
                                .foregroundColor(DarkTeal)
                                                
                            Spacer()
                                    
                            Image(systemName: "chevron.right")
                                .foregroundColor(DarkTeal)
                        }
                    }
                    .buttonStyle(.plain)
                    .padding(.trailing, 30)
                    
                    // Hidden NavigationLinks
//                    NavigationLink(destination: DashboardCreatorView(), isActive: $navigateToHelp) { EmptyView() }
//                    NavigationLink(destination: DashboardCreatorView(), isActive: $navigateToSetting) { EmptyView() }
//                    NavigationLink(destination: DashboardCreatorView(), isActive: $navigateToDashboard) { EmptyView() }
                }
                .padding(.leading, 30)
                
                Spacer()
            }
            Spacer()
        }
        .ignoresSafeArea(.all, edges: .top)
        .onAppear {
            // Refresh data setiap kali halaman ini muncul
            viewModel.fetchUserProfile()
        }
    }
}
