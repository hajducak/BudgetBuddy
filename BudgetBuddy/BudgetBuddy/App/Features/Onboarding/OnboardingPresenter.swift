import Foundation
import Combine

class OnboardingPresenter: ObservableObject {
    @Published var balance: String = ""
    @Published var currency: String = ""
    @Published var selectedCategories: [Category] = []
    @Published var isFinishOnbaordingEnabled: Bool = false
    @Published var onbaordingIsLoading: Bool = false
    @Published var toast: Toast?
    
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

    func completeOnboarding() {
        guard let balance = Double(balance) else { return }
        let wallet = Wallet(id: UUID().uuidString, balance: balance, currency: currency, transactions: [])
        guard var user = interactor.user else { return }
        user.wallets = [wallet]
        user.categories = selectedCategories
        onbaordingIsLoading = true
        interactor.saveUserData(user: user) { [weak self] result in
            self?.onbaordingIsLoading = false
            switch result {
            case .success:
                self?.router.goToApp()
            case .failure(let error):
                self?.toast = Toast(type: .error(error))
            }
        }
    }
    
    deinit {
        cancellables.removeAll()
    }
}
