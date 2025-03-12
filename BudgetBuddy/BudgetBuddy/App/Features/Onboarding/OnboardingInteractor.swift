import Foundation

protocol OnboardingInteractorProtocol {
    func saveUserData(user: User, completion: @escaping (Result<Void, AppError>) -> Void)
    var user: User? { get }
}

class OnboardingInteractor: OnboardingInteractorProtocol {
    private let firebaseManager: FirebaseManagerProtocol
    var user: User?
    
    init(firebaseManager: FirebaseManagerProtocol, user: User?) {
        self.user = user
        self.firebaseManager = firebaseManager
    }
    
    func saveUserData(user: User, completion: @escaping (Result<Void, AppError>) -> Void) {
        firebaseManager.saveUserToFirestore(user: user, completion: completion)
    }
}
