import XCTest
@testable import BudgetBuddy

class AuthPresenterTests: XCTestCase {
    var interactor: MockAuthInteractor!
    var keychainService: MockKeychainService!
    var presenter: AuthPresenter!
    
    override func setUp() {
        super.setUp()
        interactor = MockAuthInteractor()
        keychainService = MockKeychainService()
        presenter = AuthPresenter(interactor: interactor, keychainService: keychainService)
    }
    
    override func tearDown() {
        interactor = nil
        keychainService = nil
        presenter = nil
        super.tearDown()
    }
    
    func test_givenData_whenLogin_thenSuccess() {
        let expectation = self.expectation(description: "Login success")
        let testUser = User(id: "test-id", name: "Test User", email: "test@example.com")
        interactor.loginResult = .success(testUser)
        
        presenter.email = "test@example.com"
        presenter.password = "123456"
        
        var authSuccessCalled = false
        var isNew = false
        var receivedUser: User?
        
        presenter.authSuccess = { new, user in
            authSuccessCalled = true
            isNew = new
            receivedUser = user
            expectation.fulfill()
        }
        
        presenter.login()
        
        waitForExpectations(timeout: 1)
        XCTAssertTrue(interactor.loginCalled)
        XCTAssertTrue(authSuccessCalled)
        XCTAssertFalse(isNew)
        XCTAssertEqual(receivedUser?.id, testUser.id)
        XCTAssertEqual(keychainService.savedEmail, "test@example.com")
        XCTAssertEqual(keychainService.savedPassword, "123456")
    }
    
    func test_givenError_whenLogin_thenFailure() {
        let expectation = self.expectation(description: "Login failure")
        let testError = NSError(domain: "test", code: 123, userInfo: nil)
        interactor.loginResult = .failure(.loginError(testError))
        
        presenter.email = "test@example.com"
        presenter.password = "123456"
        
        presenter.login()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1)
        XCTAssertTrue(interactor.loginCalled)
        XCTAssertNotNil(presenter.toast)
        if case .error = presenter.toast?.type {
            // Toast type is correct
        } else {
            XCTFail("Wrong toast type")
        }
    }
    
    func test_givenData_whenRegister_thenSuccess() {
        let expectation = self.expectation(description: "Register success")
        let testUser = User(id: "test-id", name: "Test User", email: "test@example.com")
        interactor.registerResult = .success(testUser)
        
        presenter.name = "Test User"
        presenter.email = "test@example.com"
        presenter.password = "123456"
        
        var authSuccessCalled = false
        var isNew = false
        var receivedUser: User?
        
        presenter.authSuccess = { new, user in
            authSuccessCalled = true
            isNew = new
            receivedUser = user
            expectation.fulfill()
        }
        
        presenter.register()
        
        waitForExpectations(timeout: 1)
        XCTAssertTrue(interactor.registerCalled)
        XCTAssertTrue(authSuccessCalled)
        XCTAssertTrue(isNew)
        XCTAssertEqual(receivedUser?.id, testUser.id)
        XCTAssertEqual(keychainService.savedEmail, "test@example.com")
        XCTAssertEqual(keychainService.savedPassword, "123456")
    }
    
    func test_givenError_whenRegister_thenFailure() {
        let expectation = self.expectation(description: "Register failure")
        let testError = NSError(domain: "test", code: 123, userInfo: nil)
        interactor.registerResult = .failure(.registrationError(testError))
        
        presenter.name = "Test User"
        presenter.email = "test@example.com"
        presenter.password = "123456"
        
        presenter.register()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1)
        XCTAssertTrue(interactor.registerCalled)
        XCTAssertNotNil(presenter.toast)
        if case .error = presenter.toast?.type {
            // Toast type is correct
        } else {
            XCTFail("Wrong toast type")
        }
    }
    
    func test_givenData_whenGetCredentials_thenDataAreEqual() {
        keychainService.storedEmail = "stored@example.com"
        keychainService.storedPassword = "storedpassword"
        
        let email = presenter.getEmail()
        let password = presenter.getPassword()
        
        XCTAssertEqual(email, "stored@example.com")
        XCTAssertEqual(password, "storedpassword")
    }
    
    func test_whenGenerateRandomPassword_thenPasswordIsSet() {
        presenter.generateRandomPassword()
        
        XCTAssertFalse(presenter.password.isEmpty)
        XCTAssertGreaterThanOrEqual(presenter.password.count, 6)
    }
    
    func test_givenData_thenLoginIsEnabled() {
        presenter.email = "not-an-email"
        presenter.password = "123"

        XCTAssertFalse(presenter.loginEnabled)

        presenter.email = "valid@example.com"
        presenter.password = "123456"

        XCTAssertTrue(presenter.loginEnabled)
    }
    
    func test_givenData_thenRegisterIsEnabled() {
        presenter.name = ""
        presenter.email = "not-an-email"
        presenter.password = "123"
        
        XCTAssertFalse(presenter.registrationEnabled)
        
        presenter.name = "Test User"
        presenter.email = "valid@example.com"
        presenter.password = "123456"
        
        XCTAssertTrue(presenter.registrationEnabled)
    }
}
