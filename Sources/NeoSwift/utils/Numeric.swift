
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
    
    var toUnsigned: Int {
        return self & 0xffffffff
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

extension Decimal {
    
    var scale: Int {
        return -min(0, exponent)
    }
    
}

extension Date {
    var millisecondsSince1970: Int64 {
        Int64((self.timeIntervalSince1970 * 1000.0).rounded())
    }
}
