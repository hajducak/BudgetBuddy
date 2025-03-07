import SwiftUI
import Combine

class AppCoordinator: ObservableObject {
    @Published var isAuthenticated = false
    
    func start() -> some View {
        if isAuthenticated {
            return AnyView(MainTabView())
        } else {
            return AnyView(AuthView(presenter: createAuthPresenter()))
        }
    }
    
    private func createAuthPresenter() -> AuthPresenter {
        let firebaseManager = FirebaseManager()
        let authService = AuthService()
        let authInteractor = AuthInteractor(
            authService: authService,
            firebaseManager: firebaseManager
        )
        let presenter = AuthPresenter(interactor: authInteractor)
        presenter.authSuccess = { [weak self] in
            self?.isAuthenticated = true
        }
        return presenter
    }
}
