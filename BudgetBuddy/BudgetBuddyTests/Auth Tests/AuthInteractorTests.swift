import XCTest
@testable import BudgetBuddy

class AuthInteractorTests: XCTestCase {
    var authService: MockAuthService!
    var firebaseManager: MockFirebaseManager!
    var interactor: AuthInteractor!
    
    override func setUp() {
        super.setUp()
        authService = MockAuthService()
        firebaseManager = MockFirebaseManager()
        interactor = AuthInteractor(authService: authService, firebaseManager: firebaseManager)
    }
    
    override func tearDown() {
        authService = nil
        firebaseManager = nil
        interactor = nil
        super.tearDown()
    }
    
    func test_givenData_whenRegister_thenSuccess() {
        let expectation = self.expectation(description: "Register success")
        let testUser = User(id: "test-id", name: "Test User", email: "test@example.com")
        authService.registerResult = .success(testUser)
        firebaseManager.saveUserResult = .success(())
        
        var resultUser: User?
        var resultError: AppError?
        
        interactor.register(name: "Test User", email: "test@example.com", password: "123456") { result in
            switch result {
            case .success(let user):
                resultUser = user
            case .failure(let error):
                resultError = error
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1)
        XCTAssertTrue(authService.registerCalled)
        XCTAssertTrue(firebaseManager.saveUserCalled)
        XCTAssertNotNil(resultUser)
        XCTAssertNil(resultError)
        XCTAssertEqual(resultUser?.name, "Test User")
        XCTAssertEqual(resultUser?.email, "test@example.com")
    }
    
    func test_givenError_whenRegister_thenFailure() {
        let expectation = self.expectation(description: "Register failure")
        let testError = NSError(domain: "test", code: 123, userInfo: nil)
        authService.registerResult = .failure(.registrationError(testError))
        
        var resultUser: User?
        var resultError: AppError?
        
        interactor.register(name: "Test User", email: "test@example.com", password: "123456") { result in
            switch result {
            case .success(let user):
                resultUser = user
            case .failure(let error):
                resultError = error
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1)
        XCTAssertTrue(authService.registerCalled)
        XCTAssertFalse(firebaseManager.saveUserCalled)
        XCTAssertNil(resultUser)
        XCTAssertNotNil(resultError)
        
        if case .registrationError = resultError {
            // Error type is correct
        } else {
            XCTFail("Wrong error type")
        }
    }
    
    func test_givenData_whenLogin_thenSuccess() {
        let expectation = self.expectation(description: "Login success")
        let testUser = User(id: "test-id", name: "Test User", email: "test@example.com")
        authService.loginResult = .success(testUser)
        
        var resultUser: User?
        var resultError: AppError?
        
        interactor.login(email: "test@example.com", password: "123456") { result in
            switch result {
            case .success(let user):
                resultUser = user
            case .failure(let error):
                resultError = error
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1)
        XCTAssertTrue(authService.loginCalled)
        XCTAssertNotNil(resultUser)
        XCTAssertNil(resultError)
        XCTAssertEqual(resultUser?.email, "test@example.com")
    }
    
    func test_givenError_whenLogin_thenFailure() {
        let expectation = self.expectation(description: "Login failure")
        let testError = NSError(domain: "test", code: 123, userInfo: nil)
        authService.loginResult = .failure(.loginError(testError))
        
        var resultUser: User?
        var resultError: AppError?
        
        interactor.login(email: "test@example.com", password: "123456") { result in
            switch result {
            case .success(let user):
                resultUser = user
            case .failure(let error):
                resultError = error
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1)
        XCTAssertTrue(authService.loginCalled)
        XCTAssertNil(resultUser)
        XCTAssertNotNil(resultError)
        
        if case .loginError = resultError {
            // Error type is correct
        } else {
            XCTFail("Wrong error type")
        }
    }
}
