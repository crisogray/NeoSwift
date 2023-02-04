
import Foundation

public class AnyStackItem: StackItem, Hashable {
    
    public var type: StackItemType = .any
    let value: AnyHashable?
    
    init(_ value: AnyHashable?) {
        self.value = value
    }
    
    public func getValue() throws -> AnyHashable {
        guard let value = value else {
            throw "Cannot get stack item value because it is null"
        }
        return value
    }
    
    public static func == (lhs: AnyStackItem, rhs: AnyStackItem) -> Bool {
        return lhs.value == rhs.value
    }
    
}

extension AnyHashable: Codable {
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let value = try? container.decode(String.self) {
            self = value
        } else if let value = try? container.decode(Int.self) {
            self = value
        } else if let value = try? container.decode(Bool.self) {
            self = value
        } else if let value = try? container.decode(Bytes.self) {
            self = value
        } else if let value = try? container.decode([AnyHashable].self) {
            self = value
        }
        throw "Unable to decode AnyHashable"
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        if let string = self as? String {
            try container.encode(string)
        } else if let int = self as? Int {
            try container.encode(int)
        } else if let bool = self as? Bool {
            try container.encode(bool)
        } else if let bytes = self as? Bytes {
            try container.encode(bytes)
        } else if let hashables = self as? [AnyHashable] {
            try container.encode(hashables)
        }
        throw "Unable to encode AnyHashable"
    }
    
}
