
import BigInt
import Foundation
import SwiftECC

/// AN ECDSA Signature
public class ECDSASignature {
    
    public let signature: ECSignature
    
    public var r: BInt {
        return signature.r.bInt
    }
    
    public var s: BInt {
        return signature.s.bInt
    }
    
    /// `true` if the S component is "low", that means it is below ``NeoConstants/SECP256R1_HALF_CURVE_ORDER``.
    public var isCanonical: Bool {
        return s <= NeoConstants.SECP256R1_HALF_CURVE_ORDER
    }
    
    public init (r: BInt, s: BInt) {
        signature = ECSignature(domain: NeoConstants.SECP256R1_DOMAIN, r: r.asMagnitudeBytes(), s: s.asMagnitudeBytes())
    }
    
    public init (signature: ECSignature) {
        self.signature = signature
    }
    
}
