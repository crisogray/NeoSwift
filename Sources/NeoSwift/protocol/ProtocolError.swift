
import Foundation

public enum ProtocolError: LocalizedError {
    
    case rpcResponseError(_ error: String)
    case invocationFaultSate(_ error: String)
    case clientConnection(_ message: String)
    
    public var errorDescription: String? {
        switch self {
        case .rpcResponseError(let error): return "The Neo node responded with an error: \(error)"
        case .invocationFaultSate(let error): return "The invocation resulted in a FAULT VM state. The VM exited due to the following exception: \(error)"
        case .clientConnection(let message): return message
        }
    }
}
