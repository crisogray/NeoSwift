
import Foundation

public enum WalletError: LocalizedError {
    
    case accountState(_ message: String)
    
    public var errorDescription: String? {
        switch self {
        case .accountState(let message): return message
        }
    }
}
