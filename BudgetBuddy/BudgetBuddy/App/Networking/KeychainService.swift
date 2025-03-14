import KeychainAccess

class KeychainService {
    private let keychain = Keychain(service: "com.hajducak.auth")
    
    func saveEmail(_ email: String) {
        try? keychain.set(email, key: "email")
    }
    
    func getEmail() -> String? {
        return try? keychain.get("email")
    }
    
    func savePassword(_ password: String) {
        try? keychain.set(password, key: "password")
    }
    
    func getPassword() -> String? {
        return try? keychain.get("password")
    }
    
    func setBiometricEnabled(_ enabled: Bool) {
        try? keychain.set(String(enabled), key: "biometric_enabled")
    }
    
    func isBiometricEnabled() -> Bool {
        guard let value = try? keychain.get("biometric_enabled") else { return false }
        return value == "true"
    }
    
    func clearCredentials() {
        try? keychain.remove("email")
        try? keychain.remove("password")
    }
}
