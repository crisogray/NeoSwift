
import Foundation


public enum ContractParamterType: String, CaseIterable {

    case any = "Any", boolean = "Boolean", integer = "Integer", byteArray = "ByteArray", string = "String",
         hash160 = "Hash160", hash256 = "Hash256", publicKey = "PublicKey", signature = "Signature",
         array = "Array", map = "Map", interopInterface = "InteropInterface", void = "Void"

    var byte: Byte {
        switch self {
        case .any: return 0x00
        case .boolean: return 0x10
        case .integer: return 0x11
        case .byteArray: return 0x12
        case .string: return 0x13
        case .hash160: return 0x14
        case .hash256: return 0x15
        case .publicKey: return 0x16
        case .signature: return 0x17
        case .array: return 0x20
        case .map: return 0x22
        case .interopInterface: return 0x30
        case .void: return 0xff
        }
    }

    static func valueOf(_ byte: Byte) -> ContractParamterType? {
        return allCases.first { $0.byte == byte }
    }

}
