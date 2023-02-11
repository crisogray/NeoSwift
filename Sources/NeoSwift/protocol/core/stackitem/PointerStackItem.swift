
import Foundation

public struct PointerStackItem: StackItem, Hashable {
    
    public var type: StackItemType = .pointer
    let value: Int?
    
    init(_ value: Int) {
        self.value = value
    }
    
    public init(from decoder: Decoder) throws {
        self.value = try stringToType(decoder, forKey: StackItemValueCodingKey.value)
    }
    
    public func getValue() throws -> AnyHashable {
        return value
    }
    
    public func getInteger() throws -> Int {
        guard let value = value else {
            throw "Cannot get stack item value because it is null"
        }
        return value
    }

    public func getPointer() throws -> Int {
        guard let value = value else {
            throw "Cannot get stack item value because it is null"
        }
        return value
    }

}
