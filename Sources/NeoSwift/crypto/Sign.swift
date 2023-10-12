
import ASN1
import BigInt
import Foundation
import SwiftECC

public enum Sign {
    
    private static let LOWER_REAL_V: Int = 27
    
    /// Signs the hash SHA256 of the hexadecimal message with the private key of the provided ``ECKeyPair``.
    /// - Parameters:
    ///   - message: The message to sign in hexadecimal format
    ///   - keyPair: The key pair that holds the private key that is used to sign the message
    /// - Returns: The signature data
    public static func signHexMessage(_ message: String, _ keyPair: ECKeyPair) throws -> SignatureData {
        return try signMessage(message.bytesFromHex, keyPair)
    }
    
    /// Signs the hash SHA256 of the message's UTF-8 bytes with the private key of the provided ``ECKeyPair``.
    /// - Parameters:
    ///   - message: The message to sign
    ///   - keyPair: The key pair that holds the private key that is used to sign the message
    /// - Returns: The signature data
    public static func signMessage(_ message: String, _ keyPair: ECKeyPair) throws -> SignatureData {
        return try signMessage(message.bytes, keyPair)
    }
    
    /// Signs the hash SHA256 of the message with the private key of the provided ``ECKeyPair``.
    /// - Parameters:
    ///   - message: The message to sign
    ///   - keyPair: The key pair that holds the private key that is used to sign the message
    /// - Returns: The signature data
    public static func signMessage(_ message: Bytes, _ keyPair: ECKeyPair) throws -> SignatureData {
        let sig = keyPair.signAndGetECDSASignature(messageHash: message)
        var recId: Int = -1
        
        for i in 0...3 {
            if let k = try recoverFromSignature(recId: i, sig: sig, message: message.sha256()),
               k == keyPair.publicKey {
                recId = i
                break
            }
        }
        
        guard recId != -1 else { throw NeoSwiftError.runtime("Could not construct a recoverable key. This should never happen.") }
        
        return try SignatureData(v: Byte(recId + 27),
                             r: sig.r.toBytesPadded(length: 32),
                             s: sig.s.toBytesPadded(length: 32))
        
    }
    
    /// Given the components of a signature and a selector value, recover and return the public key that generated the signature according to the algorithm in SEC1v2 section 4.1.6.
    ///
    /// The recId is an index from 0 to 3 which indicates which of the 4 possible keys is the correct one.
    /// Because the key recovery operation yields multiple potential keys, the correct key must either be stored alongside the signature,
    /// or you must be willing to try each recId in turn until you find one that outputs the key you are expecting.
    ///
    /// If this method returns nil it means recovery was not possible and recId should be iterated.
    ///
    /// Given the above two points, a correct usage of this method is inside a for loop from 0 to 3,
    /// and if the output  is nil OR a key that is not the one you expect, you try again with the next recId.
    /// - Parameters:
    ///   - recId: Which possible key to recover
    ///   - sig: The R and S components of the signature, wrapped
    ///   - message: The hash of the data that was signed
    /// - Returns: An ECKey containing only the public part, or nil if recovery wasn't possible
    public static func recoverFromSignature(recId: Int, sig: ECDSASignature, message: Bytes) throws -> ECPublicKey? {
        guard recId >= 0 else { throw NeoSwiftError.runtime("recId must be positive") }
        guard sig.r.signum >= 0 else { throw NeoSwiftError.runtime("r must be positive") }
        guard sig.s.signum >= 0 else { throw NeoSwiftError.runtime("s must be positive") }
        guard !message.isEmpty else { throw NeoSwiftError.runtime("message cannot be empty") }
        
        let c = NeoConstants.SECP256R1_DOMAIN
        let n = c.order, i = BInt(recId / 2), x = sig.r + i * n, prime = c.p
        
        guard x <= prime,
              let R = try? decompressKey(xBN: x, yBit: (recId & 1) == 1),
              let infinity = try? R.multiply(n).infinity, infinity else {
            return nil
        }
        let e = message.bInt, eInv = (BInt.ZERO - e).mod(n)
        let rInv = sig.r.modInverse(n), srInv = (rInv * sig.s).mod(n)
        let eInvrInv = (rInv * eInv).mod(n)
        
        return try? ECPublicKey(c.addPoints(c.g.multiply(eInvrInv), R.multiply(srInv)))
    }
    
