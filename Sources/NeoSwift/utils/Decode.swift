import BigInt
import Foundation

public protocol StringDecodable: Codable {
    init(string: String) throws
    var string: String { get }
}

extension StringDecodable {
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)
        try self.init(string: string)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(string)
    }
    
}

public class SafeDecode<T: StringDecodable>: Codable {
    
    let value: T
    
    init(_ value: T) {
        self.value = value
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let value = try? container.decode(T.self) { self.value = value }
        else {
            let string = try container.decode(String.self)
            let value = try T(string: string)
            self.value = value
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(value.string)
    }
    
}

@propertyWrapper
public struct StringDecode<T: StringDecodable & Hashable>: Codable, Hashable {
    
    public var wrappedValue: T
    
    public init(wrappedValue: T) {
        self.wrappedValue = wrappedValue
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.wrappedValue = try container.decode(SafeDecode<T>.self).value
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.wrappedValue)
    }
    
}


extension Bool: StringDecodable {
    
    public init(string: String) throws {
        guard let bool = Bool(string) else {
            throw NeoSwiftError.illegalArgument("Unable to decode Bool from JSON string '\(string)'")
        }
        self = bool
    }
    
    public var string: String {
        return String(describing: self)
    }
    
}

extension BInt: StringDecodable {
    
    public init(string: String) throws {
        guard let bInt = BInt(string) else {
            throw NeoSwiftError.illegalArgument("Unable to decode BigInt from JSON string '\(string)'")
        }
        self = bInt
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let int = try? container.decode(Int.self) {
            self = BInt(int)
        } else {
            self = try BInt(string: container.decode(String.self))
        }
    }
    
    public var string: String {
        asString()
    }
    
}

extension Int: StringDecodable {
    
    public init(string: String) throws {
        guard let int = Int(string) else {
            throw NeoSwiftError.illegalArgument("Unable to decode Int from JSON string '\(string)'")
        }
        self = int
    }
    
    public var string: String {
        return String(self)
    }
    
}

extension Bytes: StringDecodable {
    
    public init(string: String) {
        self = string.base64Decoded
    }
    
    public var string: String {
        return String(bytes: self, encoding: .utf8) ?? ""
    }
    
}

extension AnyHashable: Codable {
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let value = try? container.decode(String.self) { self = value }
        else if let value = try? container.decode(Int.self) { self = value }
        else if let value = try? container.decode(BInt.self) { self = value }
        else if let value = try? container.decode(Double.self) { self = value }
        else if let value = try? container.decode(Bool.self) { self = value }
        else if let value = try? container.decode([AnyHashable].self) { self = value }
        else if let value = try? container.decode([AnyHashable : AnyHashable].self) { self = value }
        else { throw NeoSwiftError.illegalArgument("Unable to decode AnyHashable") }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case is String: try container.encode(self as! String)
        case is Int: try container.encode(self as! Int)
        case is BInt: try container.encode(self as! BInt)
        case is Bool: try container.encode(self as! Bool)
        case is Double: try container.encode(self as! Double)
        case is [AnyHashable]: try container.encode(self as! [AnyHashable])
        case is [AnyHashable: AnyHashable]: try container.encode(self as! [AnyHashable: AnyHashable])
        case is TransactionAttribute: try container.encode(self as! TransactionAttribute)
        case is ContractParameter: try container.encode(self as! ContractParameter)
        case is [ContractParameter]: try container.encode(self as! [ContractParameter])
        case is TransactionSigner: try container.encode(self as! TransactionSigner)
        case is [TransactionSigner]: try container.encode(self as! [TransactionSigner])
        case is TransactionSendToken: try container.encode(self as! TransactionSendToken)
        case is [TransactionSendToken]: try container.encode(self as! [TransactionSendToken])
        default: throw NeoSwiftError.illegalArgument("Unable to encode AnyHashable \(self)")
        }
    }
    
}

@propertyWrapper
public struct SingleValueOrNilArray<T: Codable>: Codable {
    
    public var wrappedValue: [T]
    
    public init(wrappedValue: [T]) {
        self.wrappedValue = wrappedValue
    }
    
    public init(from decoder: Decoder) throws {
        guard let container = try? decoder.singleValueContainer() else {
            self.wrappedValue = []
            return
        }
        if let t = try? container.decode(T.self) {
            self.wrappedValue = [t]
        } else if let t = try? container.decode([T].self) {
            self.wrappedValue = t
        } else {
            self.wrappedValue = []
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.wrappedValue)
    }
    
}

extension SingleValueOrNilArray: Equatable where T: Equatable { }
extension SingleValueOrNilArray: Hashable where T: Hashable { }

public class RawResponseJSONDecoder: JSONDecoder {
    
    public override func decode<T>(_ type: T.Type, from data: Data) throws -> T where T : Decodable {
        let t = try super.decode(T.self, from: data)
        if var r = t as? HasRawResponse {
            r.rawResponse = String(data: data, encoding: .utf8)
            return r as! T
        }
        return t
    }
    
}
