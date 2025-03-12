import FirebaseFirestore
import FirebaseAuth

protocol FirebaseManagerProtocol {
    func saveUserToFirestore(user: User, completion: @escaping (Result<Void, AppError>) -> Void)
}

class FirebaseManager: FirebaseManagerProtocol {
    private let firestore = Firestore.firestore()

    func saveUserToFirestore(user: User, completion: @escaping (Result<Void, AppError>) -> Void) {
        do {
            let userData = try Firestore.Encoder().encode(user)
            
            firestore.collection("users").document(user.id).setData(userData) { error in
                if let error = error {
                    completion(.failure(.saveToDatabase(error)))
                } else {
                    completion(.success(()))
                }
            }
        } catch {
            completion(.failure(.saveToDatabase(error)))
        }
    }
}
