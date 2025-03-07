import Combine

protocol AuthPresenterProtocol: AnyObject {
    var authSuccess: (() -> Void)? { get set }

    func login(email: String, password: String)
    func register(name: String, email: String, password: String)
}

class AuthPresenter: AuthPresenterProtocol, ObservableObject {
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    var authSuccess: (() -> Void)?
    
    private let interactor: AuthInteractorProtocol
    
    init(interactor: AuthInteractorProtocol) {
        self.interactor = interactor
    }
    
    func login(email: String, password: String) {
        self.isLoading = true
        interactor.login(email: email, password: password) { [weak self] result in
            self?.isLoading = false
            switch result {
            case .success:
                self?.authSuccess?()
            case .failure(let error):
                self?.errorMessage = "Login failed: \(error.localizedDescription)"
            }
        }
    }
    
    func register(name: String, email: String, password: String) {
        self.isLoading = true
        interactor.register(name: name, email: email, password: password) { [weak self] result in
            self?.isLoading = false
            switch result {
            case .success:
                self?.authSuccess?()
            case .failure(let error):
                self?.errorMessage =  "Registration failed: \(error.localizedDescription)"
            }
        }
    }
}
