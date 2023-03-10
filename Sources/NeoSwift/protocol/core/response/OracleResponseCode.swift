
public enum OracleResponseCode: ByteEnum {
    
    case success, protocolNotSupported, consensusUnreachable, notFound, timeout, forbidden,
         responseTooLarge, insufficientFunds, contentTypeNotSupported, error
    
    public var jsonValue: String {
        switch self {
        case .success: return "Success"
        case .protocolNotSupported: return "ProtocolNotSupported"
        case .consensusUnreachable: return "ConsensusUnreachable"
        case .notFound: return "NotFound"
        case .timeout: return "Timeout"
        case .forbidden: return "Forbidden"
        case .responseTooLarge: return "ResponseTooLarge"
        case .insufficientFunds: return "InsufficientFunds"
        case .contentTypeNotSupported: return "ContentTypeNotSupported"
        case .error: return "Error"
        }
    }
    
    public var byte: Byte {
        switch self {
        case .success: return 0x00
        case .protocolNotSupported: return 0x10
        case .consensusUnreachable: return 0x12
        case .notFound: return 0x14
        case .timeout: return 0x16
        case .forbidden: return 0x18
        case .responseTooLarge: return 0x1a
        case .insufficientFunds: return 0x1c
        case .contentTypeNotSupported: return 0x1f
        case .error: return 0xff
        }
    }
    
}
