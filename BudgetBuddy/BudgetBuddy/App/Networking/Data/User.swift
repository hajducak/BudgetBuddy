import Foundation

struct User: Identifiable, Codable {
    var id: String
    var name: String
    var email: String
    var wallets: [Wallet]
    var categories: [Category]
}
