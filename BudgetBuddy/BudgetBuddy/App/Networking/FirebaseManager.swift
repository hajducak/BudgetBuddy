import FirebaseFirestore
import FirebaseAuth

protocol FirebaseManagerProtocol {
    func saveUserToFirestore(user: User, completion: @escaping (Result<Void, Error>) -> Void)
}

class FirebaseManager: FirebaseManagerProtocol {
    private let firestore = Firestore.firestore()

    func saveUserToFirestore(user: User, completion: @escaping (Result<Void, Error>) -> Void) {
        let userData = [
            "email": user.email,
            "uid": user.id
        ]
        
        firestore.collection("users").document(user.id).setData(userData) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
}
