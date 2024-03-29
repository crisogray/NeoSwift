
import BigInt
import Foundation

/// Contract parameters represent an input parameter for contract invocations.
public struct ContractParameter: Codable, Hashable {
        
    public let name: String?
    public let type: ContractParamterType
    public let value: AnyHashable?
    
    private init(name: String?, type: ContractParamterType, value: AnyHashable?) {
        self.name = name
        self.type = type
        self.value = value
    }
    
    public init(name: String?, type: ContractParamterType) {
        self.init(name: name, type: type, value: nil)
    }
    
    public init(type: ContractParamterType) {
        self.init(name: nil, type: type, value: nil)
    }
    
    public init(type: ContractParamterType, value: AnyHashable?) {
        self.init(name: nil, type: type, value: value)
    }
    
    /// Creates a contract parameter from the given value.
    /// - Parameter value: Any object value
    /// - Returns: The contract parameter
    public static func any(_ value: AnyHashable?) -> ContractParameter {
        return ContractParameter(type: .any, value: value)
    }
    
    /// Creates a string parameter from the given value.
    /// - Parameter value: The string value
    /// - Returns: The contract parameter
    public static func string(_ value: String) -> ContractParameter {
        return ContractParameter(type: .string, value: value)
    }
    
    /// Creates a byte array parameter from the given value.
    ///
    /// Make sure that the array is in the right byte order, i.e., endianness.
    /// - Parameter value: The parameter value
    /// - Returns: The contract parameter
    public static func byteArray(_ value: Bytes) -> ContractParameter {
        return ContractParameter(type: .byteArray, value: value)
    }
    
    /// Creates a byte array parameter from the given hex string.
    /// - Parameter value: The hexadecimal string
    /// - Returns:The contract parameter
    public static func byteArray(_ value: String) throws -> ContractParameter {
        guard value.isValidHex else {
            throw NeoSwiftError.illegalArgument("Argument is not a valid hex number.")
        }
        return ContractParameter(type: .byteArray, value: value.bytesFromHex)
    }
    
    /// Create a byte array parameter from a string by converting the string to bytes using the UTF-8 character set.
    /// - Parameter value: The paramter value
    /// - Returns:The contract parameter
    public static func byteArrayFromString(_ value: String) -> ContractParameter {
        return ContractParameter(type: .byteArray, value: Bytes(value.utf8))
    }
    
    /// Creates a signature parameter from the given signature.
    /// - Parameter value: A signature
    /// - Returns:The contract parameter
    public static func signature(_ value: Bytes) throws -> ContractParameter {
        guard value.count == NeoConstants.SIGNATURE_SIZE else {
            throw NeoSwiftError.illegalArgument("Signature is expected to have a length of \(NeoConstants.SIGNATURE_SIZE) bytes, but had \(value.count).")
        }
        return ContractParameter(type: .signature, value: value)
    }
    
    /// Creates a signature parameter from the provided ``Sign/SignatureData``.
    /// - Parameter value: The signature data
    /// - Returns: The contract parameter
    public static func signature(_ value: Sign.SignatureData) throws -> ContractParameter {
        return try signature(value.concatenated)
    }
    
    /// Creates a signature parameter from the given signature hexadecimal string.
    /// - Parameter value: A signature as hexadecimal string
    /// - Returns: The contract parameter
    public static func signature(_ value: String) throws -> ContractParameter {
        guard value.isValidHex else {
            throw NeoSwiftError.illegalArgument("Argument is not a valid hex number.")
        }
        return try signature(value.bytesFromHex)
    }
    
    /// Creates an boolean parameter from the given boolean.
    /// - Parameter value: A boolean value
    /// - Returns: The contract parameter
    public static func bool(_ value: Bool) -> ContractParameter {
        return ContractParameter(type: .boolean, value: value)
    }
    
    /// Creates an integer parameter from the given integer.
    /// - Parameter value: An integer value
    /// - Returns: The contract parameter
    public static func integer(_ value: Int) -> ContractParameter {
        return ContractParameter(type: .integer, value: value)
    }
    
    /// Creates an integer parameter from the given byte value.
    /// - Parameter value: A byte value
    /// - Returns: The contract parameter
    public static func integer(_ value: Byte) -> ContractParameter {
        return integer(Int(value))
    }
    
    /// Creates an integer parameter from the given big integer.
    /// - Parameter value: A big integer value
    /// - Returns: The contract parameter
    public static func integer(_ value: BInt) -> ContractParameter {
        return ContractParameter(type: .integer, value: value)
    }
    
    /// Creates a hash160 parameter from the given account.
    /// - Parameter account: An account
    /// - Returns: The contract parameter
    public static func hash160(_ account: Account) throws -> ContractParameter {
        return try ContractParameter(type: .hash160, value: account.getScriptHash())
    }
    
    /// Creates a hash160 parameter from the given script hash.
    /// - Parameter value: A script hash
    /// - Returns: The contract parameter
    public static func hash160(_ value: Hash160) -> ContractParameter {
        return ContractParameter(type: .hash160, value: value)
    }
    
    /// Creates a hash256 parameter from the given hash.
    /// - Parameter value: A 456-bit hash
    /// - Returns: The contract parameter
    public static func hash256(_ value: Hash256) -> ContractParameter {
        return ContractParameter(type: .hash256, value: value)
    }
    
    /// Creates a hash256 parameter from the given bytes.
    /// - Parameter value: A 256-bit hash in big-endian order
    /// - Returns: The contract parameter
    public static func hash256(_ value: Bytes) throws -> ContractParameter {
        return try ContractParameter(type: .hash256, value: Hash256(value))
    }
    
