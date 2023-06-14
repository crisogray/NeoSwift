
import Foundation

public enum SignError: LocalizedError {
    
    case headerOutOfRange(_ byte: Byte)
    case recoverFailed
    
    public var errorDescription: String? {
        switch self {
        case .headerOutOfRange(let header): return "Header byte out of range: \(header)"
        case .recoverFailed: return "Could not recover public key from signature"
        }
    }
    
}
