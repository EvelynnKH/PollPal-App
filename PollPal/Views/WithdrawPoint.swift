import SwiftUI
struct WithdrawPoint: View {
    @State private var selectedMethod: String = "OVO"
    @State private var navigateToSuccess: Bool = false
    
    @Environment(\.managedObjectContext) private var viewContext
    
    // Fetch the currently logged-in user
    @FetchRequest private var loggedInUser: FetchedResults<User>
    
    // Computed property to get points
    private var points: Int {
        Int(loggedInUser.first?.user_point ?? 0)
    }
    
    // MARK: - Init to fetch current user
    init() {
        // Get logged-in user UUID from UserDefaults
        let userIDString = UserDefaults.standard.string(forKey: "logged_in_user_id") ?? ""
        let userUUID = UUID(uuidString: userIDString) ?? UUID()
        
        // FetchRequest for current user
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
                
                // MARK: Points Card
                VStack(alignment: .center, spacing: 12) {
                    
                    Text("My Points")
                        .font(.headline)
                        .foregroundColor(.darkTeal)
                    
                    Text(formatCurrency(points))
                        .font(.system(size: 46, weight: .bold))
                        .foregroundColor(.darkTeal)
                    
                    Text("You will receive Rp. \(formatCurrency(points)) !")
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
                            phone: "08*** **** **21",
                            selectedMethod: $selectedMethod
                        )
                        
                        Divider()
                        
                        PaymentRow(
                            icon: "ovo",
                            title: "OVO",
                            method: "OVO",
                            phone: "08*** **** **21",
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
                    
                    // MARK: NavigationDestination (iOS 16+)
                    .navigationDestination(isPresented: $navigateToSuccess) {
                        SuccessWithdrawView()
                            .navigationBarBackButtonHidden(true)
                    }
                }
            }
            .padding(.bottom, 40)
            .padding(.horizontal, 10)
            .background(Color(.systemGray6))
            .ignoresSafeArea(edges: .bottom)
        }
    }
}

// MARK: Preview
#Preview {
    WithdrawPoint()
}