    /// Creates a hash256 parameter from the given hex string.
    /// - Parameter value: A 256-bit hash in hexadecimal and big-endian order
    /// - Returns: The contract parameter
    public static func hash256(_ value: String) throws -> ContractParameter {
        return try ContractParameter(type: .hash256, value: Hash256(value))
    }
    
    /// Creates a public key parameter from the given public key.
    ///
    /// The public key must be encoded in compressed format as described in section 2.3.3 of [SEC1](http://www.secg.org/sec1-v2.pdf)
    /// - Parameter value: The public key to use in the parameter
    /// - Returns: The contract parameter
    public static func publicKey(_ value: Bytes) throws -> ContractParameter {
        guard value.count == NeoConstants.PUBLIC_KEY_SIZE_COMPRESSED else {
            throw NeoSwiftError.illegalArgument("Public key argument must be \(NeoConstants.PUBLIC_KEY_SIZE_COMPRESSED) bytes but was \(value.count) bytes.")
        }
        return ContractParameter(type: .publicKey, value: value)
    }
    
    /// Creates a public key parameter from the given public key.
    ///
    /// The public key must be encoded in compressed format as described in section 2.3.3 of [SEC1](http://www.secg.org/sec1-v2.pdf)
    /// - Parameter value: The public key in hexadecimal representation
    /// - Returns: The contract parameter
    public static func publicKey(_ value: String) throws -> ContractParameter {
        return try publicKey(value.bytesFromHex)
    }
    
    /// Creates a public key parameter from the given public key.
    /// - Parameter value: The public key
    /// - Returns: The contract parameter
    public static func publicKey(_ value: ECPublicKey) throws -> ContractParameter {
        return try publicKey(value.getEncoded(compressed: true))
    }
    
    /// Creates an array parameter from the given values.
    ///
    /// The method will try to map the given objects to the correct ``ContractParameterType``s.
    /// - Parameter values: The array entries
    /// - Returns: The contract parameter
    public static func array(_ values: [AnyHashable]) throws -> ContractParameter {
        return try ContractParameter(type: .array, value: values.map(mapToContractParameter(_:)))
    }
    
    /// Creates a map contract parameter.
    /// - Parameter values: The map entries
    /// - Returns: The contract parameter
    public static func map(_ values: [AnyHashable: AnyHashable]) throws -> ContractParameter {
        guard !values.isEmpty else {
            throw NeoSwiftError.illegalArgument("At least one map entry is required to create a map contract parameter.")
        }
        var map: [ContractParameter: ContractParameter] = [:]
        try values.forEach { k, v in
            guard let key = try? mapToContractParameter(k),
                  let value = try? mapToContractParameter(v),
                    key.type != .array && key.type != .map else {
                throw NeoSwiftError.illegalArgument("The provided map contains an invalid key. The keys cannot be of type array or map.")
            }
            map[key] = value
        }
        return ContractParameter(type: .map, value: map)
    }
    
    /// Maps the given object to a contract parameter of the appropriate type.
    /// - Parameter value: The object to map
    /// - Returns: The contract parameter
    public static func mapToContractParameter(_ value: Any?) throws -> ContractParameter {
        switch value {
        case nil: return any(nil)
        case is ContractParameter: return value as! ContractParameter
        case is Bool: return bool(value as! Bool)
        case is Int: return integer(value as! Int)
        case is BInt: return integer(value as! BInt)
        case is Byte: return integer(value as! Byte)
        case is BInt: return integer(value as! BInt)
        case is Bytes: return byteArray(value as! Bytes)
        case is String: return string(value as! String)
        case is Hash160: return hash160(value as! Hash160)
        case is Account: return try hash160(value as! Account)
        case is Hash256: return hash256(value as! Hash256)
        case is ECPublicKey: return try publicKey(value as! ECPublicKey)
        case is Sign.SignatureData: return try signature(value as! Sign.SignatureData)
        case is [AnyHashable]: return try array(value as! [AnyHashable])
        case is [AnyHashable: AnyHashable]: return try map(value as! [AnyHashable: AnyHashable])
        default: throw NeoSwiftError.illegalArgument("The provided object could not be casted into a supported contract parameter type.")
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        if let name = name { try container.encode(name, forKey: .name) }
        try container.encode(type.jsonValue, forKey: .type)
        if let value = value {
            switch type {
            case .any: try container.encode("", forKey: .value)
            case .boolean: try container.encode(value as! Bool, forKey: .value)
            case .integer: try container.encode(value as! Int, forKey: .value)
            case .byteArray, .signature: try container.encode((value as! Bytes).base64Encoded, forKey: .value)
            case .string, .interopInterface: try container.encode(value as! String, forKey: .value)
            case .hash160: try container.encode((value as! Hash160).string, forKey: .value)
            case .hash256: try container.encode((value as! Hash256).string, forKey: .value)
            case .publicKey: try container.encode((value as! Bytes).noPrefixHex, forKey: .value)
            case .array: try container.encode(value as! [ContractParameter], forKey: .value)
            case .map:
                let map = value as! [ContractParameter : ContractParameter]
                try container.encode(map.map { ["key" : $0, "value": $1] }, forKey: .value)
            default: throw NeoSwiftError.unsupportedOperation("Parameter type '\(type.jsonValue)' not supported.")
            }
        }
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try? values.decode(String.self, forKey: .name)
        guard let type = try ContractParamterType.fromJsonValue(values.decode(String.self, forKey: .type)) else {
            throw NeoSwiftError.illegalArgument()
        }
        self.type = type
        if !values.contains(.value) {
            self.value = nil
            return
        }
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
        default: throw NeoSwiftError.unsupportedOperation("Parameter type '\(type.jsonValue)' not supported.")
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
