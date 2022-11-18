
import Foundation


public enum StackItemType: String, CaseIterable {

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
