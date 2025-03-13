import XCTest
@testable import BudgetBuddy

class OnboardingRouterTests: XCTestCase {
    var mockCoordinator: MockAppCoordinator!
    var sut: OnboardingRouter!
    
    override func setUp() {
        super.setUp()
        mockCoordinator = MockAppCoordinator()
        sut = OnboardingRouter(coordinator: mockCoordinator)
    }
    
    override func tearDown() {
        mockCoordinator = nil
        sut = nil
        super.tearDown()
    }
    
    func test_whenGoToApp_thenCordinatorIsSetCorrectly() {
        sut.goToApp()
        
        XCTAssertTrue(mockCoordinator.isAuthenticated)
        XCTAssertFalse(mockCoordinator.showOnboarding)
    }
}
