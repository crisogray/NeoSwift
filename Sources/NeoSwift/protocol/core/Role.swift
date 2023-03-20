
public enum Role: ByteEnum {
    
    case stateValidator, oracle, neoFSAlphabetNode
    
    public var jsonValue: String {
        switch self {
        case .stateValidator: return "StateValidator"
        case .oracle: return "Oracle"
        case .neoFSAlphabetNode: return "NeoFSAlphabetNode"
        }
    }
    
    public var byte: Byte {
        switch self {
        case .stateValidator: return 0x04
        case .oracle: return 0x08
        case .neoFSAlphabetNode: return 0x10
        }
    }
    
}