    /// Decompress a compressed public key (x co-ord and low-bit of y co-ord).
    /// Based on: [RFC5480](https://tools.ietf.org/html/rfc5480#section-2.2)
    private static func decompressKey(xBN: BInt, yBit: Bool) throws -> ECPoint {
        var compEnc = try xBN.toBytesPadded(length: 1 + (NeoConstants.SECP256R1_DOMAIN.p.bitWidth + 7) / 8)
        compEnc[0] = yBit ? 0x03 : 0x02
        return try NeoConstants.SECP256R1_DOMAIN.decodePoint(compEnc)
    }
    
    /// Given an arbitrary piece of text and an NEO message signature encoded in bytes, returns the public key that was used to sign it.
    /// This can then be compared to the expected public key to determine if the signature was correct.
    /// - Parameters:
    ///   - message: The encoded message
    ///   - signatureData: The message signature components
    /// - Returns: The public key used to sign the message
    public static func signedMessageToKey(message: Bytes, signatureData: SignatureData) throws -> ECPublicKey {
        let r = signatureData.r, s = signatureData.s
        guard r.count == 32, s.count == 32 else {
            throw NeoSwiftError.runtime("\(r.count == 32 ? "s" : "r") must be 32 bytes.")
        }
        
        let header: Byte = signatureData.v & 0xFF
        
        guard header >= 27 && header <= 34 else {
            throw SignError.headerOutOfRange(header)
        }
        
        let sig = ECDSASignature(r: r.bInt, s: s.bInt)
        let messageHash = message.sha256()
        let recId: Int = Int(header) - 27
        
        guard let key = try recoverFromSignature(recId: recId, sig: sig, message: messageHash) else {
            throw SignError.recoverFailed
        }
        
        return key
    }
    
    /// Returns public key from the given private key.
    /// - Parameter privKey: The private key to derive the public key from
    /// - Returns: The public key
    public static func publicKeyFromPrivateKey(privKey: ECPrivateKey) throws -> ECPublicKey {
        return try ECPublicKey(publicPointFromPrivateKey(privKey: privKey))
    }
    
    /// Returns public key point from the given private key.
    /// - Parameter privKey: The private key to derive the public key point from
    /// - Returns: The ECPoint object representation of the public key based on the given private key
    public static func publicPointFromPrivateKey(privKey: ECPrivateKey) throws -> ECPoint {
        var key = privKey.int
        if key.bitWidth > NeoConstants.SECP256R1_DOMAIN.order.bitWidth {
            key = key.mod(NeoConstants.SECP256R1_DOMAIN.order)
        }
        return try NeoConstants.SECP256R1_DOMAIN.g.multiply(key)
    }
    
    /// Recovers the signer's script hash that created the given signature on the given message.
    ///
    /// If the message is a Neo transaction, then make sure that it was serialized without the verification and invocation script attached (i.e. without the signature).
    /// - Parameters:
    ///   - message: The message for which the signature was created
    ///   - signatureData: The signature
    /// - Returns: The signer's script hash that produced the signature data from the transaction
    public static func recoverSigningScriptHash(message: Bytes, signatureData: SignatureData) throws -> Hash160 {
        let sig = Sign.SignatureData(v: getRealV(signatureData.v), r: signatureData.r, s: signatureData.s)
        let key = try Sign.signedMessageToKey(message: message, signatureData: sig)
        return try Hash160.fromPublicKey(key.getEncoded(compressed: true))
    }
    
    private static func getRealV(_ v: Byte) -> Byte {
        if v == LOWER_REAL_V || v == LOWER_REAL_V + 1 {
            return v
        }
        let realV = LOWER_REAL_V
        let inc = Int(v) % 2 == 0 ? 1 :0
        return Byte(realV + inc)
    }
    
    /// Verifies the that the signature is appropriate for the given message and public key.
    /// - Parameters:
    ///   - message: The message
    ///   - sig: The signature to verify
    ///   - pubKey: The public key
    /// - Returns: true if the verification was successful. Otherwise `false`
    public static func verifySignature(message: Bytes, sig: SignatureData, pubKey: ECPublicKey) -> Bool {
        return pubKey.verify(signature: ECDSASignature(r: sig.r.bInt, s: sig.s.bInt).signature, msg: message)
    }
    
    public class SignatureData: Hashable {
        
        public let v: Byte
        public let r: Bytes
        public let s: Bytes
        
        public var concatenated: Bytes {
            return r + s
        }
        
        public init(v: Byte, r: Bytes, s: Bytes) {
            self.v = v
            self.r = r
            self.s = s
        }
        
        public convenience init(signature: Bytes) {
            self.init(v: 0, signature: signature)
        }
        
        public convenience init(v: Byte, signature: Bytes) {
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
