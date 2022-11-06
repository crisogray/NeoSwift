
import BigInt
import Foundation

extension BInt {
    
    func toBytesPadded(length: Int) -> Bytes {
        let bytes = asMagnitudeBytes()
        let firstZero = bytes.first == 0
        let srcOffset = firstZero ? 1 : 0
        let bytesLength = bytes.count - srcOffset
        guard bytesLength <= length else {
            print("Input is too large to put in byte array of size \(length)")
            return []
        }
        return Bytes(repeating: 0, count: length - bytesLength) + bytes[srcOffset..<bytesLength]
    }
    
}

extension Int {
    
    var bytes: Bytes {
        var int = self
        return Data(bytes: &int, count: 4).reversed()
    }
    
}
