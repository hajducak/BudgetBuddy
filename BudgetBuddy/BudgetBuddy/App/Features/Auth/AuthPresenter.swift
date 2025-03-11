import Combine

protocol AuthPresenterProtocol: AnyObject {
    var authSuccess: (() -> Void)? { get set }

    func login()
    func register()

    func getPassword() -> String?
    func getEmail() -> String?
    func generateRandomPassword()
}

class AuthPresenter: AuthPresenterProtocol, ObservableObject {
    @Published var isLoading: Bool = false
    @Published var toast: Toast?
    @Published var selectedTab = 0
    @Published var name = ""
    @Published var email = ""
    @Published var password = ""
    @Published var loginEnabled = false
    @Published var registrationEnabled = false

    private var cancellables = Set<AnyCancellable>()

    var authSuccess: (() -> Void)?
    
    private let interactor: AuthInteractorProtocol
    private let keychainService: KeychainService
    
    init(interactor: AuthInteractorProtocol, keychainService: KeychainService) {
        self.interactor = interactor
        self.keychainService = keychainService

        $email
            .combineLatest($password)
            .map { email, password in
                return email.isValidEmail && password.count >= 6
            }
            .assign(to: \.loginEnabled, on: self)
            .store(in: &cancellables)

        $name
            .combineLatest($password, $email)
            .map { name, password, email in
                return !name.isEmpty && email.isValidEmail && password.count >= 6
            }
            .assign(to: \.registrationEnabled, on: self)
            .store(in: &cancellables)
    }
    
    func login() {
        self.isLoading = true
        interactor.login(email: email, password: password) { [weak self] result in
            self?.isLoading = false
            switch result {
            case .success:
                self?.authSuccess?()
                self?.saveCredentials()
            case .failure(let error):
                self?.toast = Toast(type: .error(.loginError(error)))
            }
        }
    }
    
    func register() {
        self.isLoading = true
        interactor.register(name: name, email: email, password: password) { [weak self] result in
            self?.isLoading = false
            switch result {
            case .success:
                self?.authSuccess?()
                self?.saveCredentials()
            case .failure(let error):
                self?.toast = Toast(type: .error(.registrationError(error)))
            }
        }
    }
    
    func getPassword() -> String? {
        keychainService.getPassword()
    }
    
    func getEmail() -> String? {
        keychainService.getEmail()
    }
    
    private func saveCredentials() {
        keychainService.savePassword(password)
        keychainService.saveEmail(email)
    }
    
    func generateRandomPassword() {
        let length = 12
        let characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()"
        password = String((0..<length).map { _ in characters.randomElement()! })
    }
}
