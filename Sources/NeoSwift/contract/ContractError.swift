
import Foundation

public enum ContractError: LocalizedError {
    
    case invalidNeoName(_ name: String)
    case invalidNeoNameServiceRoot(_ root: String)
    case unexpectedReturnType(_ type: String, _ expected: [String]? = nil)
    case unresolvableDomainName(_ name: String)
    case emptyInvocationResultStack

    public var errorDescription: String? {
        switch self {
        case .invalidNeoName(let name): return "'\(name)' is not a valid NNS name."
        case .invalidNeoNameServiceRoot(let root): return "'\(root)' is not a valid NNS root."
        case .unexpectedReturnType(let type, let expected):
            if let expected = expected {
                return "Got stack item of type \(type) but expected \(expected.joined(separator: ", "))."
            } else { return type }
        case .unresolvableDomainName(let name): return "The provided domain name '\(name)' could not be resolved."
        case .emptyInvocationResultStack: return "InvocationResult has empty stack."
        }
    }
    
}
