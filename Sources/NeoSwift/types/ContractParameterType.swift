
public enum ContractParamterType: ByteEnum {

    case any, boolean, integer, byteArray, string, hash160, hash256,
         publicKey, signature, array, map, interopInterface, void

    public var jsonValue: String {
        switch self {
        case .any: return "Any"
        case .boolean: return "Boolean"
        case .integer: return "Integer"
        case .byteArray: return "ByteArray"
        case .string: return "String"
        case .hash160: return "Hash160"
        case .hash256: return "Hash256"
        case .publicKey: return "PublicKey"
        case .signature: return "Signature"
        case .array: return "Array"
        case .map: return "Map"
        case .interopInterface: return "InteropInterface"
        case .void: return "Void"
        }
    }
    
    public var byte: Byte {
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


}
