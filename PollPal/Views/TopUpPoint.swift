import SwiftUI
struct TopUpPoint: View {
    @State private var selectedAmount: Int = 10_000
    @State private var selectedMethod: String = "OVO"
    @State private var navigateToSuccess: Bool = false
    
    let amounts = [1_000, 2_000, 5_000, 10_000, 15_000, 20_000]
    
    var body: some View {
        NavigationStack{
            VStack(alignment: .leading, spacing: 20) {
                
                // MARK: Title
                Text("Top Up")
                    .font(.system(size: 25, weight: .bold))
                    .foregroundColor(.darkTeal)
                    .padding(.top, 120)
                    .padding(.horizontal)
                
                // MARK: Amount Card
                VStack(alignment: .leading, spacing: 16) {
                    
                    Text("Amount")
                        .font(.headline)
                        .foregroundColor(.darkTeal)
                    
                    TextField("Enter amount", value: $selectedAmount, formatter: NumberFormatter.decimalFormatter)
                        .keyboardType(.numberPad)
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.darkTeal)
                        .padding(.vertical, 10)
                        .padding(.horizontal)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                    
                    Divider()
                    
                    // Amount Buttons
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3), spacing: 12) {
                        ForEach(amounts, id: \.self) { amount in
                            Button {
                                selectedAmount = amount
                            } label: {
                                Text("+ \(formatCurrency(amount))")
                                    .font(.system(size: 16, weight: .medium))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(Color.brandOrange.opacity(0.25))
                                    .foregroundColor(.darkTeal)
                                    .cornerRadius(12)
                            }
                        }
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(20)
                .shadow(color: .black.opacity(0.1), radius: 10, y: 3)
                .padding(.horizontal)
                
                // MARK: Payment Method Section
                VStack(alignment: .leading, spacing: 20) {
                    
                    Text("Payment Method")
                        .font(.title3)
                        .foregroundColor(.darkTeal)
                        .padding(.top,10)
                        .padding(.bottom, 10)
                    
                    VStack(spacing: 24) {
                        
                        PaymentRow(
                            icon: "gopay",
                            title: "GoPay",
                            method: "GoPay",
                            phone: "08 ***8 ****",
                            selectedMethod: $selectedMethod
                        )
                        
                        Divider()
                        
                        PaymentRow(
                            icon: "ovo",
                            title: "OVO",
                            method: "OVO",
                            phone: "08 ***8 ****",
                            selectedMethod: $selectedMethod
                        )
                        
                        Divider()
                        
                        PaymentRow(
                            icon: "qris",
                            title: "QRIS",
                            method: "QRIS",
                            phone: "",
                            selectedMethod: $selectedMethod
                        )
                        
                        Divider()
                        
                    }
                }
                .padding(.horizontal)
                .padding(.leading, 10)
                
                Spacer()
                
                // MARK: Bottom Button
                VStack {
                    Button(action: {
                        navigateToSuccess = true
                    }) {
                        Text("Confirm Payment")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(Color.brandOrange)
                            .cornerRadius(18)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 25)
                    
                    .navigationDestination(isPresented: $navigateToSuccess) {
                        SuccessTopUpView() // Navigate to this view
                            .navigationBarBackButtonHidden(true)
                    }
                }
            }
            .padding(.bottom, 90)
            .padding(.horizontal, 10)
            .background(Color(.systemGray6))
            .ignoresSafeArea(edges: .bottom)
        }
    }
}
// MARK: Payment Row
struct PaymentRow: View {
    var icon: String
    var title: String
    var method: String
    var phone: String
    
    @Binding var selectedMethod: String
    
    var body: some View {
        HStack {
            Image(icon)
                .resizable()
                .scaledToFit()
                .frame(width: 32, height: 32)
            
            Text(title)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.darkTeal)
            
            Text(phone)
                .font(.caption)
                .foregroundColor(.gray)
            
            Spacer()
            
            Circle()
                .stroke(Color.darkTeal, lineWidth: 2)
                .frame(width: 26, height: 26)
                .overlay(
                    Circle()
                        .fill(Color.darkTeal)
                        .padding(6)
                        .opacity(selectedMethod == method ? 1 : 0)
                )
                .onTapGesture {
                    selectedMethod = method
                }
        }
    }
}
// MARK: Helpers
func formatCurrency(_ value: Int) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
}
// MARK: Global Colors
extension Color {
    static let darkTeal = Color(red: 12/255, green: 66/255, blue: 84/255)
    static let brandOrange = Color(red: 254/255, green: 152/255, blue: 42/255)
}
extension NumberFormatter {
    static var decimalFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }
}
#Preview {
    TopUpPoint()
}
