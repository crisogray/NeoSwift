
import Foundation

public enum WitnessScope: ByteEnum {
    
    /// A witness with this scope is only used for transactions and is disabled in contracts.
    case none
    
    /// This scope limits the use of a witness to the level of the contract called in the transaction. I.e. it only allows the invoked contract to use the witness.
    case calledByEntry
    
    /// This scope allows the specification of additional contracts in which the witness can be used.
    case customContracts
    
    /// This scope allows the specification of contract groups in which the witness can be used.
    case customGroups
    
    /// Indicates that the current context must satisfy the specified rules.
    case witnessRules
    
    /// The global scope allows to use a witness in all contexts. It cannot be combined with other scopes.
    case global
    
    public var jsonValue: String {
        switch self {
        case .none: return "None"
        case .calledByEntry: return "CalledByEntry"
        case .customContracts: return "CustomContracts"
        case .customGroups: return "CustomGroups"
        case .witnessRules: return "WitnessRules"
        case .global: return "Global"
        }
    }
    
    public var byte: Byte {
        switch self {
        case .none: return 0x00
        case .calledByEntry: return 0x01
        case .customContracts: return 0x10
        case .customGroups: return 0x20
        case .witnessRules: return 0x40
        case .global: return 0x80
        }
    }
    
    /// Encodes the given scopes in one byte.
    /// - Parameter scopes: The scopes to encode
    /// - Returns: The scope encoding byte
    public static func combineScopes(_ scopes: [WitnessScope]) -> Byte {
        return scopes.map(\.byte).reduce(0, |)
    }
    
    /// Extracts the scopes encoded in the given byte.
    /// - Parameter combinedScopes: The byte representation of the scopes
    /// - Returns: The list of scopes encoded by the given byte
    public static func extractCombinedScopes(_ combinedScopes: Byte) -> [WitnessScope] {
        if combinedScopes == WitnessScope.none.byte { return [.none] }
        return allCases.filter{ $0 != .none && (combinedScopes & $0.byte) != 0 }
    }
    
}

@propertyWrapper
struct WitnessScopesFromString: Codable, Hashable {
    
    var wrappedValue: [WitnessScope]
    
    public init(wrappedValue: [WitnessScope]) {
        self.wrappedValue = wrappedValue
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)
        wrappedValue = string.replacingOccurrences(of: " ", with: "")
            .components(separatedBy: ",")
            .compactMap(WitnessScope.fromJsonValue)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(wrappedValue.map(\.jsonValue).joined(separator: ","))
    }
    
}

