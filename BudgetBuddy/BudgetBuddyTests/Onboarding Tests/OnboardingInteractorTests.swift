import XCTest
@testable import BudgetBuddy

class OnboardingInteractorTests: XCTestCase {
    var mockFirebaseManager: MockFirebaseManager!
    var sut: OnboardingInteractor!

    override func setUp() {
        super.setUp()
        mockFirebaseManager = MockFirebaseManager()
        sut = OnboardingInteractor(firebaseManager: mockFirebaseManager, user: nil)
    }

    override func tearDown() {
        mockFirebaseManager = nil
        sut = nil
        super.tearDown()
    }

    func test_whenSaveUserData_thenSuccess() {
        let expectation = self.expectation(description: "User data saved successfully")
        let testUser = User(id: "test-id", name: "Test User", email: "test@example.com")

        mockFirebaseManager.saveUserResult = .success(())

        sut.saveUserData(user: testUser) { result in
            switch result {
            case .success:
                XCTAssertTrue(self.mockFirebaseManager.saveUserCalled, "saveUserToFirestore should be called")
                expectation.fulfill()
            case .failure:
                XCTFail("Expected success, got failure")
            }
        }

        waitForExpectations(timeout: 1)
    }

    func test_whenSaveUserData_thenFailure() {
        let expectation = self.expectation(description: "User data save failed")
        let testUser = User(id: "test-id", name: "Test User", email: "test@example.com")
        let testError = AppError.customError("Firestore error")

        mockFirebaseManager.saveUserResult = .failure(testError)

        sut.saveUserData(user: testUser) { result in
            switch result {
            case .success:
                XCTFail("Expected failure, got success")
            case .failure(let error):
                XCTAssertTrue(self.mockFirebaseManager.saveUserCalled, "saveUserToFirestore should be called")
                XCTAssertEqual(error.localizedDescription, testError.localizedDescription)
                expectation.fulfill()
            }
        }

        waitForExpectations(timeout: 1)
    }
}
