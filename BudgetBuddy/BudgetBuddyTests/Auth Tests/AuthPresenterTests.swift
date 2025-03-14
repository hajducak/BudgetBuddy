import XCTest
import LocalAuthentication
@testable import BudgetBuddy

class AuthPresenterTests: XCTestCase {
    var interactor: MockAuthInteractor!
    var keychainService: MockKeychainService!
    var biometricService: MockBiometricService!
    var sut: AuthPresenter!
    
    override func setUp() {
        super.setUp()
        interactor = MockAuthInteractor()
        keychainService = MockKeychainService()
        biometricService = MockBiometricService()
        sut = AuthPresenter(
            interactor: interactor,
            keychainService: keychainService,
            biometricService: biometricService
        )
    }
    
    override func tearDown() {
        interactor = nil
        keychainService = nil
        biometricService = nil
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
    
    // MARK: - Biometric Authentication Tests
    
    func test_givenBiometricsAvailable_whenInitialized_thenBiometricTypeIsSet() {
        biometricService.canUseBiometricsResult = true
        biometricService.biometricType = .faceID
        
        sut = AuthPresenter(
            interactor: interactor,
            keychainService: keychainService,
            biometricService: biometricService
        )
        
        XCTAssertTrue(biometricService.canUseBiometricsCalled)
        XCTAssertTrue(biometricService.getBiometricTypeCalled)
        XCTAssertEqual(sut.biometricType, .faceID)
    }
    
    func test_givenBiometricsNotAvailable_whenInitialized_thenBiometricTypeIsNone() {
        biometricService.canUseBiometricsResult = false
        
        sut = AuthPresenter(
            interactor: interactor,
            keychainService: keychainService,
            biometricService: biometricService
        )
        
        XCTAssertTrue(biometricService.canUseBiometricsCalled)
        XCTAssertEqual(sut.biometricType, .none)
    }
    
    func test_givenBiometricsAvailable_whenAuthenticating_thenSuccess() {
        let expectation = self.expectation(description: "Biometric authentication success")
        biometricService.canUseBiometricsResult = true
        biometricService.authenticateResult = .success(())
        keychainService.storedEmail = "test@example.com"
        keychainService.storedPassword = "password123"
        
        let testUser = User(id: "test-id", name: "Test User", email: "test@example.com")
        interactor.loginResult = .success(testUser)
        
        var authSuccessCalled = false
        sut.authSuccess = { isNew, _ in
            authSuccessCalled = true
            XCTAssertFalse(isNew)
            expectation.fulfill()
        }
        
        sut.authenticateWithBiometrics()
        
        waitForExpectations(timeout: 1)
        XCTAssertTrue(biometricService.authenticateCalled)
        XCTAssertEqual(biometricService.lastAuthenticationReason, "Access your BudgetBuddy account")
        XCTAssertTrue(authSuccessCalled)
        XCTAssertEqual(sut.email, "test@example.com")
        XCTAssertEqual(sut.password, "password123")
    }
    
    func test_givenBiometricsNotAvailable_whenAuthenticating_thenFailure() {
        biometricService.canUseBiometricsResult = false
        
        sut.authenticateWithBiometrics()
        
        XCTAssertNotNil(sut.toast)
        if case .error(let error) = sut.toast?.type {
            XCTAssertEqual(error.localizedDescription, AppError.customError("Biometric authentication not available").localizedDescription)
        } else {
            XCTFail("Wrong toast type")
        }
    }
    
    func test_givenBiometricsNotEnrolled_whenAuthenticating_thenProperError() {
        let expectation = self.expectation(description: "Biometric authentication failure")
        biometricService.canUseBiometricsResult = true
        biometricService.authenticateResult = .failure(LAError(.biometryNotEnrolled))
        sut.biometricType = .faceID
        
        sut.authenticateWithBiometrics()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1)
        XCTAssertNotNil(sut.toast)
        if case .error(let error) = sut.toast?.type {
            let expectedMessage = "Please set up \(sut.biometricType.displayName) in your device settings"
            XCTAssertEqual(error.localizedDescription, AppError.customError(expectedMessage).localizedDescription)
        } else {
            XCTFail("Wrong toast type")
        }
    }
    
    func test_whenEnablingBiometrics_thenStateIsUpdated() {
        sut.biometricType = .faceID
        sut.showBiometricPrompt = true
        
        sut.enableBiometricAuthentication()
        
        XCTAssertTrue(keychainService.savedBiometricEnabled == true)
        XCTAssertFalse(sut.showBiometricPrompt)
        XCTAssertNotNil(sut.toast)
        if case .success(let message) = sut.toast?.type {
            XCTAssertEqual(message, "Face ID enabled successfully")
        } else {
            XCTFail("Wrong toast type")
        }
    }
    
    func test_givenSuccessfulRegistration_whenBiometricsAvailable_thenPromptShown() {
        let expectation = self.expectation(description: "Registration success")
        let testUser = User(id: "test-id", name: "Test User", email: "test@example.com")
        interactor.registerResult = .success(testUser)
        biometricService.canUseBiometricsResult = true
        
        sut.register()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1)
        XCTAssertTrue(sut.showBiometricPrompt)
    }
}
