
import BigInt
import Foundation
import SwiftECC

public class ECKeyPair {
    
    let privateKey: ECPrivateKey
    let publicKey: ECPublicKey
    
    init(privateKey: ECPrivateKey, publicKey: ECPublicKey) {
        self.privateKey = privateKey
        self.publicKey = publicKey
    }
    
    func sign(messageHash: Bytes) -> [BInt] {
        let signature: ECDSASignature = signAndGetECDSASignature(messageHash: messageHash)
        return [signature.r, signature.s]
    }
    
    func signAndGetECDSASignature(messageHash: Bytes) -> ECDSASignature {
        return ECDSASignature(signature: privateKey.sign(msg: messageHash, deterministic: true))
    }
    
    public static func create(privateKey: ECPrivateKey) throws -> ECKeyPair {
        return try ECKeyPair(privateKey: privateKey, publicKey: Sign.publicKeyFromPrivateKey(privKey: privateKey))
    }
    
    public static func create(privateKey: BInt) throws -> ECKeyPair {
        return try create(privateKey: ECPrivateKey(key: privateKey))
    }
    
    public static func create(privateKey: Bytes) throws -> ECKeyPair {
        return try create(privateKey: ECPrivateKey(key: privateKey))
    }
    
    public static func createEcKeyPair() throws -> ECKeyPair {
        let (pub, priv) = NeoConstants.SECP256R1_DOMAIN.makeKeyPair() // Uses Secure Random
        return ECKeyPair(privateKey: priv, publicKey: pub)
    }
    
    public func exportAsWif() throws -> String {
        return try privateKey.bytes.wifFromPrivateKey()
    }
    
}

extension ECKeyPair: Equatable {
    
    public static func == (lhs: ECKeyPair, rhs: ECKeyPair) -> Bool {
        return lhs.privateKey == rhs.privateKey && lhs.publicKey == rhs.publicKey
    }
    
}

extension ECPrivateKey {
    
    var bytes: Bytes {
        return s.toBytesPadded(length: NeoConstants.PRIVATE_KEY_SIZE)
    }
    
    var int: BInt {
        return s
    }
    
    convenience init(key: BInt) throws {
        let keyString = key.asString(radix: 16, uppercase: false)
        guard keyString.count <= NeoConstants.PRIVATE_KEY_SIZE * 2 else {
            throw "Private key must fit into \(NeoConstants.PRIVATE_KEY_SIZE) bytes, but required \(keyString.count / 2) bytes."
        }
        try self.init(domain: NeoConstants.SECP256R1_DOMAIN, s: key)
    }
    
    convenience init(key: Bytes) throws {
        guard key.count == NeoConstants.PRIVATE_KEY_SIZE else {
            throw "Private key byte array must have length of \(NeoConstants.PRIVATE_KEY_SIZE) but had length \(key.count)"
        }
        try self.init(domain: NeoConstants.SECP256R1_DOMAIN, s: key.bInt)
    }
    
}

extension ECPrivateKey: Equatable {
 
    public static func ==(lhs: ECPrivateKey, rhs: ECPrivateKey) -> Bool {
        return lhs.s == rhs.s
    }

}

extension ECPublicKey {
    
    var ecPoint: ECPoint {
        return w
    }
    
    convenience init(publicKey: String) throws {
        try self.init(publicKey: publicKey.cleanedHexPrefix.bytesFromHex)
    }
    
    convenience init(publicKey: Bytes) throws {
        do {
            try self.init(domain: NeoConstants.SECP256R1_DOMAIN,
                          w: NeoConstants.SECP256R1_DOMAIN.decodePoint(publicKey))
        } catch let decodeError as SwiftECC.ECException {
            throw decodeError.description
        }
    }
    
    convenience init(publicKey: BInt) throws {
        try self.init(publicKey: publicKey.toBytesPadded(length: NeoConstants.PUBLIC_KEY_SIZE_COMPRESSED))
    }
    
    convenience init(_ point: ECPoint) throws {
        try self.init(domain: NeoConstants.SECP256R1_DOMAIN, w: point)
    }
    
    public func getEncoded(compressed: Bool) throws -> Bytes {
        return try NeoConstants.SECP256R1_DOMAIN.encodePoint(ecPoint, compressed)
    }
    
    public func getEncodedCompressedHex() throws -> String {
        return try getEncoded(compressed: true).toHexString()
    }
    
}

extension ECPublicKey: NeoSerializable {
    
    static func deserialize(_ reader: BinaryReader) -> Self? {
        if let bytes = try? reader.readBytes(NeoConstants.PUBLIC_KEY_SIZE_COMPRESSED) {
            return try? ECPublicKey(NeoConstants.SECP256R1_DOMAIN.decodePoint(bytes)) as? Self
        }
        return nil
    }
    
    func serialize(_ writer: BinaryWriter) {
        do { writer.write(try getEncoded(compressed: true)) }
        catch {}
    }
    
    var size: Int {
        return w.infinity ? 1 : NeoConstants.PUBLIC_KEY_SIZE_COMPRESSED
    }
    
    
}

extension ECPublicKey: Comparable {
    
    public static func < (lhs: ECPublicKey, rhs: ECPublicKey) -> Bool {
        return lhs.w.x != rhs.w.x ? (lhs.w.x < rhs.w.x) : (lhs.w.y < rhs.w.y)
    }
    
    public static func == (lhs: ECPublicKey, rhs: ECPublicKey) -> Bool {
        return lhs.w == rhs.w
    }
    
}
