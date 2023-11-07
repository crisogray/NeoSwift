
import Foundation
import BigInt

public indirect enum StackItem: Hashable {
    
    static let ANY_VALUE = "Any"
    static let POINTER_VALUE = "Pointer"
    static let BOOLEAN_VALUE = "Boolean"
    static let INTEGER_VALUE = "Integer"
    static let BYTE_STRING_VALUE = "ByteString"
    static let BUFFER_VALUE = "Buffer"
    static let ARRAY_VALUE = "Array"
    static let STRUCT_VALUE = "Struct"
    static let MAP_VALUE = "Map"
    static let INTEROP_INTERFACE_VALUE = "InteropInterface"
    
    static let ANY_BYTE: Byte = 0x00
    static let POINTER_BYTE: Byte = 0x10
    static let BOOLEAN_BYTE: Byte = 0x20
    static let INTEGER_BYTE: Byte = 0x21
    static let BYTE_STRING_BYTE: Byte = 0x28
    static let BUFFER_BYTE: Byte = 0x30
    static let ARRAY_BYTE: Byte = 0x40
    static let STRUCT_BYTE: Byte = 0x41
    static let MAP_BYTE: Byte = 0x48
    static let INTEROP_INTERFACE_BYTE: Byte = 0x60
    
    public var jsonValue: String {
        switch self {
        case .any: return StackItem.ANY_VALUE
        case .pointer: return StackItem.POINTER_VALUE
        case .boolean: return StackItem.BOOLEAN_VALUE
        case .integer: return StackItem.INTEGER_VALUE
        case .byteString: return StackItem.BYTE_STRING_VALUE
        case .buffer: return StackItem.BUFFER_VALUE
        case .array: return StackItem.ARRAY_VALUE
        case .struct: return StackItem.STRUCT_VALUE
        case .map: return StackItem.MAP_VALUE
        case .interopInterface: return StackItem.INTEROP_INTERFACE_VALUE
        }
    }
    
    public var byte: Byte {
        switch self {
        case .any: return StackItem.ANY_BYTE
        case .pointer: return StackItem.POINTER_BYTE
        case .boolean: return StackItem.BOOLEAN_BYTE
        case .integer: return StackItem.INTEGER_BYTE
        case .byteString: return StackItem.BYTE_STRING_BYTE
        case .buffer: return StackItem.BUFFER_BYTE
        case .array: return StackItem.ARRAY_BYTE
        case .struct: return StackItem.STRUCT_BYTE
        case .map: return StackItem.MAP_BYTE
        case .interopInterface: return StackItem.INTEROP_INTERFACE_BYTE
        }
    }
    
    case any(_ value: AnyHashable?)
    case pointer(_ value: BInt)
    case boolean(_ value: Bool)
    case integer(_ value: BInt)
    case byteString(_ value: Bytes)
    case buffer(_ value: Bytes)
    case array(_ value: [StackItem])
    case `struct`(_ value: [StackItem])
    case map(_ value: [StackItem : StackItem])
    case interopInterface(_ iteratorId: String, _ interfaceName: String)
    
}

extension StackItem: Codable {
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        switch type {
        case StackItem.ANY_VALUE: self = .any(try? container.decode(AnyHashable.self, forKey: .value))
        case StackItem.POINTER_VALUE, StackItem.INTEGER_VALUE:
            let int = try container.decode(SafeDecode<BInt>.self, forKey: .value).value
            self = type == StackItem.POINTER_VALUE ? .pointer(int) : .integer(int)
        case StackItem.BOOLEAN_VALUE: self = try .boolean(container.decode(SafeDecode<Bool>.self, forKey: .value).value)
        case StackItem.BYTE_STRING_VALUE, StackItem.BUFFER_VALUE:
            let bytes = try container.decode(SafeDecode<Bytes>.self, forKey: .value).value
            self = type == StackItem.BYTE_STRING_VALUE ? .byteString(bytes) : .buffer(bytes)
        case StackItem.ARRAY_VALUE, StackItem.STRUCT_VALUE:
            let array = try container.decode([StackItem].self, forKey: .value)
            self = type == StackItem.ARRAY_VALUE ? .array(array) : .struct(array)
        case StackItem.MAP_VALUE:
            let map = try container.decode([[String : StackItem]].self, forKey: .value)
                .reduce(into: [StackItem : StackItem]()) { $0[$1["key"]!] = $1["value"]! }
            self = .map(map)
        case StackItem.INTEROP_INTERFACE_VALUE:
            let id = try container.decode(String.self, forKey: .id)
            let interface = try container.decode(String.self, forKey: .interface)
            self = .interopInterface(id, interface)
        default: throw NeoSwiftError.illegalArgument("There exists no stack item with the provided json value. The provided json value was \(type).")
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(jsonValue, forKey: .type)
        switch self {
        case .any(let value): try container.encode(value, forKey: .value)
        case .pointer(let int), .integer(let int): try container.encode(int, forKey: .value)
        case .boolean(let bool): try container.encode(bool, forKey: .value)
        case .byteString(let bytes), .buffer(let bytes): try container.encode(String(bytes: bytes, encoding: .utf8), forKey: .value)
        case .array(let array), .struct(let array): try container.encode(array, forKey: .value)
        case .map(let map):
            let transformed = map.map { keyItem, valueItem in
                ["key" : keyItem, "value" : valueItem]
            }
            try container.encode(transformed, forKey: .value)
        case .interopInterface(let id, let interface):
            try container.encode(id, forKey: .id)
            try container.encode(interface, forKey: .interface)
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case type, value, id, interface
    }
    
}

extension StackItem {
    
