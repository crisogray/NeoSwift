
import BigInt
import Foundation
import SwiftECC

public class ECDSASignature {
    
    let signature: ECSignature
    
    var r: BInt {
        return signature.r.bInt
    }
    
    var s: BInt {
        return signature.s.bInt
    }
    
    var isCanonical: Bool {
        return s <= NeoConstants.SECP256R1_HALF_CURVE_ORDER
    }
    
    init (r: BInt, s: BInt) {
        signature = ECSignature(domain: NeoConstants.SECP256R1_DOMAIN, r: r.asMagnitudeBytes(), s: s.asMagnitudeBytes())
    }
    
    init (signature: ECSignature) {
        self.signature = signature
    }
    
}
