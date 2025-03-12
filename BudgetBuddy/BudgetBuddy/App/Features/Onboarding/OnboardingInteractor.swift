import Foundation

protocol OnboardingInteractorProtocol {
    // TODO: use combine anyPublisher
    func saveUserData(user: User, completion: @escaping (Result<Void, Error>) -> Void)
    var user: User? { get }
}

class OnboardingInteractor: OnboardingInteractorProtocol {
    private let firebaseManager: FirebaseManagerProtocol
    var user: User?
    
    init(firebaseManager: FirebaseManagerProtocol, user: User?) {
        self.user = user
        self.firebaseManager = firebaseManager
    }
    
    func saveUserData(user: User, completion: @escaping (Result<Void, Error>) -> Void) {
        firebaseManager.saveUserToFirestore(user: user, completion: completion)
    }
}
