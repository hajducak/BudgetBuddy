import Foundation

struct Transaction: Identifiable, Codable {
    var id: String
    var amount: Double
    var category: Category
    var note: String?
    var date: Date
}
