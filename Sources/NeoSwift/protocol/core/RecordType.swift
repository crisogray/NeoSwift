
import Foundation

public enum RecordType: ByteEnum {
    
    /// An address record.
    case a
    
    /// A canonical name record.
    case cname
    
    /// A text record.
    case txt
    
    /// An IPv6 address record.
    case aaaa
    
    public var jsonValue: String {
        switch self {
        case .a: return "A"
        case .cname: return "CNAME"
        case .txt: return "TXT"
        case .aaaa: return "AAAA"
        }
    }
    
    public var byte: Byte {
        switch self {
        case .a: return 1
        case .cname: return 5
        case .txt: return 16
        case .aaaa: return 28
        }
    }
    
}
