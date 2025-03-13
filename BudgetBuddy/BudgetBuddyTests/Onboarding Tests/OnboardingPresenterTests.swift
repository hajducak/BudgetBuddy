import XCTest
import Combine
@testable import BudgetBuddy

class OnboardingPresenterTests: XCTestCase {
    var mockInteractor: MockOnboardingInteractor!
    var mockRouter: MockOnboardingRouter!
    var sut: OnboardingPresenter!
    
    override func setUp() {
        super.setUp()
        mockInteractor = MockOnboardingInteractor()
        mockRouter = MockOnboardingRouter()
        sut = OnboardingPresenter(interactor: mockInteractor, router: mockRouter)
    }
    
    override func tearDown() {
        mockInteractor = nil
        mockRouter = nil
        sut = nil
        super.tearDown()
    }

    func test_toggleCategorySelection() {
        let category = Category(id: "1", name: "Test", type: .expense)
        sut.toggleCategorySelection(category)
        XCTAssertTrue(sut.selectedCategories.contains { $0.id == category.id })
        
        sut.toggleCategorySelection(category)
        XCTAssertFalse(sut.selectedCategories.contains { $0.id == category.id })
    }

    func test_whenCompleteOnboarding_thenSuccess() {
        let expectation = self.expectation(description: "Onboarding completes successfully")
        let testUser = User(id: "test-id", name: "Test User", email: "test@example.com")
        
        mockInteractor.user = testUser
        mockInteractor.saveUserDataResult = .success(())
        
        sut.balance = "100"
        sut.currency = "USD"
        sut.completeOnboarding()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertFalse(self.sut.onbaordingIsLoading)
            XCTAssertNil(self.sut.toast)
            XCTAssertTrue(self.mockRouter.didNavigateToApp)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1)
    }

    func test_givenError_whenCompleteOnboarding_thenFailure() {
        let expectation = self.expectation(description: "Onboarding fails with error")
        let testUser = User(id: "test-id", name: "Test User", email: "test@example.com")
        let testError = AppError.customError("Save error")
        
        mockInteractor.user = testUser
        mockInteractor.saveUserDataResult = .failure(testError)
        
        sut.balance = "100"
        sut.currency = "USD"
        sut.completeOnboarding()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertFalse(self.sut.onbaordingIsLoading)
            XCTAssertNotNil(self.sut.toast)
            XCTAssertEqual(self.sut.toast?.toastMessage, "⚠️ \(testError.errorMessage)")
            XCTAssertFalse(self.mockRouter.didNavigateToApp)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1)
    }
}
