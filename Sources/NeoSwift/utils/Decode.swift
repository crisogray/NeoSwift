
import Foundation

func stringToType<T: Decodable, K: CodingKey>(_ decoder: Decoder, forKey key: KeyedDecodingContainer<K>.Key) throws -> T {
    if let container = try? decoder.container(keyedBy: StackItemValueCodingKey.self) {
        if let value = try? container.decode(T.self, forKey: .value) {
            return value
        } else if let string = try? container.decode(String.self, forKey: .value) {
            if T.self == Bool.self || T.self == Optional<Bool>.self {
                return (string == "true") as! T
            } else if T.self == Int.self || T.self == Optional<Int>.self {
                return Int(string) as! T
            } else if T.self == Bytes.self || T.self == Optional<Bytes>.self {
                return string.base64Decoded as! T
            }
        }
    }
    throw "Unable to convert stack item value to \(T.self)"
}

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

