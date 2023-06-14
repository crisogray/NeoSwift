
import Foundation

public enum NeoSwiftError: LocalizedError {
    
    case illegalArgument(_ message: String? = nil)
    case deserialization(_ message: String? = nil)
    case illegalState(_ message: String? = nil)
    case runtime(_ message: String)
    case unsupportedOperation(_ message: String)

    public var errorDescription: String? {
        switch self {
        case .illegalArgument(let message), .illegalState(let message), .deserialization(let message): return message
        case .runtime(let message), .unsupportedOperation(let message): return message
        }
    }
    
}
