import SwiftUI
struct WithdrawPoint: View {
    @State private var selectedMethod: String = "OVO"
    @State private var navigateToSuccess: Bool = false
    @State private var selectedAmount: Double = 0 // NEW: user-typed amount
    @State private var showAlert: Bool = false // validation alert
    
    @Environment(\.managedObjectContext) private var viewContext
    
    // Fetch the currently logged-in user
    @FetchRequest private var loggedInUser: FetchedResults<User>
    
    // Computed property to get points
    private var points: Int {
        Int(loggedInUser.first?.user_point ?? 0)
    }
    
    private var userPhone: String {
        loggedInUser.first?.user_hp ?? "N/A" // Fetches user_hp
    }
    
    // Computed property for dynamic Rp value
    private var rupiahValue: Int {
        Int(selectedAmount * 10) // 1 point = 100 Rp
    }
    
    // MARK: - Init to fetch current user
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
                
                // MARK: Page Title
                Text("Withdraw Money")
                    .font(.system(size: 25, weight: .bold))
                    .foregroundColor(.darkTeal)
                    .padding(.top, 35)
                    .padding(.horizontal)
                    .padding(.bottom, 15)
                    .frame(maxWidth: .infinity, alignment: .center)
                
                // MARK: Points Card
                VStack(alignment: .center, spacing: 12) {
                    
                    Text("You have \(points) points")
                        .font(.headline)
                        .foregroundColor(.darkTeal)
                    
                    TextField("Enter amount", value: $selectedAmount, formatter: NumberFormatter.decimalFormatter)
                        .keyboardType(.numberPad)                   // only numeric keyboard
                        .multilineTextAlignment(.center)           // center text
                        .keyboardType(.numberPad)
                        .font(.system(size: 30, weight: .bold))
                        .foregroundColor(.darkTeal)
                        .padding(.vertical, 10)
                        .padding(.horizontal)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                    
                    
                    
                    // Dynamic Rp display
                    Text("Enter amount to withdraw")
                        .font(.body)
                        .foregroundColor(.darkTeal)
                    
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .cornerRadius(20)
                .shadow(color: .black.opacity(0.1), radius: 10, y: 3)
                .padding(.horizontal)
                
                // MARK: Withdraw To Section
                VStack(alignment: .leading, spacing: 20) {
                    
                    Text("Withdraw Points To")
                        .font(.title3)
                        .foregroundColor(.darkTeal)
                        .padding(.top, 10)
                        .padding(.bottom,10)
                    
                    VStack(spacing: 24) {
                        
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
                
                HStack(spacing: 8) {
                    Text("Total Received:")
                        .font(.title2)
                        .foregroundColor(.darkTeal)
                    Spacer()
                    Text("Rp \(rupiahValue.formattedWithSeparator())")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.darkTeal)
                }
                .padding(.horizontal)
                .padding(.bottom,10)
                // MARK: Bottom Button
                VStack {
                    Button(action: {
                        if selectedAmount > Double(points) {
                                showAlert = true
                            } else {
                                if let user = loggedInUser.first {
                                    user.user_point -= Int32(selectedAmount) // update points
                                    
                                    // Create transaction record
                                    let trans = Transaction(context: viewContext)
                                    trans.transaction_id = UUID()
                                    trans.transaction_point_change = -Int32(selectedAmount)
                                    trans.transaction_description = "Withdraw Berhasil"
                                    trans.transaction_status_del = false
                                    trans.owned_by_user = user
                                    trans.transaction_created_at = Date()
                                    trans.transaction_type = "WITHDRAW"
                                    
                                    do {
                                        try viewContext.save() // save points and transaction
                                        navigateToSuccess = true
                                    } catch {
                                        print("❌ Failed to save withdraw and transaction: \(error.localizedDescription)")
                                    }
                                }
                            }
                    }) {
                        Text("Confirm Withdraw")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(Color.darkTeal)
                            .cornerRadius(18)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 25)
                    .alert("Insufficient points", isPresented: $showAlert) {
                        Button("OK", role: .cancel) {}
                    }
                    .navigationDestination(isPresented: $navigateToSuccess) {
                        SuccessWithdrawView()
                            .navigationBarBackButtonHidden(true)
                    }
                }
            }
            .toolbar(.hidden, for: .tabBar)
            .padding(.bottom, 40)
            .padding(.horizontal, 10)
            .background(Color(.systemGray6))
            .ignoresSafeArea(edges: .bottom)
        }
    }
}
extension Int {
    func formattedWithSeparator() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
}
// MARK: Preview
#Preview {
    WithdrawPoint()
}
