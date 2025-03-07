import Foundation

struct User: Identifiable, Codable {
    var id: String
    var name: String
    var email: String
    var wallets: [Wallet]?
    var categories: [Category]?
    
    init(id: String, name: String, email: String, wallets: [Wallet]? = nil, categories: [Category]? = nil) {
        self.id = id
        self.name = name
        self.email = email
        self.wallets = wallets
        self.categories = categories
    }
}
