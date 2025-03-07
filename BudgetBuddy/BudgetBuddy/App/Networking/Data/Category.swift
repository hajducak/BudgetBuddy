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
}

/* Categories names:
Expenses:
    Groceries
    Home
    Transportation
    Entertainment
    Health
    Education
    Gifts
    Others
Incomes:
    Salary
    Bonuses
    Gifts
    Investments
    Sales
    Other
*/
