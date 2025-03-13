import XCTest
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
