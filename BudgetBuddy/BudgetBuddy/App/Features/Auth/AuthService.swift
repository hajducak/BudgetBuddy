import FirebaseAuth
import Foundation

protocol AuthServiceProtocol {
    func register(email: String, password: String, completion: @escaping (Result<User, AppError>) -> Void)
    func login(email: String, password: String, completion: @escaping (Result<User, AppError>) -> Void)
    func logout(completion: @escaping (Result<Void, AppError>) -> Void)
}

class AuthService: AuthServiceProtocol {
    func register(email: String, password: String, completion: @escaping (Result<User, AppError>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                completion(.failure(.registrationError(error)))
            } else if let authResult = authResult {
                let user = User(id: authResult.user.uid, name: authResult.user.displayName ?? "No Name", email: authResult.user.email ?? "")
                completion(.success(user))
            }
        }
    }

    func login(email: String, password: String, completion: @escaping (Result<User, AppError>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                completion(.failure(.loginError(error)))
            } else if let authResult = authResult {
                let user = User(id: authResult.user.uid, name: authResult.user.displayName ?? "No Name", email: authResult.user.email ?? "")
                completion(.success(user))
            }
        }
    }

    func logout(completion: @escaping (Result<Void, AppError>) -> Void) {
        do {
            try Auth.auth().signOut()
            completion(.success(()))
        } catch let error {
            completion(.failure(.logoutError(error)))
        }
    }
}
