import SwiftUI

struct SuccessTopUpView: View {
    @Environment(\.dismiss) var dismiss
    var pointsAdded: Int32
    var body: some View {
        ZStack {
            VStack(spacing: 30) {
                // Checkmark Icon and Blob Shape
                ZStack {
                    Image("splash")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 500, height: 370)
                            .offset(x: 10, y: 10)
                            .padding(.bottom, 35)
                    
                    Image(systemName: "checkmark")
                        .font(.system(size: 80, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 150, height: 150)
                        .background(Color.brandOrange)
                        .clipShape(Circle())
                        .padding(5)
                    
                }
                
                // Success Text
                VStack(spacing: 10) {
                    Text("Top Up Successful !")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(Color.darkTeal)
                    
                    Text("+ \(pointsAdded.formattedWithSeparator()) Points")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(Color.brandOrange)
                        .padding(.bottom, 10)
                    
                    Text("The balance will be added to your wallet")
                        .font(.subheadline)
                        .foregroundColor(Color.darkTeal)
                }
                

                Spacer()
                // The OK Button
                Button(action: {
                    dismiss()
                }) {
                    Text("OK")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(height: 60)
                        .frame(maxWidth: 200)
                        .background(Color.brandOrange)
                        .cornerRadius(15)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 160)
            }
            .toolbar(.hidden, for: .tabBar) 
            .padding(.top, 100)
        }
    }
}


// MARK: - Previe

#Preview {
    SuccessTopUpView(pointsAdded: 1000)
}
