import Foundation

enum AppError: Error, LocalizedError {
    case loginError(Error)
    case registrationError(Error)
    case unknownError
    case invalidInput
    case customError(String)

    var errorMessage: String {
        switch self {
        case .loginError(let error):
            return "Login failed: \(error.localizedDescription)"
        case .registrationError(let error):
            return "Registration failed: \(error.localizedDescription)"
        case .invalidInput:
            return "Please fill in all fields correctly."
        case .unknownError:
            return "An unknown error occurred. Please try again."
        case .customError(let message):
            return message
        }
    }
}
