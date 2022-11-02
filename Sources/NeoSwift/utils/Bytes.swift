
import BigInt
import Foundation

extension Bytes {
    
    var bInt: BInt {
        return BInt(magnitude: self)
    }
    
    var base64Encoded: String {
        return self.toBase64()
    }
    
    var base58Encoded: String {
        return Base58.encode(self)
    }
    
    var base58CheckEncoded: String {
        return Base58.base58CheckEncode(self)
    }
    
}
