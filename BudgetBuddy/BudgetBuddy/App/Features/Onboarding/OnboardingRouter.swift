import SwiftUI

protocol OnboardingRouterProtocol {
    func goToApp()
}

class OnboardingRouter: OnboardingRouterProtocol {
    weak var coordinator: AppCoordinator?
    
    init(coordinator: AppCoordinator) {
        self.coordinator = coordinator
    }
    
    func goToApp() {
        coordinator?.isAuthenticated = true
        coordinator?.showOnboarding = false
    }
}
