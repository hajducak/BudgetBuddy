import LocalAuthentication

protocol BiometricServiceProtocol {
    func canUseBiometrics() -> Bool
    func getBiometricType() -> LABiometryType
    func authenticate(reason: String, completion: @escaping (Result<Void, Error>) -> Void)
}

class BiometricService: BiometricServiceProtocol {
    private let context: LAContext
    private var error: NSError?
    
    init(context: LAContext? = nil) {
        self.context = context ?? LAContext()
    }
    
    func canUseBiometrics() -> Bool {
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
    }
    
    func getBiometricType() -> LABiometryType {
        _ = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
        return context.biometryType
    }
    
    func authenticate(reason: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard canUseBiometrics() else {
            completion(.failure(LAError(.biometryNotAvailable)))
            return
        }
        
        context.evaluatePolicy(
            .deviceOwnerAuthenticationWithBiometrics,
            localizedReason: reason
        ) { success, error in
            DispatchQueue.main.async {
                if success {
                    completion(.success(()))
                } else if let error = error {
                    completion(.failure(error))
                }
            }
        }
    }
} 