
import Foundation
import DynamicCodableKit

public protocol StackItem: DynamicCodable {
    
    var type: StackItemType { get }
    var valueString: String { get }
    func getValue() throws -> AnyHashable
    func getBoolean() throws -> Bool
    func getInteger() throws -> Int
    func getAddress() throws -> String
    func getString() throws -> String
    func getHexString() throws -> String
    func getByteArray() throws -> Bytes
    func getList() throws -> [StackItem]
    func getMap() throws -> [(StackItem, StackItem)]
    func getPointer() throws -> Int
    func getIteratorId() throws -> String
}

public extension StackItem {
    
    var valueString: String {
        return (try? getValue().description) ?? "null"
    }
    
    var string: String {
        let maxLength = 80
        var valueString = valueString
        valueString = valueString.count > maxLength ? "\(String(valueString.prefix(maxLength)))..." : valueString
        return type.rawValue + "{value='\(valueString)'}"
    }
    
    func anyHashable() -> AnyHashable {
        switch type {
        case .any: return self as! AnyStackItem
        case .pointer: return self as! PointerStackItem
        case .boolean: return self as! BooleanStackItem
        case .integer: return self as! IntegerStackItem
        case .byteString: return self as! ByteStringStackItem
        case .buffer: return self as! BufferStackItem
        case .array: return self as! ArrayStackItem
        case .struct: return self as! StructStackItem
        case .map: return self as! MapStackItem
        case .interopInterface: return self as! InteropInterfaceStackItem
        }
    }
    
    func getValue() throws -> AnyHashable {
        throw "Cannot get stack item value because it is null"
    }
    
    func getBoolean() throws -> Bool {
        throw "Cannot cast stack item \(string) to a boolean."
    }
    
    func getInteger() throws -> Int {
        throw "Cannot cast stack item \(string) to a boolean."
    }
    
    func getAddress() throws -> String {
        throw "Cannot cast stack item \(string) to an address."
    }
    
    func getString() throws -> String {
        throw "Cannot cast stack item \(string) to a string."
    }
    
    func getHexString() throws -> String {
        throw "Cannot cast stack item \(string) to a string."
    }
    
    func getByteArray() throws -> Bytes {
        throw "Cannot cast stack item \(string) to a byte array."
    }
    
    func getList() throws -> [StackItem] {
        throw "Cannot cast stack item \(string) to a list."
    }

    func getMap() throws -> [(StackItem, StackItem)] {
        throw "Cannot cast stack item \(string) to a map."
    }
    
    func getPointer() throws -> Int {
        throw "Cannot cast stack item \(string) to a neo-vm pointer."
    }
    
    func getIteratorId() throws -> String {
        throw "Cannot cast stack item \(string) to a neo-vm session id."
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(type)
        hasher.combine(try? getValue())
    }
    
}

enum StackItemValueCodingKey: String, CodingKey {
    case value
}

public func == (lhs: StackItem, rhs: StackItem) -> Bool {
    return lhs.anyHashable() == rhs.anyHashable()
}

public func != (lhs: StackItem, rhs: StackItem) -> Bool {
    return !(lhs == rhs)
}
