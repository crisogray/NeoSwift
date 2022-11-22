
import ASN1
import BigInt
import Foundation
import SwiftECC

public enum Sign {
    
    private static let LOWER_REAL_V: Int = 27
    
    public static func signHexMessage(message: String, keyPair: ECKeyPair) throws -> SignatureData {
        return try signMessage(message: message.bytesFromHex, keyPair: keyPair)
    }
    
    public static func signMessage(message: String, keyPair: ECKeyPair) throws -> SignatureData {
        return try signMessage(message: message.bytes, keyPair: keyPair)
    }
    
    public static func signMessage(message: Bytes, keyPair: ECKeyPair) throws -> SignatureData {
        let sig = keyPair.signAndGetECDSASignature(messageHash: message)
        var recId: Int = -1
        
        for i in 0...3 {
            if let k = try recoverFromSignature(recId: i, sig: sig, message: message.sha256()),
               k == keyPair.publicKey {
                recId = i
                break
            }
        }
        
        guard recId != -1 else { throw "Could not construct a recoverable key. This should never happen." }
        
        return SignatureData(v: Byte(recId + 27),
                             r: sig.r.toBytesPadded(length: 32),
                             s: sig.s.toBytesPadded(length: 32))
        
    }
    
    public static func recoverFromSignature(recId: Int, sig: ECDSASignature, message: Bytes) throws -> ECPublicKey? {
        guard recId >= 0 else { throw "recId must be positive" }
        guard sig.r.signum >= 0 else { throw "r must be positive" }
        guard sig.s.signum >= 0 else { throw "s must be positive" }
        guard !message.isEmpty else { throw "message cannot be empty" }
        
        let c = NeoConstants.SECP256R1_DOMAIN
        let n = c.order, i = BInt(recId / 2), x = sig.r + i * n, prime = c.p
        
        if x > prime {
            throw "Cannot have point co-ordinates larger than this as everything takes place modulo prime"
        }
        
        guard let R = try? decompressKey(xBN: x, yBit: (recId & 1) == 1),
              let infinity = try? R.multiply(n).infinity, infinity else {
            throw "If nR != point at infinity, then do another iteration of Step 1 (callers responsibility)."
        }
        let e = message.bInt, eInv = (BInt.ZERO - e).mod(n)
        let rInv = sig.r.modInverse(n), srInv = (rInv * sig.s).mod(n)
        let eInvrInv = (rInv * eInv).mod(n)
        
        return try? ECPublicKey(c.addPoints(c.g.multiply(eInvrInv), R.multiply(srInv)))
    }
    
    private static func decompressKey(xBN: BInt, yBit: Bool) throws -> ECPoint {
        var compEnc = xBN.toBytesPadded(length: 1 + (NeoConstants.SECP256R1_DOMAIN.p.bitWidth + 7) / 8)
        compEnc[0] = yBit ? 0x03 : 0x02
        return try NeoConstants.SECP256R1_DOMAIN.decodePoint(compEnc)
    }
    
    public static func signedMessageToKey(message: Bytes, signatureData: SignatureData) throws -> ECPublicKey {
        let r = signatureData.r, s = signatureData.s
        guard r.count == 32, s.count == 32 else {
            throw "\(r.count == 32 ? "s" : "r") must be 32 bytes."
        }
        
        let header: Byte = signatureData.v & 0xFF
        
        guard header >= 27 && header <= 34 else {
            throw "Header byte out of range: \(header)"
        }
        
        let sig = ECDSASignature(r: r.bInt, s: s.bInt)
        let messageHash = message.sha256()
        let recId: Int = Int(header) - 27
        
        guard let key = try recoverFromSignature(recId: recId, sig: sig, message: messageHash) else {
            throw "Could not recover public key from signature"
        }
        
        return key
    }
    
    public static func publicKeyFromPrivateKey(privKey: ECPrivateKey) throws -> ECPublicKey {
        return try ECPublicKey(publicPointFromPrivateKey(privKey: privKey))
    }
    
    public static func publicPointFromPrivateKey(privKey: ECPrivateKey) throws -> ECPoint {
        var key = privKey.int
        if key.bitWidth > NeoConstants.SECP256R1_DOMAIN.order.bitWidth {
            key = key.mod(NeoConstants.SECP256R1_DOMAIN.order)
        }
        return try NeoConstants.SECP256R1_DOMAIN.g.multiply(key)
    }
    
    public static func recoverSigningScriptHash(message: Bytes, signatureData: SignatureData) throws -> Hash160 {
        let sig = Sign.SignatureData(v: getRealV(signatureData.v), r: signatureData.r, s: signatureData.s)
        let key = try Sign.signedMessageToKey(message: message, signatureData: sig)
        return try Hash160.fromPublicKey(key.getEncoded(compressed: true))
    }
    
    public static func getRealV(_ v: Byte) -> Byte {
        if v == LOWER_REAL_V || v == LOWER_REAL_V + 1 {
            return v
        }
        let realV = LOWER_REAL_V
        let inc = Int(v) % 2 == 0 ? 1 :0
        return Byte(realV + inc)
    }
    
    public static func verifySignature(message: Bytes, sig: SignatureData, pubKey: ECPublicKey) -> Bool {
        return pubKey.verify(signature: ECDSASignature(r: sig.r.bInt, s: sig.s.bInt).signature, msg: message)
    }
    
    public class SignatureData: Equatable, Hashable {
        
        let v: Byte
        let r: Bytes
        let s: Bytes
        
        var concatenated: Bytes {
            return r + s
        }
        
        init(v: Byte, r: Bytes, s: Bytes) {
            self.v = v
            self.r = r
            self.s = s
        }
        
        convenience init(signature: Bytes) {
            self.init(v: 0, signature: signature)
        }
        
        convenience init(v: Byte, signature: Bytes) {
            self.init(v: v, r: Bytes(signature[0..<32]), s: Bytes(signature[32..<64]))
        }
        
        public static func fromByteArray(signature: Bytes) -> SignatureData {
            return fromByteArray(v: 0, signature: signature)
        }
        
        public static func fromByteArray(v: Byte, signature: Bytes) -> SignatureData {
            return SignatureData(v: v, r: Bytes(signature[0..<32]), s: Bytes(signature[32..<64]))
        }
        
        public func hash(into hasher: inout Hasher) {
            hasher.combine(v)
            hasher.combine(r)
            hasher.combine(s)
        }
        
        public static func == (lhs: SignatureData, rhs: SignatureData) -> Bool {
            return lhs.v == rhs.v && lhs.r == rhs.r && lhs.s == rhs.s
        }
        
    }
    
}
