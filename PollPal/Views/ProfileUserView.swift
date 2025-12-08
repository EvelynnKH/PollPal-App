//
//  ProfileUserView.swift
//  PollPal
//
//  Created by student on 01/12/25.
//

import CoreData
import SwiftUI

struct ProfileUserView: View {
    // Inject Context & ViewModel
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var viewModel: ProfileUserViewModel

    // Custom Init
    init(context: NSManagedObjectContext) {
        _viewModel = StateObject(
            wrappedValue: ProfileUserViewModel(context: context)
        )
    }

    // Colors
    let darkTeal = Color(red: 12 / 255, green: 66 / 255, blue: 84 / 255)
    let brandOrange = Color(red: 254 / 255, green: 152 / 255, blue: 42 / 255)

    // State untuk Log Out
    @State private var showLogOutAlert = false

    var body: some View {
        NavigationStack {
            List {
                // MARK: - SECTION 1: HEADER (Custom Visual)
                // Kita masukkan Header sebagai item pertama list tanpa padding
                Group {
                    VStack(spacing: 0) {
                        headerSection
                        profileInfoSection
                        statsCardsSection
                    }
                }
                .listRowInsets(EdgeInsets())  // Hapus margin kiri-kanan agar Gambar Full Width
                .listRowSeparator(.hidden)  // Hapus garis pemisah bawah

                // MARK: - SECTION 2: MENU LIST
                Section {
                    // 1. Edit Profile
                    NavigationLink(
                        destination: EditProfileView(context: viewContext)
                    ) {
                        Label {
                            Text("Edit Profile")
                                .fontWeight(.medium)
                                .foregroundColor(darkTeal)
                        } icon: {
                            Image(systemName: "person")
                                .foregroundColor(darkTeal)
                        }
                    }
                    .padding(.vertical, 4)

                    // 2. Change Password
                    NavigationLink(destination: ChangePasswordView(context: viewContext))
                    {
                        Label {
                            Text("Change Password")
                                .fontWeight(.medium)
                                .foregroundColor(darkTeal)
                        } icon: {
                            Image(systemName: "key")
                                .foregroundColor(darkTeal)
                        }
                    }
                    .padding(.vertical, 4)

                    // 3. Switch Role (Direct Link ke DashboardCreator)
                    NavigationLink(
                        destination: DashboardCreatorView(context: viewContext)
                    ) {
                        Label {
                            Text("Switch Role")
                                .fontWeight(.medium)
                                .foregroundColor(darkTeal)
                        } icon: {
                            Image(systemName: "person.2.circle")
                                .foregroundColor(darkTeal)
                        }
                    }
                    .padding(.vertical, 4)

                    // 4. Log Out (Button Merah)
                    Button(action: {
                        showLogOutAlert = true
                    }) {
                        Label {
                            Text("Log Out")
                                .fontWeight(.medium)
                                .foregroundColor(.red)
                        } icon: {
                            Image(
                                systemName: "rectangle.portrait.and.arrow.right"
                            )
                            .foregroundColor(.red)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .listStyle(.plain)  // Gaya List Polos (Putih Bersih)
            .ignoresSafeArea(edges: .top)  // Gambar Header mentok atas
            .onAppear {
                viewModel.fetchUserProfile()
            }
            // Alert Logout
            .alert("Log Out", isPresented: $showLogOutAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Log Out", role: .destructive) {
                    UserDefaults.standard.set(nil, forKey: "logged_in_user_id")
                    
                }
            } message: {
                Text("Are you sure you want to log out?")
            }
        }
    }
}

// MARK: - EXTENSIONS (Visual Header)
extension ProfileUserView {

    // 1. Header Image
    var headerSection: some View {
        ZStack(alignment: .bottomTrailing) {
            Image(viewModel.userHeaderImage)
                .resizable()
                .scaledToFill()
                .frame(height: 220)
                .clipped()
                .cornerRadius(24, corners: [.bottomLeft, .bottomRight])

            // Tombol Edit Header (Hanya Visual)
            Image(systemName: "pencil")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.gray)
                .padding(8)
                .background(Color.white.opacity(0.8))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .padding(16)
        }
    }

    // 2. Profile Info
    var profileInfoSection: some View {
        VStack(spacing: 4) {
            // Avatar
            ZStack(alignment: .bottomTrailing) {
                Image(viewModel.userProfileImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 110, height: 110)
                    .clipShape(Circle())
                    .overlay(
                        Circle().stroke(darkTeal, lineWidth: 3)
                    )
                    .background(Circle().fill(Color.white))

                // Ikon pensil visual saja
                Image(systemName: "pencil")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.gray)
                    .padding(6)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                    .shadow(radius: 2)
                    .offset(x: 5, y: 0)
            }
            .offset(y: -50)
            .padding(.bottom, -40)

            // Nama
            Text(viewModel.userName)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(darkTeal)

            // Interest
            Text("My Interest: \(viewModel.userInterests)")
                .font(.subheadline)
                .foregroundColor(darkTeal)
                .padding(.bottom, 10)

            // --- TOMBOL ADD MORE CATEGORY SUDAH DIHAPUS DISINI ---
        }
        .padding(.bottom, 24)
    }

    // 3. Stats Cards
    var statsCardsSection: some View {
        HStack(spacing: 16) {
            // Card Poin
            VStack(spacing: 8) {
                Text("My Points")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(darkTeal)
                Text("\(viewModel.userPoints)")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(brandOrange)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 16).stroke(
                    darkTeal,
                    lineWidth: 1.5
                )
            )
            .cornerRadius(16)

            // Card Survey
            VStack(spacing: 8) {
                Text("Total Survey")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(darkTeal)
                Text("\(viewModel.completedSurveysCount)")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(brandOrange)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 16).stroke(
                    darkTeal,
                    lineWidth: 1.5
                )
            )
            .cornerRadius(16)
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 20)
    }
}

// Helper Corner Radius
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

#Preview {
    let context = PersistenceController.shared.container.viewContext
    ProfileUserView(context: context)
}
