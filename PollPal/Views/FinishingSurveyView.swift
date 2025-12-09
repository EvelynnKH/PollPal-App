//
//  ContentView.swift
//  New Survey PollPal
//
//  Created by student on 27/11/25.
//
import SwiftUI
import PhotosUI

struct FinishingSurveyView: View {
    @Environment(\.managedObjectContext) private var context
    @ObservedObject var vm: SurveyViewModel
    @Environment(\.dismiss) var dismiss
    
    // MARK: - Color theme
    let orange = Color(red: 254 / 255, green: 152 / 255, blue: 42 / 255)
    let DarkTeal = Color(red: 12 / 255, green: 66 / 255, blue: 84 / 255)
    
    // MARK: - Incoming survey data
    var survey: Survey
    var questions: [Question]
    
    // MARK: - State for category
    @State private var categoryText: String = ""
    @State private var addedCategories: [String] = ["Food", "Tech"]
    
    // MARK: - State for image picker
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedImage: Image? = nil
    
    @State private var expandToTen = false

    
    // MARK: - Helper
    func addCategory() {
        let trimmedText = categoryText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedText.isEmpty && !addedCategories.contains(trimmedText) {
            addedCategories.append(trimmedText)
            categoryText = ""
        }
    }
    
    // MARK: - Body
    var body: some View {
            VStack(spacing: 0) {
                
                // Header Section
                VStack(alignment: .leading) {
                    
                    VStack(alignment: .leading) {
                        Text((survey.survey_title ?? "").isEmpty ? "Untitled Survey" : (survey.survey_title ?? ""))
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("Please Fill In The Remaining Information...")
                            .font(.caption)
                            .foregroundColor(.white)
                    }
                    .padding([.top, .horizontal])
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(height: 250)
                .background(orange)
                
                
                // Main White Card Content
                VStack(alignment: .leading, spacing: 20) {
                    
                    ScrollView {
                    // Description
                    VStack(alignment: .leading, spacing: 5) {
                        Text((survey.survey_title ?? "").isEmpty ? "Untitled Survey" : (survey.survey_title ?? ""))
                            .font(.title)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                            .padding(.bottom, 2)
                        
                        Text("Preview")
                            .foregroundColor(.gray)
                            .font(.subheadline)
                        let initialLimit = 5
                        let expandedLimit = 10

                        let currentLimit = expandToTen ? expandedLimit : initialLimit

                        let limitedQuestions = Array(questions.prefix(currentLimit))
                        ForEach(Array(limitedQuestions.enumerated()), id: \.element.objectID) { index, q in
                            VStack(alignment: .leading, spacing: 2) {
                                Text("\(index + 1). \(q.question_text ?? "Untitled Question")")
                                    .fontWeight(.bold)
                            }
                        }
                        if !expandToTen && questions.count > initialLimit {
                                    Button("See more…") {
                                        withAnimation {
                                            expandToTen = true
                                        }
                                    }
                                    .font(.caption)
                                    .foregroundColor(.blue)
                                    .padding(.top, 4)
                                }

                    }
                    .padding(.horizontal)
                    
                    // Category Box
                    VStack(alignment: .leading) {
                        Text("Category")
                            .font(.headline)
                            .fontWeight(.bold)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(addedCategories, id: \.self) { category in
                                    HStack(spacing: 5) {
                                        Text(category)
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.white)
                                        Image(systemName: "xmark")
                                            .resizable()
                                            .frame(width: 8, height: 8)
                                            .foregroundColor(.white)
                                    }
                                    .padding(.horizontal, 15)
                                    .padding(.vertical, 8)
                                    .background(DarkTeal)
                                    .cornerRadius(10)
                                    .onTapGesture {
                                        if let index = addedCategories.firstIndex(of: category) {
                                            addedCategories.remove(at: index)
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.bottom, 10)
                        
                        HStack {
                            TextField("Search For Available Category...", text: $categoryText)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            
                            Button(action: {
                                addCategory()
                            }) {
                                Text("Add")
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 15)
                                    .padding(.vertical, 8)
                                    .background(orange)
                                    .cornerRadius(10)
                            }
                        }
                        .padding(.bottom, 10)
                        
                        Divider()
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(20)
                    .shadow(radius: 5)
                    .padding(.horizontal)
                    
                    
                    // IMAGE + SMALL BUTTON ON RIGHT
                    HStack(alignment: .top, spacing: 15) {
                        if let image = selectedImage {
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 230, height: 150)
                                .cornerRadius(10)
                                .shadow(radius: 3)
                        }
                        
                        Spacer()
                        
                        PhotosPicker(
                            selection: $selectedItem,
                            matching: .images,
                            photoLibrary: .shared()
                        ) {
                            Text(selectedImage == nil ? "Add Image" : "Change")
                                .font(.caption.bold())
                                .padding(.vertical, 8)
                                .padding(.horizontal, 15)
                                .background(DarkTeal)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                        .onChange(of: selectedItem) {
                            guard let item = selectedItem else { return }
                            Task {
                                if let data = try? await item.loadTransferable(type: Data.self) {
                                    await MainActor.run {
                                        if let uiImage = UIImage(data: data) {
                                            selectedImage = Image(uiImage: uiImage)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    HStack {
                        // SAVE BUTTON
                        Button(action: {
                            survey.survey_updated_at = Date()
                            vm.saveSurvey()   // <— simpan via view model

                            do {
                                try context.save()
                                print("Survey saved!")
                                print("SAVED:", survey.objectID)
                                
                                vm.reset()
                                dismiss()
                            } catch {
                                print("Failed to save survey: \(error)")
                            }

                        }) {
                            Text("Save")
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(orange)
                                .cornerRadius(15)
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 30)
                        

                        // PUBLISH BUTTON
                        Button(action: {
                            survey.is_public = true      // <– set public
                            survey.survey_updated_at = Date()

                            vm.publishSurvey()      // <– tetap save via VM

                            do {
                                try context.save()
                                print("Survey published & saved!")
                                
                                vm.reset()
                                dismiss()
                            } catch {
                                print("Failed to save survey: \(error)")
                            }

                        }) {
                            Text("Publish")
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(orange)
                                .cornerRadius(15)
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 30)
                    }

                }
                .padding(.vertical, 20)
                .padding(.horizontal, 10)
                .background(Color.white)
                .offset(y: -50)
            }
        }
        .edgesIgnoringSafeArea(.top)
    }
}
