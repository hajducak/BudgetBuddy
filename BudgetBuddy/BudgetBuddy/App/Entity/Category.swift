import Foundation

enum CategoryType: String, Codable {
    case income = "Income"
    case expense = "Expense"
}

/// Specific categories inside expenses or incomes
struct Category: Identifiable, Codable {
    var id: String
    var name: String
    var type: CategoryType
    var subcategories: [String]
}

extension Category {
    static let predefinedCategories: [Category] = [
        Category(id: UUID().uuidString, name: "🍏 Groceries", type: .expense, subcategories: ["Food", "Household Items", "Personal Care"]),
        Category(id: UUID().uuidString, name: "🏠 Home", type: .expense, subcategories: ["Rent/Mortgage", "Utilities", "Maintenance"]),
        Category(id: UUID().uuidString, name: "🚗 Transportation", type: .expense, subcategories: ["Fuel", "Public Transit", "Vehicle Maintenance"]),
        Category(id: UUID().uuidString, name: "🎬 Entertainment", type: .expense, subcategories: ["Dining Out", "Movies/Shows", "Hobbies"]),
        Category(id: UUID().uuidString, name: "💪 Health", type: .expense, subcategories: ["Medical", "Pharmacy", "Fitness"]),
        Category(id: UUID().uuidString, name: "🎓 Education", type: .expense, subcategories: ["Tuition", "Books", "Courses"]),
        Category(id: UUID().uuidString, name: "🎁 Gifts", type: .expense, subcategories: ["Birthdays", "Holidays", "Special Occasions"]),
        Category(id: UUID().uuidString, name: "🌍 Others", type: .expense, subcategories: ["Shopping", "Travel", "Miscellaneous"]),
        
        Category(id: UUID().uuidString, name: "💼 Salary", type: .income, subcategories: ["Regular", "Overtime", "Contract"]),
        Category(id: UUID().uuidString, name: "💰 Bonuses", type: .income, subcategories: ["Performance", "Annual", "Special"]),
        Category(id: UUID().uuidString, name: "🎁 Gifts", type: .income, subcategories: ["Personal", "Business", "Inheritance"]),
        Category(id: UUID().uuidString, name: "📈 Investments", type: .income, subcategories: ["Stocks", "Dividends", "Interest"]),
        Category(id: UUID().uuidString, name: "💸 Sales", type: .income, subcategories: ["Personal Items", "Business", "Real Estate"]),
        Category(id: UUID().uuidString, name: "🔀 Other", type: .income, subcategories: ["Freelance", "Rental", "Miscellaneous"])
    ]
}
