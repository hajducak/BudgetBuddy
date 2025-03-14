import XCTest
@testable import BudgetBuddy

class AuthServiceTests: XCTestCase {
    var biometricService: MockBiometricService!
    var mockAuthService: MockAuthService!
    var mockFirebaseManager: MockFirebaseManager!
    var mockKeychainService: MockKeychainService!
    var interactor: AuthInteractor!
    var presenter: AuthPresenter!
    
    override func setUp() {
        super.setUp()
        mockAuthService = MockAuthService()
        mockFirebaseManager = MockFirebaseManager()
        mockKeychainService = MockKeychainService()
        biometricService = MockBiometricService()
        interactor = AuthInteractor(authService: mockAuthService, firebaseManager: mockFirebaseManager)
        presenter = AuthPresenter(interactor: interactor, keychainService: mockKeychainService, biometricService: biometricService)
    }
    
    override func tearDown() {
        mockAuthService = nil
        mockFirebaseManager = nil
        mockKeychainService = nil
        interactor = nil
        presenter = nil
        super.tearDown()
    }
    
    func test_givenError_whenAuthService_thenFailures() {
        let expectation = self.expectation(description: "Service error handled")
        let testError = NSError(domain: "auth", code: 1001, userInfo: [NSLocalizedDescriptionKey: "Invalid credentials"])
        mockAuthService.loginResult = .failure(.loginError(testError))
        
        presenter.email = "test@example.com"
        presenter.password = "wrongpassword"
        presenter.login()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1)
        XCTAssertNotNil(presenter.toast)
        XCTAssertFalse(presenter.isLoading)
        XCTAssertNil(mockKeychainService.savedEmail)
    }
    
    func test_givenSuccess_whenAuthService_thenUserLoggedIn() {
        let expectation = self.expectation(description: "Login successful")
        let testUser = User(id: "test-id", name: "Test User", email: "test@example.com")
        mockAuthService.loginResult = .success(testUser)
        
        presenter.email = "test@example.com"
        presenter.password = "correctpassword"
        presenter.login()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1)
        XCTAssertNil(presenter.toast)
        XCTAssertFalse(presenter.isLoading)
        XCTAssertEqual(mockKeychainService.savedEmail, "test@example.com")
    }
    
    func test_givenError_whenRegister_thenFirebaseManagerFailure() {
        let expectation = self.expectation(description: "Firebase error handled")
        let testUser = User(id: "test-id", name: "Test User", email: "test@example.com")
        let testError = AppError.customError("Firebase error")
        
        mockAuthService.registerResult = .success(testUser)
        mockFirebaseManager.saveUserResult = .failure(testError)
        
        presenter.name = "Test User"
        presenter.email = "test@example.com"
        presenter.password = "password123"
        presenter.register()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1)
        XCTAssertNotNil(presenter.toast)
        XCTAssertFalse(presenter.isLoading)
        XCTAssertNil(mockKeychainService.savedEmail)
    }
    
    func test_givenSuccess_whenRegister_thenUserSavedSuccessfully() {
        let expectation = self.expectation(description: "User registered successfully")
        let testUser = User(id: "test-id", name: "Test User", email: "test@example.com")
        
        mockAuthService.registerResult = .success(testUser)
        mockFirebaseManager.saveUserResult = .success(())
        
        presenter.name = "Test User"
        presenter.email = "test@example.com"
        presenter.password = "password123"
        presenter.register()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1)
        XCTAssertNil(presenter.toast)
        XCTAssertFalse(presenter.isLoading)
        XCTAssertEqual(mockKeychainService.savedEmail, "test@example.com")
    }
}
