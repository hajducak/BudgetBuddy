import Combine
@testable import BudgetBuddy
import Foundation

class MockOnboardingInteractor: OnboardingInteractorProtocol {
    var user: User?
    var saveUserDataResult: Result<Void, AppError>?
    
    func saveUserData(user: User, completion: @escaping (Result<Void, AppError>) -> Void) {
        if let result = saveUserDataResult {
            completion(result)
        }
    }
}

class MockOnboardingRouter: OnboardingRouterProtocol {
    var didNavigateToApp = false
    
    func goToApp() {
        didNavigateToApp = true
    }
}

class MockAppCoordinator: AppCoordinator {
    private var _isAuthenticated = false
    private var _showOnboarding = true
    
    override var isAuthenticated: Bool {
        get { _isAuthenticated }
        set { _isAuthenticated = newValue }
    }
    
    override var showOnboarding: Bool {
        get { _showOnboarding }
        set { _showOnboarding = newValue }
    }
}
