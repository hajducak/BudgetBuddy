import Combine
import LocalAuthentication

protocol AuthPresenterProtocol: AnyObject {
    var authSuccess: ((Bool, User) -> Void)? { get set }

    func login()
    func register()
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
    @Published var showBiometricPrompt = false
    @Published var biometricType: String = "None"
    
    private var cancellables = Set<AnyCancellable>()
    
    var authSuccess: ((Bool, User) -> Void)?
    
    private let interactor: AuthInteractorProtocol
    let keychainService: KeychainService
    private let biometricService: BiometricServiceProtocol
    
    init(interactor: AuthInteractorProtocol, keychainService: KeychainService, biometricService: BiometricServiceProtocol) {
        self.interactor = interactor
        self.keychainService = keychainService
        self.biometricService = biometricService
        
        setupBiometricType()
        setupValidation()
    }
    
    private func setupBiometricType() {
        if biometricService.canUseBiometrics() {
            switch biometricService.getBiometricType() {
            case .faceID:
                biometricType = "Face ID"
            case .touchID:
                biometricType = "Touch ID"
            default:
                biometricType = "None"
            }
        }
    }
    
    private func setupValidation() {
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
            case .success(let user):
                self?.authSuccess?(false, user)
                self?.saveCredentials()
            case .failure(let error):
                self?.toast = Toast(type: .error(error))
            }
        }
    }
    
    func register() {
        self.isLoading = true
        interactor.register(name: name, email: email, password: password) { [weak self] result in
            self?.isLoading = false
            switch result {
            case .success(let user):
                self?.authSuccess?(true, user)
                self?.showBiometricPrompt = self?.biometricService.canUseBiometrics() ?? false
                self?.saveCredentials()
            case .failure(let error):
                self?.toast = Toast(type: .error(error))
            }
        }
    }
    
    func authenticateWithBiometrics() {
        guard biometricService.canUseBiometrics() else {
            toast = Toast(type: .error(AppError.customError("Biometric authentication not available")))
            return
        }
        
        biometricService.authenticate(reason: "Access your BudgetBuddy account") { [weak self] result in
            switch result {
            case .success:
                if let savedEmail = self?.getEmail(),
                   let savedPassword = self?.getPassword() {
                    self?.email = savedEmail
                    self?.password = savedPassword
                    self?.login()
                }
            case .failure(let error):
                if let laError = error as? LAError {
                    switch laError.code {
                    case .userFallback, .biometryLockout:
                        break
                    case .biometryNotEnrolled:
                        self?.toast = Toast(type: .error(AppError.customError("Please set up \(self?.biometricType ?? "biometric authentication") in your device settings")))
                    case .biometryNotAvailable:
                        self?.keychainService.setBiometricEnabled(false)
                        self?.toast = Toast(type: .error(AppError.customError("Biometric authentication is no longer available")))
                    default:
                        self?.toast = Toast(type: .error(AppError.customError(error.localizedDescription)))
                    }
                } else {
                    self?.toast = Toast(type: .error(AppError.customError(error.localizedDescription)))
                }
            }
        }
    }
    
    func enableBiometricAuthentication() {
        keychainService.setBiometricEnabled(true)
        showBiometricPrompt = false
        toast = Toast(type: .success("\(biometricType) enabled successfully"))
    }
    
    private func getPassword() -> String? {
        keychainService.getPassword()
    }
    
    private func getEmail() -> String? {
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
    
    deinit {
        cancellables.removeAll()
    }
}
