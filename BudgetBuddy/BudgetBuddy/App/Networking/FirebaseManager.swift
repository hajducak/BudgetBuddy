import FirebaseFirestore
import FirebaseAuth

protocol FirebaseManagerProtocol {
    // TODO: use combine anyPublisher
    func saveUserToFirestore(user: User, completion: @escaping (Result<Void, Error>) -> Void)
}

class FirebaseManager: FirebaseManagerProtocol {
    private let firestore = Firestore.firestore()

    func saveUserToFirestore(user: User, completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            let userData = try Firestore.Encoder().encode(user)
            
            firestore.collection("users").document(user.id).setData(userData) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        } catch {
            completion(.failure(error))
        }
    }
}
