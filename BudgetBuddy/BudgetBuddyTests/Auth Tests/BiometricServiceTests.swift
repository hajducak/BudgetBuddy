import XCTest
import LocalAuthentication
@testable import BudgetBuddy

class BiometricServiceTests: XCTestCase {
    var sut: BiometricService!
    var context: LAContext!
    
    override func setUp() {
        super.setUp()
        context = LAContext()
        sut = BiometricService(context: context)
    }
    
    override func tearDown() {
        sut = nil
        context = nil
        super.tearDown()
    }
    
    func test_whenCanUseBiometrics_thenPolicyIsEvaluated() {
        var error: NSError?
        let canEvaluate = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
        let result = sut.canUseBiometrics()
        
        XCTAssertEqual(result, canEvaluate)
    }
    
    func test_whenGetBiometricType_thenTypeIsReturned() {
        let type = sut.getBiometricType()
        XCTAssertEqual(type, context.biometryType)
    }
    
    func test_givenBiometricsNotAvailable_whenAuthenticate_thenFailure() {
        let expectation = self.expectation(description: "Authentication fails")
        context.invalidate()
        sut.authenticate(reason: "Test authentication") { result in
            if case .failure = result {
                expectation.fulfill()
            }
        }
        waitForExpectations(timeout: 1)
    }
}
