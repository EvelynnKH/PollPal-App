import SwiftUI
import CoreData
struct ViewPointView: View {
    @Environment(\.managedObjectContext) private var viewContext
        @State private var searchText: String = ""
        
        let orange = Color(red: 254/255, green: 152/255, blue: 42/255)
        let darkTeal = Color(red: 12/255, green: 66/255, blue: 84/255)
        
        // Logged-in username from AppStorage
        @AppStorage("loggedInUserName") var loggedInUserName: String = ""
        
        // Survey history for current user
        @FetchRequest private var surveyHistory: FetchedResults<HResponse>
        
        // Transactions for current user
        @FetchRequest private var transactions: FetchedResults<Transaction>
        
        // Currently logged-in User object
        @FetchRequest private var loggedInUser: FetchedResults<User>
    init() {
        // 1. Get logged-in user UUID from UserDefaults
        let userIDString = UserDefaults.standard.string(forKey: "logged_in_user_id") ?? ""
        let userUUID = UUID(uuidString: userIDString) ?? UUID() // fallback if missing
        // 2. Fetch survey history for current user
        _surveyHistory = FetchRequest(
            sortDescriptors: [NSSortDescriptor(keyPath: \HResponse.submitted_at, ascending: false)],
            predicate: NSPredicate(format: "is_filled_by_user.user_id == %@", userUUID as CVarArg)
        )
        // 3. Fetch transactions for current user
        _transactions = FetchRequest(
            sortDescriptors: [NSSortDescriptor(keyPath: \Transaction.transaction_created_at, ascending: false)],
            predicate: NSPredicate(format: "owned_by_user.user_id == %@", userUUID as CVarArg)
        )
        // 4. Fetch the current logged-in user
        _loggedInUser = FetchRequest(
            sortDescriptors: [],
            predicate: NSPredicate(format: "user_id == %@", userUUID as CVarArg)
        )
    }
    var filteredTransactions: [Transaction] {
        if searchText.isEmpty {
            return Array(transactions)
        } else {
            return transactions.filter { t in
                // Check if the title or description contains the search text (case-insensitive)
                let title = titleFor(transaction: t).lowercased()
                let desc = (t.transaction_description ?? "").lowercased()
                return title.contains(searchText.lowercased()) || desc.contains(searchText.lowercased())
            }
        }
    }
    
    var body: some View {
        NavigationStack{
            VStack(alignment: .leading, spacing: 20) {
                // MARK: PAGE TITLE
                Text("Points")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(darkTeal)
                    .padding(.top, 5)
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity, alignment: .center)
                
                // MARK: POINTS CARD
                VStack(spacing: 10) {
                    Text("My Points")
                        .font(.headline)
                        .foregroundColor(.white)
                    Text("\(loggedInUser.first?.user_point ?? 0)")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(orange)
                    // BUTTONS
                    // MARK: BUTTONS
                    HStack(spacing: 20) {
                        // Withdraw Button
                        NavigationLink(destination: WithdrawPoint()) {
                            HStack {
                                Image(systemName: "hand.tap")
                                Text("Withdraw")
                            }
                            .font(.headline.bold())
                            .foregroundColor(darkTeal)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 20)
                            .background(Color.white)
                            .cornerRadius(20)
                        }
                        
                        // Top Up Button
                        NavigationLink(destination: TopUpPoint()) {
                            HStack {
                                Image(systemName: "plus")
                                Text("Top Up")
                            }
                            .font(.headline.bold())
                            .foregroundColor(darkTeal)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 25)
                            .background(Color.white)
                            .cornerRadius(20)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(darkTeal)
                .cornerRadius(30)
                .padding(.horizontal)
                
                // MARK: HISTORY TITLE
                Text("History")
                    .font(.title3.bold())
                    .foregroundColor(darkTeal)
                    .padding(.horizontal)
                // MARK: SEARCH BAR
                HStack {
                    TextField("Search", text: $searchText)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 20)
                        .background(Color.gray.opacity(0.15))
                        .cornerRadius(20)
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(darkTeal)
                        .font(.title2)
                }
                .padding(.horizontal)
                // MARK: DYNAMIC HISTORY LIST
                ScrollView(.vertical, showsIndicators: false) {
                    // Filtered transactions based on search text
                    
                    VStack(spacing: 0) {
                        
                        // TRANSACTION HISTORY (Topup, reward, cost, withdraw)
                        ForEach(filteredTransactions) { t in
                            
                            let points = Int(t.transaction_point_change)
                            let dateString = formatDate(t.transaction_created_at)
                            let type = t.transaction_type ?? ""
                            
                            TransactionRow_UI(
                                icon: iconFor(type: type),
                                title: titleFor(transaction: t),
                                date: dateString,
                                points: points >= 0 ? "+ \(points)" : "- \(abs(points))",
                                isPositive: points >= 0
                            )
                            
                            Divider().padding(.leading, 80)
                        }
                    }
                    .padding(.horizontal)
                }
                Spacer()
            }
            .toolbar(.hidden, for: .tabBar)
            .background(Color(.white))
            .ignoresSafeArea(edges: .bottom)
        }
    }
    
    // MARK: - Helper
    func formatDate(_ date: Date?) -> String {
        guard let d = date else { return "No date" }
        let f = DateFormatter()
        f.dateStyle = .long
        return f.string(from: d)
    }
    
    // MARK: - Dynamic Transaction Title
    func titleFor(transaction t: Transaction) -> String {
        switch t.transaction_type {
        case "TOP UP":
            return "Top Up Berhasil"
        case "REWARD SURVEY":
            return t.transaction_description ?? "Reward Survey"
        case "COST SURVEY":
            return t.transaction_description ?? "Biaya Membuat Survey"
        case "WITHDRAW":
            return "Withdraw Poin"
        default:
            return t.transaction_description ?? "Transaction"
        }
    }
    // MARK: - Icon Picker
    func iconFor(type: String) -> String {
        switch type {
        case "TOP UP":
            return "arrow.up.circle.fill"
        case "REWARD SURVEY":
            return "gift.fill"
        case "COST SURVEY":
            return "minus.circle.fill"
        case "WITHDRAW":
            return "arrow.down.circle.fill"
        default:
            return "dollarsign.circle.fill"
        }
    }
}
struct TransactionRow_UI: View {
    var icon: String
    var title: String
    var date: String
    var points: String
    var isPositive: Bool
    let darkTeal = Color(red: 12/255, green: 66/255, blue: 84/255)
    var body: some View {
        HStack(alignment: .center, spacing: 15) {
            Image(systemName: icon)
                .font(.system(size: 32))
                .foregroundColor(darkTeal)
                .frame(width: 50, height: 50)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(darkTeal)
                Text(date)
                    .font(.footnote)
                    .foregroundColor(.gray)
            }
            Spacer()
            VStack(alignment: .trailing) {
                Text(points)
                    .font(.headline)
                    .foregroundColor(isPositive ? .green : .red)
                Text("points")
                    .font(.caption)
                    .foregroundColor(isPositive ? .green : .red)
            }
        }
        .padding(.vertical, 15)
    }
}
#Preview {
    ViewPointView()
}