    var toString: String {
        let maxLength = 80
        var valueString = valueString
        valueString = valueString.count > maxLength ? "\(String(valueString.prefix(maxLength)))..." : valueString
        return jsonValue + "{value='\(valueString)'}"
    }
    
    var valueString: String {
        switch self {
        case .any(let value): return value == nil ? "null" : String(describing: value)
        case .pointer(let int), .integer(let int): return int.asString()
        case .boolean(let bool): return bool ? "true" : "false"
        case .byteString(let bytes), .buffer(let bytes): return bytes.noPrefixHex
        case .array(let array), .struct(let array): return array.map(\.toString).joined(separator: ", ")
        case .map(let map): return map.map { $0.key.toString + " -> " + $0.value.toString }.joined(separator: ", ")
        case .interopInterface(let id, _): return id
        }
    }
    
    var value: AnyHashable? {
        switch self {
        case .any(let value): return value
        case .pointer(let int), .integer(let int): return int
        case .boolean(let bool): return bool
        case .byteString(let bytes), .buffer(let bytes): return bytes
        case .array(let array), .struct(let array): return array
        case .map(let map): return map
        case .interopInterface(let id, _): return id
        }
    }
    
    var boolean: Bool? {
        switch self {
        case .any(let value): return value as? Bool
        case .boolean(let bool): return bool
        case .integer(let int): return int == 1 ? true : int == 0 ? false : nil
        case .byteString(_), .buffer(_): return integer! > 0
        default: return nil
        }
    }
    
    var integer: Int? {
        switch self {
        case .any(let value): return value as? Int
        case .boolean(let bool): return bool ? 1 : 0
        case .pointer(let int), .integer(let int): return int.asInt()
        case .byteString(let bytes), .buffer(let bytes): return BInt(magnitude: bytes.reversed()).asInt()!
        default: return nil
        }
    }

    public func getInteger() throws -> Int {
        guard let integer = integer else {
            throw ProtocolError.stackItemCastError(self, "integer")
        }
        return integer
    }
    
    var address: String? {
        switch self {
        case .byteString(let bytes), .buffer(let bytes): return try? Hash160(bytes.reversed()).toAddress()
        default: return nil
        }
    }
        
    var string: String? {
        switch self {
        case .any(let value): return value as? String
        case .boolean(let bool): return bool ? "true" : "false"
        case .integer(let int): return int.asString()
        case .byteString(let bytes), .buffer(let bytes): return String(bytes: bytes, encoding: .utf8)
        default: return nil
        }
    }

    public func getString() throws -> String {
        guard let string = string else {
            throw ProtocolError.stackItemCastError(self, "string")
        }
        return string
    }
    
    var hexString: String? {
        switch self {
        case .byteString(let bytes), .buffer(let bytes): return bytes.noPrefixHex
        case .integer(_): return byteArray?.reduce("") {$0 + String(format: "%02x", $1)}
        default: return nil
        }
    }
    
    public func getHexString() throws -> String {
        guard let hexString = hexString else {
            throw ProtocolError.stackItemCastError(self, "hex string")
        }
        return hexString
    }
    
    var byteArray: Bytes? {
        switch self {
        case .byteString(let bytes), .buffer(let bytes): return bytes.isEmpty ? nil : bytes
        case .integer(let int): return int.asSignedBytes().reversed()
        default: return nil
        }
    }
    
    public func getByteArray() throws -> Bytes {
        guard let byteArray = byteArray else {
            throw ProtocolError.stackItemCastError(self, "byte array")
        }
        return byteArray
    }

    var list: [StackItem]? {
        switch self {
        case .array(let array), .struct(let array): return array
        default: return nil
        }
    }
    
    public func getList() throws -> [StackItem] {
        guard let list = list else {
            throw ProtocolError.stackItemCastError(self, "list")
        }
        return list
    }
    
    var map: [StackItem: StackItem]? {
        if case .map(let map) = self {
            return map
        }
        return nil
    }
    
    var pointer: Int? {
        if case .pointer = self {
            return integer
        }
        return nil
    }
    
    var iteratorId: String? {
        if case .interopInterface(let id, _) = self {
            return id
        }
        return nil
    }
    
}
