
import Foundation

public enum WitnessAction: ByteEnum {
    
    case deny, allow

    public var jsonValue: String {
        switch self {
        case .deny: return "Deny"
        case .allow: return "Allow"
        }
    }
    
    public var byte: Byte { return self == .allow ? 1 : 0 }

}
