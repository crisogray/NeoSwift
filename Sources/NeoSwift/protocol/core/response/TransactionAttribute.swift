
import BigInt

public enum TransactionAttribute: ByteEnum, CaseIterable {
    
    static let MAX_RESULT_SIZE: Int = 0xffff
    
    public static var allCases: [TransactionAttribute] = [.highPriority, .oracleResponse(0, .error, "")]
    
    case highPriority
    case oracleResponse(_ id: Int, _ responseCode: OracleResponseCode, _ result: String)
    
    public var jsonValue: String {
        switch self {
        case .highPriority: return "HighPriority"
        case .oracleResponse: return "OracleResponse"
        }
    }
    
    public var byte: Byte {
        switch self {
        case .highPriority: return 0x01
        case .oracleResponse: return 0x11
        }
    }
    
}

extension TransactionAttribute: Codable {
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let typeString = try container.decode(String.self, forKey: .type)
        guard let type = TransactionAttribute.fromJsonValue(typeString) else {
            throw "\(String(describing: TransactionAttribute.self)) value type not found"
        }
        switch type {
        case .highPriority: self = .highPriority
        case .oracleResponse:
            let id = try container.decode(SafeDecode<Int>.self, forKey: .id).value
            let responseCode = try container.decode(OracleResponseCode.self, forKey: .code)
            let result = try container.decode(String.self, forKey: .result)
            self = .oracleResponse(id, responseCode, result)
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(jsonValue, forKey: .type)
        switch self {
        case .highPriority: break
        case .oracleResponse(let id, let responseCode, let result):
            try container.encode(id, forKey: .id)
            try container.encode(responseCode, forKey: .code)
            try container.encode(result, forKey: .result)
        }
    }
    
    private enum CodingKeys: String, CodingKey {
        case type, id, code, result
    }
    
}

extension TransactionAttribute: NeoSerializable {
    
    public var size: Int {
        switch self {
        case .highPriority: return 1
        case .oracleResponse(_, _, let result):
            return 1 + 9 + result.varSize
        }
    }
    
    public func serialize(_ writer: BinaryWriter) {
        writer.writeByte(byte)
        if case .oracleResponse(let id, let responseCode, let result) = self {
            writer.write(BInt(id).asMagnitudeBytes().reversed())
            writer.writeByte(responseCode.byte)
            writer.writeVarBytes(result.base64Decoded)
        }
    }
    
    public static func deserialize(_ reader: BinaryReader) -> TransactionAttribute? {
        if let type = TransactionAttribute.valueOf(reader.readByte()) {
            if case .highPriority = type { return type }
            else {
                if let id = try? BInt(magnitude: reader.readBytes(8).reversed()).asInt()!,
                   let code = OracleResponseCode.valueOf(reader.readByte()),
                   let result = try? reader.readVarBytes(MAX_RESULT_SIZE).base64Encoded {
                    return .oracleResponse(id, code, result)
                }
            }
        }
        return nil
    }
    
}
