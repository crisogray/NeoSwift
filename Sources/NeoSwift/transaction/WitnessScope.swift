
import Foundation

public enum WitnessScope: ByteEnum {
    
    case none, calledByEntry, customContracts, customGroups, witnessRules, global
    
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
    
    public static func combineScopes(_ scopes: [WitnessScope]) -> Byte {
        return scopes.map(\.byte).reduce(0, |)
    }
    
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

