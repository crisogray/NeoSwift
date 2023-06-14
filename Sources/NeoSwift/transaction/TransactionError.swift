
import Foundation

public enum TransactionError: LocalizedError {
    
    case scriptFormat(_ message: String)
    case signerConfiguration(_ message: String)
    case transactionConfiguration(_ message: String)
    
    public var errorDescription: String? {
        switch self {
        case .scriptFormat(let message), .signerConfiguration(let message), .transactionConfiguration(let message): return message
        }
    }
    
}
