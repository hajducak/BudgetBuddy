import SwiftUI
import Combine

class AppCoordinator: ObservableObject {
    @Published var isAuthenticated = false
    @Published var showOnboarding = false
    var user: User?
    
    func start() -> some View {
        // return AnyView(OnboardingView(presenter: createOnboardingPresenter())) // TESTING ONBOARDING
        if isAuthenticated {
            return AnyView(MainTabView())
        } else if showOnboarding {
            return AnyView(OnboardingView(presenter: createOnboardingPresenter()))
        } else {
            return AnyView(AuthView(presenter: createAuthPresenter()))
        }
    }
    
    private func createOnboardingPresenter() -> OnboardingPresenter {
        // self.user = .init(id: "dummy", name: "name", email: "esges@gmail.com") // TESTING ONBOARDING
        let firebaseManager = FirebaseManager()
        let interactor = OnboardingInteractor(firebaseManager: firebaseManager, user: user)
        let router = OnboardingRouter(coordinator: self)
        return OnboardingPresenter(interactor: interactor, router: router)
    }
    
    private func createAuthPresenter() -> AuthPresenter {
        let firebaseManager = FirebaseManager()
        let authService = AuthService()
        let authInteractor = AuthInteractor(
            authService: authService,
            firebaseManager: firebaseManager
        )
        let keychainService = KeychainService()
        let presenter = AuthPresenter(interactor: authInteractor, keychainService: keychainService)
        presenter.authSuccess = { [weak self] isRegistration, user in
            self?.user = user
            if isRegistration {
                self?.showOnboarding = true
            } else {
                self?.isAuthenticated = true
            }
        }
        return presenter
    }
}
