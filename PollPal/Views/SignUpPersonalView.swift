//
//  SignUpPersonalView.swift
//  PollPal
//
//  Created by student on 09/12/25.
//

import SwiftUI
import PhotosUI
import CoreData

struct SignUpPersonalView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    // Inisialisasi ViewModel di sini (Root Flow)
    @StateObject private var viewModel: SignUpViewModel
    
    init(context: NSManagedObjectContext) {
        _viewModel = StateObject(wrappedValue: SignUpViewModel(context: context))
    }
    
    // Format Tanggal
    var dateFormatter: DateFormatter {
        let f = DateFormatter(); f.dateFormat = "d/M/yyyy"; return f
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // HEADER
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Sign Up")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(Color(hex: "0C4254"))
                        Text("Fill in your personal information")
                            .font(.body)
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 20)
                    
                    // FORM INPUTS
                    InputGroup(label: "Full Name", text: $viewModel.fullName, placeholder: "Enter your full name")
                    
                    // GENDER & DATE
                    HStack(spacing: 15) {
                        // Gender Dropdown
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Gender").font(.headline).foregroundColor(Color(hex: "0C4254"))
                            Menu {
                                Button("Male") { viewModel.gender = "Male" }
                                Button("Female") { viewModel.gender = "Female" }
                            } label: {
                                HStack {
                                    Text(viewModel.gender).foregroundColor(Color(hex: "0C4254"))
                                    Spacer()
                                    Image(systemName: "arrowtriangle.down.fill").resizable().frame(width: 10, height: 6).foregroundColor(Color(hex: "0C4254"))
                                }
                                .padding().background(Color(hex: "E0E0E0").opacity(0.8)).cornerRadius(12)
                            }
                        }
                        
                        // Date Picker Overlay
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Tanggal Lahir").font(.headline).foregroundColor(Color(hex: "0C4254"))
                            ZStack {
                                HStack {
                                    Text(dateFormatter.string(from: viewModel.birthDate))
                                        .foregroundColor(Color(hex: "0C4254"))
                                    Spacer()
                                    Image(systemName: "calendar").foregroundColor(Color(hex: "0C4254"))
                                }
                                DatePicker("", selection: $viewModel.birthDate, displayedComponents: .date)
                                    .labelsHidden().colorMultiply(.clear)
                            }
                            .padding().background(Color(hex: "E0E0E0").opacity(0.8)).cornerRadius(12)
                        }
                    }
                    let indonesianProvinces = [
                        "Aceh", "Sumatera Utara", "Sumatera Barat", "Riau", "Jambi", "Sumatera Selatan", "Bengkulu", "Lampung", "Kepulauan Bangka Belitung", "Kepulauan Riau",
                        "DKI Jakarta", "Jawa Barat", "Jawa Tengah", "DI Yogyakarta", "Jawa Timur", "Banten",
                        "Bali", "Nusa Tenggara Barat", "Nusa Tenggara Timur",
                        "Kalimantan Barat", "Kalimantan Tengah", "Kalimantan Selatan", "Kalimantan Timur", "Kalimantan Utara",
                        "Sulawesi Utara", "Sulawesi Tengah", "Sulawesi Selatan", "Sulawesi Tenggara", "Gorontalo", "Sulawesi Barat",
                        "Maluku", "Maluku Utara",
                        "Papua Barat", "Papua", "Papua Tengah", "Papua Pegunungan", "Papua Selatan", "Papua Barat Daya"
                    ].sorted()
                    
                    
                    VStack(alignment: .leading, spacing: 8) {
                        // Label
                        Text("Province / Residence")
                            .font(.subheadline.bold())
                            .foregroundColor(Color(hex: "0C4254")) // Sesuaikan warna tema Anda
                        
                        // Dropdown Menu
                        Menu {
                            ForEach(indonesianProvinces, id: \.self) { province in
                                Button(action: {
                                    viewModel.placeOfResidence = province
                                }) {
                                    HStack {
                                        Text(province)
                                        // Tampilkan centang jika dipilih
                                        if viewModel.placeOfResidence == province {
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                }
                            }
                        } label: {
                            // Tampilan Tombol agar mirip TextField
                            HStack {
                                Text(viewModel.placeOfBirth.isEmpty ? "Select Birth Place Province" : viewModel.placeOfBirth)
                                    .foregroundColor(viewModel.placeOfBirth.isEmpty ? .gray : .black)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.down")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .background(Color.gray.opacity(0.15)) // Background abu-abu seperti input lain
                            .cornerRadius(12)
                        }
                    }
                    InputGroup(label: "Phone Number", text: $viewModel.phoneNumber, placeholder: "Enter your phone number", keyboardType: .phonePad)
                    
                    // UPLOAD KTM
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Upload KTM").font(.headline).foregroundColor(Color(hex: "0C4254"))
                        PhotosPicker(selection: $viewModel.selectedPhotoItem, matching: .images) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color(hex: "0C4254"), style: StrokeStyle(lineWidth: 1, dash: [5]))
                                    .background(Color.white)
                                    .frame(height: 150)
                                
                                if let img = viewModel.ktmImage {
                                    Image(uiImage: img)
                                        .resizable().scaledToFill()
                                        .frame(height: 150).clipShape(RoundedRectangle(cornerRadius: 16))
                                } else {
                                    VStack {
                                        Image(systemName: "photo.on.rectangle").font(.largeTitle)
                                        Text("Click to upload").font(.caption)
                                    }
                                    .foregroundColor(Color(hex: "0C4254"))
                                }
                            }
                        }
                    }
                    
                    Spacer().frame(height: 20)
                    
                    // BUTTON NEXT
                    Button(action: {
                        viewModel.validateStep1() // Cek validasi
                    }) {
                        Text("Next")
                            .font(.headline.bold())
                            .foregroundColor(.orange)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(hex: "0C4254"))
                            .cornerRadius(16)
                    }
                    .padding(.bottom, 20)
                    
                    HStack {
                        Text("Joined Us Before?")
                            .foregroundColor(Color(hex: "0C4254"))
                        NavigationLink(destination: LoginView()) {
                            Text("Login")
                                .font(.headline.bold())
                                .foregroundColor(Color(hex: "0C4254"))
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.bottom, 20)
                    
                    // NAVIGASI KE SIGNUP VIEW (STEP 2)
                    .navigationDestination(isPresented: $viewModel.isStep1Valid) {
                        // Kita oper ViewModel yang sama agar datanya nyambung
                        SignUpView(viewModel: viewModel)
                    }
                }
                .padding(24)
            }
            .background(Color(hex: "F8F9FA"))
            .navigationBarBackButtonHidden(true)
            .alert(isPresented: $viewModel.showError) {
                Alert(title: Text("Warning"), message: Text(viewModel.errorMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
}

// Reusable Input
struct InputGroup: View {
    var label: String
    @Binding var text: String
    var placeholder: String
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label).font(.headline).foregroundColor(Color(hex: "0C4254"))
            TextField(placeholder, text: $text)
                .padding()
                .background(Color(hex: "E0E0E0").opacity(0.8))
                .cornerRadius(12)
                .foregroundColor(Color(hex: "0C4254"))
                .keyboardType(keyboardType)
        }
    }
}
