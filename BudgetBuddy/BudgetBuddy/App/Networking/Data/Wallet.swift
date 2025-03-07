import Foundation

struct Wallet: Identifiable, Codable {
    var id: String
    var balance: Double
    var currency: String
    var transactions: [Transaction]
}
