
import Foundation

public enum NEP2Error: LocalizedError {
    
    case invalidPassphrase(_ message: String), invalidFormat(_ message: String)
    
    public var errorDescription: String? {
        switch self {
        case .invalidPassphrase(let message), .invalidFormat(let message): return message
        }
    }
    
}
