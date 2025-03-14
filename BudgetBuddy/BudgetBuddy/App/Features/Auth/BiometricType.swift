import LocalAuthentication

enum BiometricType {
    case none
    case faceID
    case touchID
    
    init(from biometryType: LABiometryType) {
        switch biometryType {
        case .faceID:
            self = .faceID
        case .touchID:
            self = .touchID
        default:
            self = .none
        }
    }
    
    var displayName: String {
        switch self {
        case .none:
            return "None"
        case .faceID:
            return "Face ID"
        case .touchID:
            return "Touch ID"
        }
    }
    
    var systemImageName: String {
        switch self {
        case .faceID:
            return "faceid"
        case .touchID:
            return "touchid"
        case .none:
            return ""
        }
    }
} 