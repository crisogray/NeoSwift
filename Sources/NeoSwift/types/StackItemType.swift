
import Foundation
import DynamicCodableKit

public enum StackItemType: String, CaseIterable, Encodable, Hashable, DynamicDecodingContextIdentifierKey {

    public var associatedContext: DynamicDecodingContext<StackItem> {
        switch self {
        case .any: return DynamicDecodingContext(decoding: AnyStackItem.self)
        case .pointer: return DynamicDecodingContext(decoding: PointerStackItem.self)
        case .boolean: return DynamicDecodingContext(decoding: BooleanStackItem.self)
        case .integer: return DynamicDecodingContext(decoding: IntegerStackItem.self)
        case .byteString: return DynamicDecodingContext(decoding: ByteStringStackItem.self)
        case .buffer: return DynamicDecodingContext(decoding: BufferStackItem.self)
        case .array: return DynamicDecodingContext(decoding: ArrayStackItem.self)
        case .struct: return DynamicDecodingContext(decoding: StructStackItem.self)
        case .map: return DynamicDecodingContext(decoding: MapStackItem.self)
        case .interopInterface: return DynamicDecodingContext(decoding: InteropInterfaceStackItem.self)
        }
    }
    
    case any = "Any", pointer = "Pointer", boolean = "Boolean", integer = "Integer", byteString = "ByteString",
         buffer = "Buffer", array = "Array", `struct` = "Struct", map = "Map", interopInterface = "InteropInterface"

    var byte: Byte {
        switch self {
        case .any: return 0x00
        case .pointer: return 0x10
        case .boolean: return 0x20
        case .integer: return 0x21
        case .byteString: return 0x28
        case .buffer: return 0x30
        case .array: return 0x40
        case .struct: return 0x41
        case .map: return 0x48
        case .interopInterface: return 0x60
        }
    }

    static func valueOf(_ byte: Byte) -> StackItemType? {
        return allCases.first { $0.byte == byte }
    }

}

public enum StackItemTypeCodingKey: String, DynamicDecodingContextIdentifierCodingKey {
    
    public typealias Identifier = StackItemType
    public typealias Identified = StackItem
    case type
    public static var identifierCodingKey: Self { .type }
    
}
