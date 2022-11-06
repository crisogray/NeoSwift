
import BigInt
import Foundation

extension ECPoint {
    
    func multiply(_ k: BInt) throws -> ECPoint {
        return try NeoConstants.SECP256R1_DOMAIN.multiplyPoint(self, k)
    }
    
    func getEncoded(_ compressed: Bool) throws -> Bytes {
        return try NeoConstants.SECP256R1_DOMAIN.encodePoint(self, compressed)
    }
    
}
