
import BigInt
import Foundation

public struct ContractParameter: Codable, Hashable {
        
    public let name: String?
    public let type: ContractParamterType
    public let value: AnyHashable?
    
    private init(name: String?, type: ContractParamterType, value: AnyHashable?) {
        self.name = name
        self.type = type
        self.value = value
    }
    
    init(name: String?, type: ContractParamterType) {
        self.init(name: name, type: type, value: nil)
    }
    
    init(type: ContractParamterType) {
        self.init(name: nil, type: type, value: nil)
    }
    
    init(type: ContractParamterType, value: AnyHashable?) {
        self.init(name: nil, type: type, value: value)
    }
 
    public static func any(_ value: AnyHashable?) -> ContractParameter {
        return ContractParameter(type: .any, value: value)
    }
    
    public static func string(_ value: String) -> ContractParameter {
        return ContractParameter(type: .string, value: value)
    }
    
    public static func byteArray(_ value: Bytes) -> ContractParameter {
        return ContractParameter(type: .byteArray, value: value)
    }
    
    public static func byteArray(_ value: String) throws -> ContractParameter {
        guard value.isValidHex else {
            throw "Argument is not a valid hex number."
        }
        return ContractParameter(type: .byteArray, value: value.bytesFromHex)
    }
    
    public static func byteArrayFromString(_ value: String) -> ContractParameter {
        return ContractParameter(type: .byteArray, value: Bytes(value.utf8))
    }
    
    public static func signature(_ value: Bytes) throws -> ContractParameter {
        guard value.count == NeoConstants.SIGNATURE_SIZE else {
            throw "Signature is expected to have a length of \(NeoConstants.SIGNATURE_SIZE) bytes, but had \(value.count)."
        }
        return ContractParameter(type: .signature, value: value)
    }
    
    public static func signature(_ value: Sign.SignatureData) throws -> ContractParameter {
        return try signature(value.concatenated)
    }
    
    public static func signature(_ value: String) throws -> ContractParameter {
        guard value.isValidHex else {
            throw "Argument is not a valid hex number."
        }
        return try signature(value.bytesFromHex)
    }
    
    public static func bool(_ value: Bool) -> ContractParameter {
        return ContractParameter(type: .boolean, value: value)
    }
    
    public static func integer(_ value: Int) -> ContractParameter {
        return ContractParameter(type: .integer, value: value)
    }
    
    public static func integer(_ value: Byte) -> ContractParameter {
        return integer(Int(value))
    }
    
    public static func integer(_ value: BInt) -> ContractParameter {
        return ContractParameter(type: .integer, value: value.asInt())
    }
    
    public static func hash160(_ value: Hash160) -> ContractParameter {
        return ContractParameter(type: .hash160, value: value)
    }
    
    // TODO: Hash160 from Account
    
    public static func hash256(_ value: Hash256) -> ContractParameter {
        return ContractParameter(type: .hash256, value: value)
    }
    
    public static func hash256(_ value: Bytes) throws -> ContractParameter {
        return try ContractParameter(type: .hash256, value: Hash256(value))
    }
    
    public static func hash256(_ value: String) throws -> ContractParameter {
        return try ContractParameter(type: .hash256, value: Hash256(value))
    }
    
    public static func publicKey(_ value: Bytes) throws -> ContractParameter {
        guard value.count == NeoConstants.PUBLIC_KEY_SIZE_COMPRESSED else {
            throw "Public key argument must be \(NeoConstants.PUBLIC_KEY_SIZE_COMPRESSED) bytes but was \(value.count) bytes."
        }
        return ContractParameter(type: .publicKey, value: value)
    }
    
    public static func publicKey(_ value: String) throws -> ContractParameter {
        return try publicKey(value.bytesFromHex)
    }
    
    public static func publicKey(_ value: ECPublicKey) throws -> ContractParameter {
        return try publicKey(value.getEncoded(compressed: true))
    }
    
    public static func array(_ values: [AnyHashable]) throws -> ContractParameter {
        return try ContractParameter(type: .array, value: values.map(mapToContractParameter(_:)))
    }
    
    public static func map(_ values: [AnyHashable: AnyHashable]) throws -> ContractParameter {
        guard !values.isEmpty else {
            throw "At least one map entry is required to create a map contract parameter."
        }
        var map: [ContractParameter: ContractParameter] = [:]
        try values.forEach { k, v in
            guard let key = try? mapToContractParameter(k),
                  let value = try? mapToContractParameter(v),
                    key.type != .array && key.type != .map else {
                throw "The provided map contains an invalid key. The keys cannot be of type array or map."
            }
            map[key] = value
        }
        return ContractParameter(type: .map, value: map)
    }
    
    public static func mapToContractParameter(_ value: AnyHashable) throws -> ContractParameter {
        switch value {
        case nil: return any(nil)
        case is ContractParameter: return value as! ContractParameter
        case is Bool: return bool(value as! Bool)
        case is Int: return integer(value as! Int)
        case is Byte: return integer(value as! Byte)
        case is BInt: return integer(value as! BInt)
        case is Bytes: return byteArray(value as! Bytes)
        case is String: return string(value as! String)
        case is Hash160: return hash160(value as! Hash160)
        case is Hash256: return hash256(value as! Hash256)
            // TODO: ACCOUNT
        case is ECPublicKey: return try publicKey(value as! ECPublicKey)
        case is Sign.SignatureData: return try signature(value as! Sign.SignatureData)
        case is [AnyHashable]:
            print("THING")
            print(value)
            return try array(value as! [AnyHashable])
        default: throw "The provided object could not be casted into a supported contract parameter type."
        }
    }
    
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
