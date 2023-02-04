
import Foundation
import BigInt

public struct IntegerStackItem: StackItem, Hashable {
    
    public var type: StackItemType = .integer
    let value: Int?
    
    init(_ value: Int?) {
        self.value = value
    }
    
    public init(from decoder: Decoder) throws {
        self.value = try Self.stringToType(decoder)
    }
    
    public func getValue() throws -> AnyHashable {
        return value
    }
    
    public func getBoolean() throws -> Bool {
        guard let value = value else {
            throw "Cannot get stack item value because it is null"
        }
        guard value == 1 || value == 0 else {
            throw "Cannot cast stack item \(string) to a boolean."
        }
        return value == 1
    }
    
    public func getInteger() throws -> Int {
        guard let value = value else {
            throw "Cannot get stack item value because it is null"
        }
        return value
    }
    
    public func getString() throws -> String {
        guard let value = value else {
            throw "Cannot get stack item value because it is null"
        }
        return String(value)
    }
    
    public func getByteArray() throws -> Bytes {
        guard let value = value else {
            throw "Cannot get stack item value because it is null"
        }
        return BInt(value).asSignedBytes().reversed()
    }
    
    public func getHexString() throws -> String {
        return try getByteArray().reduce("") {$0 + String(format: "%02x", $1)}
    }
    
}


