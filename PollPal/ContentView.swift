//
//  ContentView.swift
//  PollPal
//
//  Created by student on 27/11/25.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @AppStorage("logged_in_user_id") var loggedInUserID: String = ""
    
    var body: some View {
            // LOGIKA PERCABANGAN UTAMA
            if loggedInUserID.isEmpty {
                
                // SKENARIO A: BELUM LOGIN
                // Tampilkan Welcome Screen (yang nanti nyambung ke Login/Sign Up)
                NavigationStack {
                    WelcomeView()
                }
                // Transition effect (opsional, biar halus saat ganti layar)
                .transition(.opacity)
                
            } else {
                
                // SKENARIO B: SUDAH LOGIN
                // Tampilkan Dashboard Utama dengan Tab Bar
                TabView {
                    // Tab 1: Home (Dashboard)
                    // Ganti WelcomeView dengan DashboardRView
                    NavigationStack {
                        DashboardRView(context: viewContext)
                    }
                    .tabItem {
                        Image(systemName: "house.fill")
                        Text("Home")
                    }
                    
                    // Tab 2: History
                    NavigationStack {
                        HistoryView(context: viewContext)
                            .navigationTitle("History")
                    }
                    .tabItem {
                        Image(systemName: "clock.arrow.trianglehead.counterclockwise.rotate.90")
                        Text("History")
                    }
                    
                    // Tab 3: Profile
                    NavigationStack {
                        ProfileUserView(context: viewContext)
                    }
                    .tabItem {
                        Image(systemName: "person.fill")
                        Text("Profile")
                    }
                }
                .tint(Color(hex: "#FE982A")) // Warna Orange Brand
                .transition(.opacity)
            }
        }
    }
#Preview {
    ContentView()
}
