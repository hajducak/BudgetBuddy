import XCTest
import LocalAuthentication
@testable import BudgetBuddy

class AuthFlowTests: XCTestCase {
    var authService: MockAuthService!
    var firebaseManager: MockFirebaseManager!
    var keychainService: MockKeychainService!
    var biometricService: MockBiometricService!
    var sut: MockAuthRouter!
    
    override func setUp() {
        super.setUp()
        authService = MockAuthService()
        firebaseManager = MockFirebaseManager()
        keychainService = MockKeychainService()
        biometricService = MockBiometricService()
        sut = MockAuthRouter()
    }
    
    override func tearDown() {
        authService = nil
        firebaseManager = nil
        keychainService = nil
        biometricService = nil
        sut = nil
        super.tearDown()
    }
    
    func test_givenData_whenAuthSuccess_thenLoginFlowIsComplete() {
        let testUser = User(id: "test-id", name: "Test User", email: "test@example.com")
        authService.loginResult = .success(testUser)
        
        let interactor = AuthInteractor(authService: authService, firebaseManager: firebaseManager)
        let presenter = AuthPresenter(
            interactor: interactor,
            keychainService: keychainService,
            biometricService: biometricService
        )
        
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
        biometricService.canUseBiometricsResult = true
        
        let interactor = AuthInteractor(authService: authService, firebaseManager: firebaseManager)
        let presenter = AuthPresenter(
            interactor: interactor,
            keychainService: keychainService,
            biometricService: biometricService
        )
        
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
        XCTAssertTrue(presenter.showBiometricPrompt)
    }
    
    func test_givenBiometrics_whenAuthSuccess_thenBiometricLoginFlowIsComplete() {
        let testUser = User(id: "test-id", name: "Test User", email: "test@example.com")
        authService.loginResult = .success(testUser)
        biometricService.canUseBiometricsResult = true
        biometricService.biometricType = .faceID
        keychainService.storedBiometricEnabled = true
        keychainService.storedEmail = "test@example.com"
        keychainService.storedPassword = "password123"
        
        let interactor = AuthInteractor(authService: authService, firebaseManager: firebaseManager)
        let presenter = AuthPresenter(
            interactor: interactor,
            keychainService: keychainService,
            biometricService: biometricService
        )
        
        let expectation = self.expectation(description: "Biometric login flow completes")
        
        presenter.authSuccess = { isNew, user in
            if !isNew {
                self.sut.navigateToHome()
            }
            expectation.fulfill()
        }
        
        presenter.authenticateWithBiometrics()
        
        waitForExpectations(timeout: 1)
        
        XCTAssertTrue(biometricService.authenticateCalled)
        XCTAssertTrue(authService.loginCalled)
        XCTAssertTrue(sut.navigateToHomeCalled)
        XCTAssertEqual(presenter.email, "test@example.com")
        XCTAssertEqual(presenter.password, "password123")
    }
    
    func test_givenRegistrationSuccess_whenBiometricsEnabled_thenFlowIsComplete() {
        let testUser = User(id: "test-id", name: "New User", email: "new@example.com")
        authService.registerResult = .success(testUser)
        firebaseManager.saveUserResult = .success(())
        biometricService.canUseBiometricsResult = true
        biometricService.biometricType = .faceID
        
        let interactor = AuthInteractor(authService: authService, firebaseManager: firebaseManager)
        let presenter = AuthPresenter(
            interactor: interactor,
            keychainService: keychainService,
            biometricService: biometricService
        )
        
        let expectation = self.expectation(description: "Registration with biometrics flow completes")
        
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
        
        XCTAssertTrue(presenter.showBiometricPrompt)
        XCTAssertEqual(presenter.biometricType, "Face ID")
        
        // Simulate enabling biometrics
        presenter.enableBiometricAuthentication()
        
        XCTAssertTrue(keychainService.savedBiometricEnabled == true)
        XCTAssertFalse(presenter.showBiometricPrompt)
        XCTAssertNotNil(presenter.toast)
        if case .success(let message) = presenter.toast?.type {
            XCTAssertEqual(message, "Face ID enabled successfully")
        } else {
            XCTFail("Wrong toast type")
        }
    }
    
    func test_givenBiometricsNotAvailable_whenAuthenticating_thenFlowFails() {
        biometricService.canUseBiometricsResult = false
        
        let interactor = AuthInteractor(authService: authService, firebaseManager: firebaseManager)
        let presenter = AuthPresenter(
            interactor: interactor,
            keychainService: keychainService,
            biometricService: biometricService
        )
        
        presenter.authenticateWithBiometrics()
        
        XCTAssertNotNil(presenter.toast)
        if case .error(let error) = presenter.toast?.type {
            XCTAssertTrue(error is AppError)
            XCTAssertEqual(error.localizedDescription, AppError.customError("Biometric authentication not available").localizedDescription)
        } else {
            XCTFail("Wrong toast type")
        }
        XCTAssertFalse(authService.loginCalled)
        XCTAssertFalse(sut.navigateToHomeCalled)
    }
    
    func test_givenBiometricsNotEnrolled_whenAuthenticating_thenFlowFails() {
        biometricService.canUseBiometricsResult = true
        biometricService.authenticateResult = .failure(LAError(.biometryNotEnrolled))
        
        let interactor = AuthInteractor(authService: authService, firebaseManager: firebaseManager)
        let presenter = AuthPresenter(
            interactor: interactor,
            keychainService: keychainService,
            biometricService: biometricService
        )
        
        let expectation = self.expectation(description: "Biometric authentication failure")
        
        presenter.authenticateWithBiometrics()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1)
        
        XCTAssertNotNil(presenter.toast)
        if case .error(let error) = presenter.toast?.type {
            XCTAssertTrue(error is AppError)
            let expectedMessage = "Please set up \(presenter.biometricType) in your device settings"
            XCTAssertEqual(error.localizedDescription, AppError.customError(expectedMessage).localizedDescription)
        } else {
            XCTFail("Wrong toast type")
        }
        XCTAssertFalse(authService.loginCalled)
        XCTAssertFalse(sut.navigateToHomeCalled)
    }
}
