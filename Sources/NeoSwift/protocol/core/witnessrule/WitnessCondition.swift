
import Foundation

public indirect enum WitnessCondition: Hashable {
    
    case boolean(_ expression: Bool)
    case not(_ expression: WitnessCondition)
    case and(_ expressions: [WitnessCondition])
    case or(_ expressions: [WitnessCondition])
    case scriptHash(_ hash: Hash160)
    case group(_ group: ECPublicKey)
    case calledByEntry
    case calledByContract(_ hash: Hash160)
    case calledByGroup(_ key: ECPublicKey)
    
    static let MAX_SUBITEMS = 16
    static let MAX_NESTING_DEPTH = 2
    
    static let BOOLEAN_VALUE = "Boolean"
    static let NOT_VALUE = "Not"
    static let AND_VALUE = "And"
    static let OR_VALUE = "Or"
    static let SCRIPT_HASH_VALUE = "ScriptHash"
    static let GROUP_VALUE = "Group"
    static let CALLED_BY_ENTRY_VALUE = "CalledByEntry"
    static let CALLED_BY_CONTRACT_VALUE = "CalledByContract"
    static let CALLED_BY_GROUP_VALUE = "CalledByGroup"
    
    static let BOOLEAN_BYTE: Byte = 0x00
    static let NOT_BYTE: Byte = 0x01
    static let AND_BYTE: Byte = 0x02
    static let OR_BYTE: Byte = 0x03
    static let SCRIPT_HASH_BYTE: Byte = 0x18
    static let GROUP_BYTE: Byte = 0x19
    static let CALLED_BY_ENTRY_BYTE: Byte = 0x20
    static let CALLED_BY_CONTRACT_BYTE: Byte = 0x28
    static let CALLED_BY_GROUP_BYTE: Byte = 0x29
    
    var jsonValue: String {
        switch self {
        case .boolean: return WitnessCondition.BOOLEAN_VALUE
        case .not: return WitnessCondition.NOT_VALUE
        case .and: return WitnessCondition.AND_VALUE
        case .or: return WitnessCondition.OR_VALUE
        case .scriptHash: return WitnessCondition.SCRIPT_HASH_VALUE
        case .group: return WitnessCondition.GROUP_VALUE
        case .calledByEntry: return WitnessCondition.CALLED_BY_ENTRY_VALUE
        case .calledByContract: return WitnessCondition.CALLED_BY_CONTRACT_VALUE
        case .calledByGroup:return WitnessCondition.CALLED_BY_GROUP_VALUE
        }
    }
    
    var byte: Byte {
        switch self {
        case .boolean: return WitnessCondition.BOOLEAN_BYTE
        case .not: return WitnessCondition.NOT_BYTE
        case .and: return WitnessCondition.AND_BYTE
        case .or: return WitnessCondition.OR_BYTE
        case .scriptHash: return WitnessCondition.SCRIPT_HASH_BYTE
        case .group: return WitnessCondition.GROUP_BYTE
        case .calledByEntry: return WitnessCondition.CALLED_BY_ENTRY_BYTE
        case .calledByContract: return WitnessCondition.CALLED_BY_CONTRACT_BYTE
        case .calledByGroup:return WitnessCondition.CALLED_BY_GROUP_BYTE
        }
    }
    
}

