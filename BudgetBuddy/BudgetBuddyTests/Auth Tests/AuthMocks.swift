import XCTest
import LocalAuthentication
@testable import BudgetBuddy

class MockAuthService: AuthServiceProtocol {
    var registerResult: Result<User, AppError>?
    var loginResult: Result<User, AppError>?
    var logoutResult: Result<Void, AppError>?
    
    var registerCalled = false
    var loginCalled = false
    var logoutCalled = false
    
    func register(email: String, password: String, completion: @escaping (Result<User, AppError>) -> Void) {
        registerCalled = true
        if let result = registerResult {
            completion(result)
        }
    }
    
    func login(email: String, password: String, completion: @escaping (Result<User, AppError>) -> Void) {
        loginCalled = true
        if let result = loginResult {
            completion(result)
        }
    }
    
    func logout(completion: @escaping (Result<Void, AppError>) -> Void) {
        logoutCalled = true
        if let result = logoutResult {
            completion(result)
        }
    }
}

class MockFirebaseManager: FirebaseManagerProtocol {
    var saveUserResult: Result<Void, AppError>?
    var saveUserCalled = false
    
    func saveUserToFirestore(user: User, completion: @escaping (Result<Void, AppError>) -> Void) {
        saveUserCalled = true
        if let result = saveUserResult {
            completion(result)
        }
    }
}

class MockKeychainService: KeychainService {
    var savedPassword: String?
    var savedEmail: String?
    var storedPassword: String?
    var storedEmail: String?
    var savedBiometricEnabled: Bool?
    var storedBiometricEnabled: Bool = false
    
    override func savePassword(_ password: String) {
        savedPassword = password
    }
    
    override func saveEmail(_ email: String) {
        savedEmail = email
    }
    
    override func getPassword() -> String? {
        return storedPassword
    }
    
    override func getEmail() -> String? {
        return storedEmail
    }
    
    override func setBiometricEnabled(_ enabled: Bool) {
        savedBiometricEnabled = enabled
    }
    
    override func isBiometricEnabled() -> Bool {
        return storedBiometricEnabled
    }
    
    override func clearCredentials() {
        savedPassword = nil
        savedEmail = nil
        storedPassword = nil
        storedEmail = nil
    }
}

class MockAuthRouter: AuthRouterProtocol {
    var navigateToHomeCalled = false
    
    func navigateToHome() {
        navigateToHomeCalled = true
    }
}

class MockAuthInteractor: AuthInteractorProtocol {
    var registerResult: Result<User, AppError>?
    var loginResult: Result<User, AppError>?
    
    var registerCalled = false
    var loginCalled = false
    
    var capturedName: String?
    var capturedEmail: String?
    var capturedPassword: String?
    
    func register(name: String, email: String, password: String, completion: @escaping (Result<User, AppError>) -> Void) {
        registerCalled = true
        capturedName = name
        capturedEmail = email
        capturedPassword = password
        
        if let result = registerResult {
            completion(result)
        }
    }
    
    func login(email: String, password: String, completion: @escaping (Result<User, AppError>) -> Void) {
        loginCalled = true
        capturedEmail = email
        capturedPassword = password
        
        if let result = loginResult {
            completion(result)
        }
    }
}

class MockBiometricService: BiometricServiceProtocol {
    var canUseBiometricsResult = false
    var biometricType: LABiometryType = .none
    var authenticateResult: Result<Void, Error> = .success(())
    
    var canUseBiometricsCalled = false
    var getBiometricTypeCalled = false
    var authenticateCalled = false
    var lastAuthenticationReason: String?
    
    func canUseBiometrics() -> Bool {
        canUseBiometricsCalled = true
        return canUseBiometricsResult
    }
    
    func getBiometricType() -> LABiometryType {
        getBiometricTypeCalled = true
        return biometricType
    }
    
    func authenticate(reason: String, completion: @escaping (Result<Void, Error>) -> Void) {
        authenticateCalled = true
        lastAuthenticationReason = reason
        completion(authenticateResult)
    }
}
