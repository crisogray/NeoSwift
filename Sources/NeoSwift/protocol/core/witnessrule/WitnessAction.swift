
import Foundation

public enum WitnessAction: String, Codable {
    
    case deny = "Deny", allow = "Allow"
    
    var byte: Byte { return self == .allow ? 1 : 0 }
    
    static func valueOf(_ byte: Byte) -> WitnessAction? {
        return byte == 1 ? .allow : byte == 0 ? .deny : nil
    }

}
