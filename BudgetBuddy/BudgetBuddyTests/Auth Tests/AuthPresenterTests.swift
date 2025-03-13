import XCTest
@testable import BudgetBuddy

class AuthPresenterTests: XCTestCase {
    var interactor: MockAuthInteractor!
    var keychainService: MockKeychainService!
    var sut: AuthPresenter!
    
    override func setUp() {
        super.setUp()
        interactor = MockAuthInteractor()
        keychainService = MockKeychainService()
        sut = AuthPresenter(interactor: interactor, keychainService: keychainService)
    }
    
    override func tearDown() {
        interactor = nil
        keychainService = nil
        sut = nil
        super.tearDown()
    }
    
    func test_givenData_whenLogin_thenSuccess() {
        let expectation = self.expectation(description: "Login success")
        let testUser = User(id: "test-id", name: "Test User", email: "test@example.com")
        interactor.loginResult = .success(testUser)
        
        sut.email = "test@example.com"
        sut.password = "123456"
        
        var authSuccessCalled = false
        var isNew = false
        var receivedUser: User?
        
        sut.authSuccess = { new, user in
            authSuccessCalled = true
            isNew = new
            receivedUser = user
            expectation.fulfill()
        }
        
        sut.login()
        
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
        
        sut.email = "test@example.com"
        sut.password = "123456"
        
        sut.login()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1)
        XCTAssertTrue(interactor.loginCalled)
        XCTAssertNotNil(sut.toast)
        if case .error = sut.toast?.type {
            // Toast type is correct
        } else {
            XCTFail("Wrong toast type")
        }
    }
    
    func test_givenData_whenRegister_thenSuccess() {
        let expectation = self.expectation(description: "Register success")
        let testUser = User(id: "test-id", name: "Test User", email: "test@example.com")
        interactor.registerResult = .success(testUser)
        
        sut.name = "Test User"
        sut.email = "test@example.com"
        sut.password = "123456"
        
        var authSuccessCalled = false
        var isNew = false
        var receivedUser: User?
        
        sut.authSuccess = { new, user in
            authSuccessCalled = true
            isNew = new
            receivedUser = user
            expectation.fulfill()
        }
        
        sut.register()
        
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
        
        sut.name = "Test User"
        sut.email = "test@example.com"
        sut.password = "123456"
        
        sut.register()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1)
        XCTAssertTrue(interactor.registerCalled)
        XCTAssertNotNil(sut.toast)
        if case .error = sut.toast?.type {
            // Toast type is correct
        } else {
            XCTFail("Wrong toast type")
        }
    }
    
    func test_givenData_whenGetCredentials_thenDataAreEqual() {
        keychainService.storedEmail = "stored@example.com"
        keychainService.storedPassword = "storedpassword"
        
        let email = sut.getEmail()
        let password = sut.getPassword()
        
        XCTAssertEqual(email, "stored@example.com")
        XCTAssertEqual(password, "storedpassword")
    }
    
    func test_whenGenerateRandomPassword_thenPasswordIsSet() {
        sut.generateRandomPassword()
        
        XCTAssertFalse(sut.password.isEmpty)
        XCTAssertGreaterThanOrEqual(sut.password.count, 6)
    }
    
    func test_givenData_thenLoginIsEnabled() {
        sut.email = "not-an-email"
        sut.password = "123"

        XCTAssertFalse(sut.loginEnabled)

        sut.email = "valid@example.com"
        sut.password = "123456"

        XCTAssertTrue(sut.loginEnabled)
    }
    
    func test_givenData_thenRegisterIsEnabled() {
        sut.name = ""
        sut.email = "not-an-email"
        sut.password = "123"
        
        XCTAssertFalse(sut.registrationEnabled)
        
        sut.name = "Test User"
        sut.email = "valid@example.com"
        sut.password = "123456"
        
        XCTAssertTrue(sut.registrationEnabled)
    }
}
