protocol AuthInteractorProtocol {
    func register(name: String, email: String, password: String, completion: @escaping (Result<User, AppError>) -> Void)
    func login(email: String, password: String, completion: @escaping (Result<User, AppError>) -> Void)
}

class AuthInteractor: AuthInteractorProtocol {
    private let authService: AuthServiceProtocol
    private let firebaseManager: FirebaseManagerProtocol

    init(authService: AuthServiceProtocol, firebaseManager: FirebaseManagerProtocol) {
        self.authService = authService
        self.firebaseManager = firebaseManager
    }

    func register(name: String, email: String, password: String, completion: @escaping (Result<User, AppError>) -> Void) {
        authService.register(email: email, password: password) { [weak self] result in
            switch result {
            case .success(let authResult):
                let user = User(id: authResult.id, name: name, email: email)
                self?.firebaseManager.saveUserToFirestore(user: user) { firebaseResult in
                    switch firebaseResult {
                    case .success:
                        completion(.success(user))
                    case .failure(let error):
                        completion(.failure(.saveToDatabase(error)))
                    }
                }
            case .failure(let error):
                completion(.failure(.registrationError(error)))
            }
        }
    }

    func login(email: String, password: String, completion: @escaping (Result<User, AppError>) -> Void) {
        authService.login(email: email, password: password, completion: completion)
    }
}
