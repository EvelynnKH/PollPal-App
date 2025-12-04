//
//  ContentView.swift
//  PollPal
//
//  Created by student on 27/11/25.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View {
        TabView{
            NavigationStack{
                ListSurveyView(context: viewContext)
            }
            .tabItem {
                Image(systemName: "house")
                Text("Home")
            }
            
            NavigationStack{
                    HistoryView(context: viewContext)
                    .navigationTitle("History")
            }
            .tabItem{
                Image(systemName: "clock.arrow.trianglehead.counterclockwise.rotate.90")
                Text("History")
            }
            
            NavigationStack{
                ProfileUserView(context: viewContext)
            }
            .tabItem{
                Image(systemName: "person")
                Text("Profile")
            }
        }
        .tint(Color(hex: "#FE982A"))
    }
}

#Preview {
    ContentView()
}