extension WitnessCondition: Codable {
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        switch type {
        case WitnessCondition.BOOLEAN_VALUE:
            self = .boolean(try container.decode(SafeDecode<Bool>.self, forKey: .expression).value)//.boolean(stringToType(decoder, forKey: CodingKeys.expression))
        case WitnessCondition.NOT_VALUE:
            self = try .not(container.decode(WitnessCondition.self, forKey: CodingKeys.expression))
        case WitnessCondition.AND_VALUE, WitnessCondition.OR_VALUE:
            let expressions = try container.decode([WitnessCondition].self, forKey: CodingKeys.expressions)
            self = type == WitnessCondition.AND_VALUE ? .and(expressions) : .or(expressions)
        case WitnessCondition.SCRIPT_HASH_VALUE, WitnessCondition.CALLED_BY_CONTRACT_VALUE:
            let hashString = try container.decode(String.self, forKey: CodingKeys.hash)
            let hash = try Hash160(hashString)
            self = type == WitnessCondition.SCRIPT_HASH_VALUE ? .scriptHash(hash) : .calledByContract(hash)
        case WitnessCondition.GROUP_VALUE, WitnessCondition.CALLED_BY_GROUP_VALUE:
            let publicKeyString = try container.decode(String.self, forKey: .group)
            let publicKey = try ECPublicKey(publicKeyString)
            self = type == WitnessCondition.GROUP_VALUE ? .group(publicKey) : .calledByGroup(publicKey)
        case WitnessCondition.CALLED_BY_ENTRY_VALUE: self = .calledByEntry
        default: throw "Unable to deserialse WitnessCondition from JSON"
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(jsonValue, forKey: .type)
        switch self {
        case .boolean(let expression): try container.encode(expression, forKey: .expression)
        case .not(let expression):try container.encode(expression, forKey: .expression)
        case .and(let expressions), .or(let expressions): try container.encode(expressions, forKey: .expressions)
        case .scriptHash(let hash), .calledByContract(let hash): try container.encode(hash.string, forKey: .hash)
        case .calledByGroup(let group), .group(let group): try container.encode(group.getEncodedCompressedHex(), forKey: .group)
        default: break
        }
    }
    
    private enum CodingKeys: String, CodingKey {
        case type, expression, expressions, hash, group
    }
    
}

extension WitnessCondition: NeoSerializable {
    
    public var size: Int {
        switch self {
        case .boolean: return 2
        case .not(let expression): return 1 + expression.size
        case .and(let expressions), .or(let expressions): return 1 + expressions.varSize
        case .scriptHash(let hash), .calledByContract(let hash): return 1 + hash.size
        case .group(let group), .calledByGroup(let group): return 1 + group.size
        case .calledByEntry: return 1
        }
    }
    
    public func serialize(_ writer: BinaryWriter) {
        writer.writeByte(byte)
        switch self {
        case .boolean(let boolean): writer.writeBoolean(boolean)
        case .not(let expression): writer.writeSerializableFixed(expression)
        case .and(let expressions), .or(let expressions): writer.writeSerializableVariable(expressions)
        case .scriptHash(let hash), .calledByContract(let hash): writer.writeSerializableFixed(hash)
        case .group(let group), .calledByGroup(let group): writer.writeSerializableFixed(group)
        default: break
        }
    }
    
    public static func deserialize(_ reader: BinaryReader) throws -> WitnessCondition {
        let typeByte = reader.readByte()
        switch typeByte {
        case BOOLEAN_BYTE: return .boolean(reader.readBoolean())
        case NOT_BYTE:
            return try .not(WitnessCondition.deserialize(reader))
        case AND_BYTE, WitnessCondition.OR_BYTE:
            let expressions = try (0 ..< reader.readVarInt()).map { _ in
                return try WitnessCondition.deserialize(reader)
            }
            return typeByte == AND_BYTE ? .and(expressions) : .or(expressions)
        case SCRIPT_HASH_BYTE, CALLED_BY_CONTRACT_BYTE:
            let hash = try Hash160.deserialize(reader)
            return typeByte == SCRIPT_HASH_BYTE ? .scriptHash(hash) : .calledByContract(hash)
        case GROUP_BYTE, CALLED_BY_GROUP_BYTE:
            let key = try ECPublicKey.deserialize(reader)
            return typeByte == GROUP_BYTE ? .group(key) : .calledByGroup(key)
        case CALLED_BY_ENTRY_BYTE: return .calledByEntry
        default: throw "The deserialized type does not match the type information in the serialized data."
        }
    }
    
    
}

extension WitnessCondition {
    
    var booleanExpression: Bool? {
        if case let .boolean(bool) = self { return bool }
        return nil
    }
    
    var expression: WitnessCondition? {
        if case let .not(exp) = self { return exp }
        return nil
    }
    
    var expressionList: [WitnessCondition]? {
        switch self {
        case .or(let expressions), .and(let expressions): return expressions
        default: return nil
        }
    }
    
    var scriptHash: Hash160? {
        switch self {
        case .scriptHash(let hash), .calledByContract(let hash): return hash
        default: return nil
        }
    }
    
    var group: ECPublicKey? {
        switch self {
        case .group(let group), .calledByGroup(let group): return group
        default: return nil
        }
    }
    
}

