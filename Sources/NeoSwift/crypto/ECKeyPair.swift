
import BigInt
import Foundation
import SwiftECC

public class ECKeyPair {
    
    public let privateKey: ECPrivateKey
    public let publicKey: ECPublicKey
    
    public init(privateKey: ECPrivateKey, publicKey: ECPublicKey) {
        self.privateKey = privateKey
        self.publicKey = publicKey
    }
    
    public func getAddress() throws -> String {
        return try getScriptHash().toAddress()
    }
    
    public func getScriptHash() throws -> Hash160 {
        let script = try ScriptBuilder.buildVerificationScript(publicKey.getEncoded(compressed: true))
        return try Hash160.fromScript(script)
    }
    
    public func sign(messageHash: Bytes) -> [BInt] {
        let signature: ECDSASignature = signAndGetECDSASignature(messageHash: messageHash)
        return [signature.r, signature.s]
    }
    
    public func signAndGetECDSASignature(messageHash: Bytes) -> ECDSASignature {
        return ECDSASignature(signature: privateKey.sign(msg: messageHash, deterministic: true))
    }
    
    public static func create(privateKey: ECPrivateKey) throws -> ECKeyPair {
        return try ECKeyPair(privateKey: privateKey, publicKey: Sign.publicKeyFromPrivateKey(privKey: privateKey))
    }
    
    public static func create(privateKey: BInt) throws -> ECKeyPair {
        return try create(privateKey: ECPrivateKey(privateKey))
    }
    
    public static func create(privateKey: Bytes) throws -> ECKeyPair {
        return try create(privateKey: ECPrivateKey(privateKey))
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

public extension ECPrivateKey {
    
    var bytes: Bytes {
        return s.toBytesPadded(length: NeoConstants.PRIVATE_KEY_SIZE)
    }
    
    var int: BInt {
        return s
    }
    
    convenience init(_ key: BInt) throws {
        let keyString = key.asString(radix: 16, uppercase: false)
        guard keyString.count <= NeoConstants.PRIVATE_KEY_SIZE * 2 else {
            throw "Private key must fit into \(NeoConstants.PRIVATE_KEY_SIZE) bytes, but required \(keyString.count / 2) bytes."
        }
        try self.init(domain: NeoConstants.SECP256R1_DOMAIN, s: key)
    }
    
    convenience init(_ key: Bytes) throws {
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

public extension ECPublicKey {
    
    var ecPoint: ECPoint {
        return w
    }
    
    convenience init(_ publicKey: String) throws {
        try self.init(publicKey.bytesFromHex)
    }
    
    convenience init(_ publicKey: Bytes) throws {
        do {
            try self.init(domain: NeoConstants.SECP256R1_DOMAIN,
                          w: NeoConstants.SECP256R1_DOMAIN.decodePoint(publicKey))
        } catch let decodeError as SwiftECC.ECException {
            throw decodeError.description
        }
    }
    
    convenience init(_ publicKey: BInt) throws {
        try self.init(publicKey.toBytesPadded(length: NeoConstants.PUBLIC_KEY_SIZE_COMPRESSED))
    }
    
    convenience init(_ point: ECPoint) throws {
        try self.init(domain: NeoConstants.SECP256R1_DOMAIN, w: point)
    }
    
    func getEncoded(compressed: Bool) throws -> Bytes {
        return try NeoConstants.SECP256R1_DOMAIN.encodePoint(ecPoint, compressed)
    }
    
    func getEncodedCompressedHex() throws -> String {
        return try getEncoded(compressed: true).noPrefixHex
    }
    
}

extension ECPublicKey: NeoSerializable {
    
    public var size: Int {
        return w.infinity ? 1 : NeoConstants.PUBLIC_KEY_SIZE_COMPRESSED
    }
    
    public func serialize(_ writer: BinaryWriter) {
        do { writer.write(try getEncoded(compressed: true)) }
        catch {}
    }
    
    public static func deserialize(_ reader: BinaryReader) -> Self? {
        if let bytes = try? reader.readBytes(NeoConstants.PUBLIC_KEY_SIZE_COMPRESSED) {
            return try? ECPublicKey(NeoConstants.SECP256R1_DOMAIN.decodePoint(bytes)) as? Self
        }
        return nil
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

extension ECPublicKey: Hashable {

    public func hash(into hasher: inout Hasher) {
        hasher.combine(w.x * 17)
        hasher.combine(w.y * 257)
    }
    
}
