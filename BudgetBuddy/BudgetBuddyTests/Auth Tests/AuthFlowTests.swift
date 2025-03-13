import XCTest
@testable import BudgetBuddy

class AuthFlowTests: XCTestCase {
    var authService: MockAuthService!
    var firebaseManager: MockFirebaseManager!
    var keychainService: MockKeychainService!
    var sut: MockAuthRouter!
    
    override func setUp() {
        super.setUp()
        authService = MockAuthService()
        firebaseManager = MockFirebaseManager()
        keychainService = MockKeychainService()
        sut = MockAuthRouter()
    }
    
    override func tearDown() {
        authService = nil
        firebaseManager = nil
        keychainService = nil
        sut = nil
        super.tearDown()
    }
    
    func test_givenData_whenAuthSuccess_thenLoginFlowIsComplete() {
        let testUser = User(id: "test-id", name: "Test User", email: "test@example.com")
        authService.loginResult = .success(testUser)
        
        let interactor = AuthInteractor(authService: authService, firebaseManager: firebaseManager)
        let presenter = AuthPresenter(interactor: interactor, keychainService: keychainService)
        
        let expectation = self.expectation(description: "Login flow completes")
        
        presenter.email = "test@example.com"
        presenter.password = "password123"
        
        presenter.authSuccess = { isNew, user in
            if !isNew {
                self.sut.navigateToHome()
            }
            expectation.fulfill()
        }
        
        presenter.login()
        
        waitForExpectations(timeout: 1)
        
        XCTAssertTrue(authService.loginCalled)
        XCTAssertTrue(sut.navigateToHomeCalled)
        XCTAssertEqual(keychainService.savedEmail, "test@example.com")
        XCTAssertEqual(keychainService.savedPassword, "password123")
    }
    
    func test_givenData_whenAuthSuccess_thenRegistrationFlowIsComplete() {
        let testUser = User(id: "test-id", name: "New User", email: "new@example.com")
        authService.registerResult = .success(testUser)
        firebaseManager.saveUserResult = .success(())
        
        let interactor = AuthInteractor(authService: authService, firebaseManager: firebaseManager)
        let presenter = AuthPresenter(interactor: interactor, keychainService: keychainService)
        
        let expectation = self.expectation(description: "Registration flow completes")
        
        presenter.name = "New User"
        presenter.email = "new@example.com"
        presenter.password = "password123"
        
        presenter.authSuccess = { isNew, user in
            if isNew {
                self.sut.navigateToHome()
            }
            expectation.fulfill()
        }
        
        presenter.register()
        
        waitForExpectations(timeout: 1)
        
        XCTAssertTrue(authService.registerCalled)
        XCTAssertTrue(sut.navigateToHomeCalled)
        XCTAssertEqual(keychainService.savedEmail, "new@example.com")
        XCTAssertEqual(keychainService.savedPassword, "password123")
    }
}
