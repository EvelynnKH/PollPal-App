import SwiftUI
struct TopUpPoint: View {
    @State private var selectedAmount: Int32 = 0
    @State private var selectedMethod: String = "OVO"
    @State private var navigateToSuccess: Bool = false
    @State private var typedAmount: String = ""
    
    let amounts = [250, 500, 750, 1000, 2000, 5000]
    
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest private var loggedInUser: FetchedResults<User>
    
    // Computed: total payment in Rp
    private var totalPayment: Int32 {
        // For example: 1 point = 10 Rp
        return selectedAmount * 10
    }
    
    init() {
        let userIDString = UserDefaults.standard.string(forKey: "logged_in_user_id") ?? ""
        let userUUID = UUID(uuidString: userIDString) ?? UUID()
        _loggedInUser = FetchRequest(
            sortDescriptors: [],
            predicate: NSPredicate(format: "user_id == %@", userUUID as CVarArg)
        )
    }
    
    var body: some View {
        NavigationStack{
            VStack(alignment: .leading, spacing: 20) {
                
                // MARK: Title
                Text("Top Up Points")
                    .font(.system(size: 25, weight: .bold))
                    .foregroundColor(.darkTeal)
                    .padding(.top, 120)
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity, alignment: .center)
                
                // MARK: Amount Card
                VStack(alignment: .leading, spacing: 16) {
                    
                    Text("PollPal Points")
                        .font(.headline)
                        .foregroundColor(.darkTeal)
                    
                    TextField("Enter amount", value: $selectedAmount, formatter: NumberFormatter.decimalFormatter)
                        .keyboardType(.numberPad)
                        .font(.system(size: 30, weight: .bold))
                        .foregroundColor(.darkTeal)
                        .padding(.vertical, 10)
                        .padding(.horizontal)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                        .keyboardType(.numberPad)
                        .onChange(of: typedAmount) { _ in
                                // Keep only digits
                                typedAmount = typedAmount.filter { "0123456789".contains($0) }
                                selectedAmount = Int32(typedAmount) ?? 0
                            }
                    
                    Divider()
                    
                    // Amount Buttons
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3), spacing: 12) {
                        ForEach(amounts, id: \.self) { amount in
                            Button {
                                selectedAmount = Int32(amount)
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
                VStack(alignment: .leading, spacing: 10) {
                    let userPhone = loggedInUser.first?.user_hp ?? "N/A"
                    
                    Text("Payment Method")
                        .font(.title3)
                        .foregroundColor(.darkTeal)
                        .padding(.bottom, 10)
                    
                    VStack(spacing: 18) {
                        
                        PaymentRow(
                            icon: "gopay",
                            title: "GoPay",
                            method: "GoPay",
                            phone: userPhone,
                            selectedMethod: $selectedMethod
                        )
                        
                        Divider()
                        
                        PaymentRow(
                            icon: "ovo",
                            title: "OVO",
                            method: "OVO",
                            phone: userPhone,
                            selectedMethod: $selectedMethod
                        )
                        
                        Divider()
                        
                        
                    }
                }
                .padding(.horizontal)
                .padding(.leading, 10)
                
                Spacer()
                
                // MARK: Total Payment
                HStack(spacing: 8) {
                    Text("Total Payment:")
                        .font(.title2)
                        .foregroundColor(.darkTeal)
                    Spacer()
                    Text("Rp \(totalPayment.formattedWithSeparator())")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.darkTeal)
                }
                .padding(.horizontal)
                .padding(.bottom,10)
                
                // MARK: Bottom Button
                VStack {
                    Button(action: {
                        if let user = loggedInUser.first {
                            user.user_point += selectedAmount // top-up
                            let trans = Transaction(context: viewContext)
                            trans.transaction_id = UUID()
                            trans.transaction_point_change = selectedAmount
                            trans.transaction_description = "Top Up Berhasil"
                            trans.transaction_status_del = false
                            trans.owned_by_user = user
                            trans.transaction_created_at = Date()
                            trans.transaction_type = "TOP UP"
                            
                            do {
                                try viewContext.save() // MUST save
                                navigateToSuccess = true
                            } catch {
                                print("❌ Failed to save transaction: \(error)")
                            }
                        }
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
                        SuccessTopUpView(pointsAdded: selectedAmount)
                            .navigationBarBackButtonHidden(true)
                    }
                }
            }
            .toolbar(.hidden, for: .tabBar)
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
extension Int32 {
    func formattedWithSeparator() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
}
#Preview {
    TopUpPoint()
}
