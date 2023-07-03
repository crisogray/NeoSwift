
import Foundation

public enum ProtocolError: LocalizedError {
    
    case rpcResponseError(_ error: String)
    case invocationFaultSate(_ error: String)
    case clientConnection(_ message: String)
    case stackItemCastError(_ item: StackItem, _ target: String)
    
    public var errorDescription: String? {
        switch self {
        case .rpcResponseError(let error): return "The Neo node responded with an error: \(error)"
        case .invocationFaultSate(let error): return "The invocation resulted in a FAULT VM state. The VM exited due to the following exception: \(error)"
        case .clientConnection(let message): return message
        case .stackItemCastError(let item, let target): return "Cannot cast stack item \(item.jsonValue) to a \(target)."
        }
    }
}
