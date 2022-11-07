
import BigInt
import Foundation

extension Bytes {
    
    var bInt: BInt {
        return BInt(magnitude: self)
    }
    
    var base64Encoded: String {
        return toBase64()
    }
    
    var base58Encoded: String {
        return Base58.encode(self)
    }
    
    var base58CheckEncoded: String {
        return Base58.base58CheckEncode(self)
    }
    
    func toPadded(length: Int, trailing: Bool = false) -> Bytes {
        let firstZero = self.first == 0
        let srcOffset = firstZero ? 1 : 0
        let bytesLength = self.count - srcOffset
        guard bytesLength <= length else {
            print("Input is too large to put in byte array of size \(length)")
            return []
        }
        if trailing {
            return self[srcOffset..<bytesLength] + Bytes(repeating: 0, count: length - bytesLength)
        }
        return Bytes(repeating: 0, count: length - bytesLength) + self[srcOffset..<bytesLength]
    }
    
}
