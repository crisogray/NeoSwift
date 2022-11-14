
import Foundation

public struct ContractParameter: Codable, Hashable {
        
    public var name: String?
    public var type: ContractParamterType
    public var value: AnyHashable?
    
    
    
    
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        if let name = name { try container.encode(name, forKey: .name) }
        try container.encode(type.rawValue, forKey: .type)
        switch type {
        case .any: try container.encode("", forKey: .value)
        case .boolean: try container.encode(value as! Bool, forKey: .value)
        case .integer: try container.encode(value as! Int, forKey: .value)
        case .byteArray, .signature: try container.encode((value as! Bytes).base64Encoded, forKey: .value)
        case .string, .interopInterface: try container.encode(value as! String, forKey: .value)
        case .hash160: try container.encode((value as! Hash160).string, forKey: .value)
        case .hash256: try container.encode((value as! Hash256).string, forKey: .value)
        case .publicKey: try container.encode((value as! Bytes).toHexString().cleanedHexPrefix, forKey: .value)
        case .array: try container.encode(value as! [ContractParameter], forKey: .value)
        case .map:
            let map = value as! [ContractParameter : ContractParameter]
            try container.encode(map.map { ["key" : $0, "value": $1] }, forKey: .value)
        default: throw "Parameter type '\(type.rawValue)' not supported."
        }
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try? values.decode(String.self, forKey: .name)
        guard let type = try ContractParamterType(rawValue: values.decode(String.self, forKey: .type)) else {
            throw "Invalid Contract Parameter Type"
        }
        self.type = type
        switch type {
        case .any: value = nil
        case .boolean:
            if let s = try? values.decode(String.self, forKey: .value) { value = Bool(s) }
            else { value = try values.decode(Bool.self, forKey: .value) }
        case .integer:
            if let s = try? values.decode(String.self, forKey: .value) { value = Int(s) }
            else { value = try values.decode(Int.self, forKey: .value) }
        case .byteArray, .signature: value = try values.decode(String.self, forKey: .value).base64Decoded
        case .string, .interopInterface: value = try values.decode(String.self, forKey: .value)
        case .hash160: value = try Hash160(values.decode(String.self, forKey: .value))
        case .hash256: value = try Hash256(values.decode(String.self, forKey: .value))
        case .publicKey: value = try values.decode(String.self, forKey: .value).bytesFromHex
        case .array: value = try values.decode([ContractParameter].self, forKey: .value)
        case .map:
            var map: [ContractParameter : ContractParameter] = [:]
            try values.decode([[String : ContractParameter]].self, forKey: .value)
                .forEach { map[$0["key"]!] = $0["value"]! }
            value = map
        default: throw "Parameter type '\(type.rawValue)' not supported."
        }
    }
    
    private enum CodingKeys: String, CodingKey {
        case name, type, value
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(type)
        hasher.combine(value)
    }
    
    public static func == (lhs: ContractParameter, rhs: ContractParameter) -> Bool {
        return lhs.name == rhs.name && lhs.type == rhs.type && lhs.value == rhs.value
    }
    
}
