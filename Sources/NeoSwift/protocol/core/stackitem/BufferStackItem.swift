

import Foundation
import BigInt

public struct BufferStackItem: StackItem, Hashable {
    
    public var type: StackItemType = .buffer
    let value: Bytes
    
    public init(from decoder: Decoder) throws {
        self.value = (try? stringToType(decoder, forKey: StackItemValueCodingKey.value)) ?? []
    }
    
    public var valueString: String {
        return value.toHexString().cleanedHexPrefix
    }
    
    init(_ value: Bytes) {
        self.value = value
    }
    
    init(_ hexValue: String) {
        self.value = hexValue.bytesFromHex
    }
    
    public func getValue() throws -> AnyHashable {
        if value == [] {
            throw "Cannot get stack item value because it is null"
        }
        return value
    }
    
    public func getAddress() throws -> String {
        return try Hash160(value.reversed()).toAddress()
    }
    
    public func getBoolean() throws -> Bool {
        return try getInteger() > 0
    }
    
    public func getByteArray() throws -> Bytes {
        if value == [] {
            throw "Cannot get stack item value because it is null"
        }
        return value
    }
    
    public func getInteger() throws -> Int {
        if value == [] {
            throw "Cannot get stack item value because it is null"
        }
        return BInt(magnitude: value.reversed()).asInt()!
    }
    
    public func getString() throws -> String {
        guard let string = String(bytes: value, encoding: .utf8) else {
            throw "Cannot cast stack item \(string) to a string."
        }
        return string
    }
    
    public func getHexString() throws -> String {
        return value.toHexString().cleanedHexPrefix
    }

}
