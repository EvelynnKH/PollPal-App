//
//  ContentView.swift
//  New Survey PollPal
//
//  Created by student on 27/11/25.
//
import SwiftUI
import PhotosUI
struct NotificationView: View {
    let orange = Color(red: 254 / 255, green: 152 / 255, blue: 42 / 255)
    let DarkTeal = Color(red: 12 / 255, green: 66 / 255, blue: 84 / 255)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
                    // MARK: Header
                    Text("Notification")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(DarkTeal)
                        .padding(.horizontal)
                        .padding(.top, 30)
                        .padding(.bottom, 35)
                    
                    ScrollView {
                        VStack(spacing: 22) {
                            NotificationRow(
                                icon: "dollarsign.circle.fill",
                                iconColor: .green,
                                title: "Balance",
                                subtitle: "You've collected 1000 points"
                            )
                            
                            NotificationRow(
                                icon: "doc.text.fill",
                                iconColor: .orange,
                                title: "Survey",
                                subtitle: "You’ve got 100 respond on Cooking Mama Survey"
                            )
                            
                            NotificationRow(
                                icon: "dollarsign.circle.fill",
                                iconColor: .green,
                                title: "Balance",
                                subtitle: "You've collected 1000 points"
                            )
                            
                            NotificationRow(
                                icon: "doc.text.fill",
                                iconColor: .orange,
                                title: "Survey",
                                subtitle: "You’ve got 100 respond on Cooking Mama Survey"
                            )
                        }
                        .padding(.horizontal)
                        .padding(.top, 10)
                    }
                }
                .background(Color.white)
                .ignoresSafeArea(edges: .bottom)
                .padding(.horizontal, 10)
    }
}
struct NotificationRow: View {
    var icon: String
    var iconColor: Color
    var title: String
    var subtitle: String
    
    let orange = Color(red: 254 / 255, green: 152 / 255, blue: 42 / 255)
    let DarkTeal = Color(red: 12 / 255, green: 66 / 255, blue: 84 / 255)
    
    var body: some View {
        VStack(spacing: 12) {
            HStack(alignment: .top, spacing: 14) {
                
                // Icon
                Image(systemName: icon)
                    .foregroundColor(iconColor)
                    .font(.system(size: 30))
                
                // Text Content
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(DarkTeal)
                    
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Spacer()
            }
            
            Divider().padding(.leading, 45)
        }
    }
}
#Preview {
    NotificationView()
}
