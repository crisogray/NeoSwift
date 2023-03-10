
import Foundation

public enum RecordType: ByteEnum {
    
    case a, cname, txt, aaaa
    
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
