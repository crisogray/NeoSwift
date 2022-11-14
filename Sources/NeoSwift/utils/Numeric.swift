
import BigInt
import Foundation

public extension BInt {
    
    func toBytesPadded(length: Int) -> Bytes {
        let bytes = asMagnitudeBytes()
        return bytes.toPadded(length: length)
    }
    
}

public extension Int {
    
    func toPowerOf(_ p: Self) -> Self {
        return Self(pow(Double(self), Double(p)))
    }
    
    var varSize: Int {
        if self < 0xFD { return 1 }
        else if self <= 0xFFFF { return 3 }
        else if self <= 0xFFFFFFFF { return 5 }
        else { return 9 }
    }
    
}

public extension Numeric {
    
    var bytes: Bytes {
        return bigEndianBytes.reversed()
    }
    
    var bigEndianBytes: Bytes {
        var int = self
        return Data(bytes: &int, count: MemoryLayout.size(ofValue: self)).bytes
    }
    
}
