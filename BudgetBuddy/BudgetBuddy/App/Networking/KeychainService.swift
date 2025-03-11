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
}
