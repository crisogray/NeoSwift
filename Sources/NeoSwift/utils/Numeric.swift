
import BigInt
import Foundation

extension BInt {
    
    func toBytesPadded(length: Int) -> Bytes {
        let bytes = asMagnitudeBytes()
        return bytes.toPadded(length: length)
    }
    
}

extension Int {
    
    func toPowerOf(_ p: Self) -> Self {
        return Self(pow(Double(self), Double(p)))
    }
    
}

extension Numeric {
    
    var bytes: Bytes {
        return bigEndianBytes.reversed()
    }
    
    var bigEndianBytes: Bytes {
        var int = self
        return Data(bytes: &int, count: MemoryLayout.size(ofValue: self)).bytes
    }
}
