import Foundation
import Combine

class OnboardingPresenter: ObservableObject {
    @Published var balance: String = ""
    @Published var currency: String = ""
    @Published var selectedCategories: [Category] = []
    @Published var isFinishOnbaordingEnabled: Bool = false
    
    let defaultCategories: [Category] = [
        Category(id: UUID().uuidString, name: "🍏 Groceries", type: .expense),
        Category(id: UUID().uuidString, name: "🏠 Home", type: .expense),
        Category(id: UUID().uuidString, name: "🚗 Transportation", type: .expense),
        Category(id: UUID().uuidString, name: "🎬 Entertainment", type: .expense),
        Category(id: UUID().uuidString, name: "💪 Health", type: .expense),
        Category(id: UUID().uuidString, name: "🎓 Education", type: .expense),
        Category(id: UUID().uuidString, name: "🎁 Gifts", type: .expense),
        Category(id: UUID().uuidString, name: "🌍 Others", type: .expense),
        Category(id: UUID().uuidString, name: "💼 Salary", type: .income),
        Category(id: UUID().uuidString, name: "💰 Bonuses", type: .income),
        Category(id: UUID().uuidString, name: "🎁 Gifts", type: .income),
        Category(id: UUID().uuidString, name: "📈 Investments", type: .income),
        Category(id: UUID().uuidString, name: "💸 Sales", type: .income),
        Category(id: UUID().uuidString, name: "🔀 Other", type: .income)
    ]
    
    private var cancellables = Set<AnyCancellable>()
    private let interactor: OnboardingInteractorProtocol
    private let router: OnboardingRouterProtocol
    
    init(interactor: OnboardingInteractorProtocol, router: OnboardingRouterProtocol) {
        self.interactor = interactor
        self.router = router
        
        $currency
            .combineLatest($balance, $selectedCategories)
            .map { (currency, balance, selectedCategories) in
                return !currency.isEmpty && !balance.isEmpty && !selectedCategories.isEmpty
            }.assign(to: \.isFinishOnbaordingEnabled, on: self)
            .store(in: &cancellables)
    }
    
    func toggleCategorySelection(_ category: Category) {
        if selectedCategories.contains(where: { $0.id == category.id }) {
            selectedCategories.removeAll { $0.id == category.id }
        } else {
            selectedCategories.append(category)
        }
    }
    // TODO: use combine anyPublisher cancelables
    func completeOnboarding() {
        guard let balance = Double(balance) else { return }
        let wallet = Wallet(id: UUID().uuidString, balance: balance, currency: currency, transactions: [])
        guard var user = interactor.user else { return }
        user.wallets = [wallet]
        user.categories = selectedCategories
        
        interactor.saveUserData(user: user) { result in
            switch result {
            case .success:
                self.router.goToApp()
            case .failure(let error):
                print("Failed to save user data: \(error)")
            }
        }
    }
    
    deinit {
        cancellables.removeAll()
    }
}
