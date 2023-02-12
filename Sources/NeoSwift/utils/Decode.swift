
import Foundation

public protocol SafeDecodable {
    init?(_ string: String)
}

public class SafeDecode<T: Codable & SafeDecodable>: Codable {
    
    let value: T
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let value = try? container.decode(T.self) {
            self.value = value
        } else if let string = try? container.decode(String.self), let value = T(string) {
            self.value = value
        } else {
            throw "Unable to decode \(String(describing: T.self)) from JSON"
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(value)
    }
    
}

extension Bool: SafeDecodable {}
extension Int: SafeDecodable {}

extension Bytes: SafeDecodable {
    
    public init?(_ string: String) {
        self = string.base64Decoded
    }
    
}

extension AnyHashable: Codable {
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let value = try? container.decode(String.self) {
            self = value
        } else if let value = try? container.decode(Int.self) {
            self = value
        } else if let value = try? container.decode(Double.self) {
            self = value
        } else if let value = try? container.decode(Bool.self) {
            self = value
        } else if let value = try? container.decode([AnyHashable].self) {
            self = value
        } else if let value = try? container.decode([AnyHashable : AnyHashable].self) {
            self = value
        } else {
            throw "Unable to decode AnyHashable"
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        if let string = self as? String {
            try container.encode(string)
        } else if let int = self as? Int {
            try container.encode(int)
        } else if let double = self as? Double {
            try container.encode(double)
        } else if let bool = self as? Bool {
            try container.encode(bool)
        } else if let hashables = self as? [AnyHashable] {
            try container.encode(hashables)
        } else if let hashables = self as? [AnyHashable : AnyHashable] {
            try container.encode(hashables)
        } else {
            throw "Unable to encode AnyHashable"
        }
    }
    
}
