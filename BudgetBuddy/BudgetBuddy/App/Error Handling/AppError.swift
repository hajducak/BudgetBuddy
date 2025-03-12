import Foundation

enum AppError: Error, LocalizedError {
    case loginError(Error)
    case logoutError(Error)
    case registrationError(Error)
    case saveToDatabase(Error)
    case unknownError
    case invalidInput
    case customError(String)

    var errorMessage: String {
        switch self {
        case .loginError(let error):
            return "Login failed: \(error.localizedDescription)"
        case .logoutError(let error):
            return "Logout failed: \(error.localizedDescription)"
        case .registrationError(let error):
            return "Registration failed: \(error.localizedDescription)"
        case .saveToDatabase(let error):
            return "Saveing to database failed: \(error.localizedDescription)"
        case .invalidInput:
            return "Please fill in all fields correctly."
        case .unknownError:
            return "An unknown error occurred. Please try again."
        case .customError(let message):
            return message
        }
    }
}
