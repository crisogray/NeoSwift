
import BigInt
import Foundation
import SwiftECC

/// Elliptic Curve SECP-256r1 generated key pair.
public class ECKeyPair {
    
    /// The private key of this EC key pair.
    public let privateKey: ECPrivateKey
    
    /// The public key of this EC key pair.
    public let publicKey: ECPublicKey
    
    public init(privateKey: ECPrivateKey, publicKey: ECPublicKey) {
        self.privateKey = privateKey
        self.publicKey = publicKey
    }
    
    /// Constructs the NEO address from this key pair's public key.
    ///
    /// The address is constructed ad hoc each time this method is called.
    /// - Returns: The NEO address of the public key
    public func getAddress() throws -> String {
        return try getScriptHash().toAddress()
    }
    
    /// Constructs the script hash from this key pairs public key.
    ///
    /// The script hash is constructed ad hoc each time this method is called.
    /// - Returns: Tthe script hash of the public key
    public func getScriptHash() throws -> Hash160 {
        let script = try ScriptBuilder.buildVerificationScript(publicKey.getEncoded(compressed: true))
        return try Hash160.fromScript(script)
    }
    
    /// Sign a hash with the private key of this key pair.
    /// - Parameter messageHash: The hash to sign
    /// - Returns: A raw byte array with the signature
    public func sign(messageHash: Bytes) -> [BInt] {
        let signature: ECDSASignature = signAndGetECDSASignature(messageHash: messageHash)
        return [signature.r, signature.s]
    }
    
    /// Sign a hash with the private key of this key pair.
    /// - Parameter messageHash: The hash to sign
    /// - Returns: An ``ECDSASignature`` of the hash
    public func signAndGetECDSASignature(messageHash: Bytes) -> ECDSASignature {
        return ECDSASignature(signature: privateKey.sign(msg: messageHash, deterministic: true))
    }
    
    /// Creates an EC key pair from a private key.
    /// - Parameter privateKey: The private key
    /// - Returns: The EC key pair
    public static func create(privateKey: ECPrivateKey) throws -> ECKeyPair {
        return try ECKeyPair(privateKey: privateKey, publicKey: Sign.publicKeyFromPrivateKey(privKey: privateKey))
    }
    
    /// Creates a secp256r1 EC key pair from the private key.
    /// - Parameter privateKey: The private key
    /// - Returns: The EC key pair
    public static func create(privateKey: BInt) throws -> ECKeyPair {
        return try create(privateKey: ECPrivateKey(privateKey))
    }
    
    /// Creates a secp256r1 EC key pair from the private key.
    /// - Parameter privateKey: The private key
    /// - Returns: The EC key pair
    public static func create(privateKey: Bytes) throws -> ECKeyPair {
        return try create(privateKey: ECPrivateKey(privateKey))
    }
    
    /// Create a fresh secp256r1 EC key pair.
    /// - Returns: The created EC key pair
    public static func createEcKeyPair() throws -> ECKeyPair {
        let (pub, priv) = NeoConstants.SECP256R1_DOMAIN.makeKeyPair() // Uses Secure Random
        return ECKeyPair(privateKey: priv, publicKey: pub)
    }
    
    /// - Returns: The WIF of this ECKeyPair.
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
    
    /// This private key as a byte array in big-endian order (not in two's complement).
    var bytes: Bytes {
        return (try? s.toBytesPadded(length: NeoConstants.PRIVATE_KEY_SIZE)) ?? []
    }
    
    /// This private key as an integer.
    var int: BInt {
        return s
    }
    
    /// Creates a ECPrivateKey instance from the given private key.
    /// - Parameter key: The private key
    convenience init(_ key: BInt) throws {
        let keyString = key.asString(radix: 16, uppercase: false)
        guard keyString.count <= NeoConstants.PRIVATE_KEY_SIZE * 2 else {
            throw NeoSwiftError.illegalArgument("Private key must fit into \(NeoConstants.PRIVATE_KEY_SIZE) bytes, but required \(keyString.count / 2) bytes.")
        }
        try self.init(domain: NeoConstants.SECP256R1_DOMAIN, s: key)
    }
    
    /// Creates a ECPrivateKey instance from the given private key.
    /// The bytes are interpreted as a positive integer (not two's complement) in big-endian ordering.
    /// - Parameter key: The key's bytes
    convenience init(_ key: Bytes) throws {
        guard key.count == NeoConstants.PRIVATE_KEY_SIZE else {
            throw NeoSwiftError.illegalArgument("Private key byte array must have length of \(NeoConstants.PRIVATE_KEY_SIZE) but had length \(key.count)")
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
    
    /// The EC point of this public key
    var ecPoint: ECPoint {
        return w
    }
    
    /// Creates a new instance from the given encoded public key in hex format. The public key must be encoded as defined in section 2.3.3 of [SEC1](http://www.secg.org/sec1-v2.pdf).
    /// It can be in compressed or uncompressed format.
    ///
    /// Assumes the public key EC point is from the secp256r1 named curve.
    /// - Parameter publicKey: The public key in hex format
    convenience init(_ publicKey: String) throws {
        try self.init(publicKey.bytesFromHex)
    }
    
    /// Creates a new instance from the given encoded public key. The public key must be encoded as defined in section 2.3.3 of [SEC1](http://www.secg.org/sec1-v2.pdf).
    /// It can be in compressed or uncompressed format.
    ///
    /// Assumes the public key EC point is from the secp256r1 named curve.
    /// - Parameter publicKey: The public key
    convenience init(_ publicKey: Bytes) throws {
        try self.init(domain: NeoConstants.SECP256R1_DOMAIN,
                      w: NeoConstants.SECP256R1_DOMAIN.decodePoint(publicKey))
    }
    
    /// Creates a new instance from the given encoded public key. The public key must be encoded as defined in section 2.3.3 of [SEC1](http://www.secg.org/sec1-v2.pdf).
    /// It can be in compressed or uncompressed format.
    ///
    /// - Parameter publicKey: The public key
    convenience init(_ publicKey: BInt) throws {
        try self.init(publicKey.toBytesPadded(length: NeoConstants.PUBLIC_KEY_SIZE_COMPRESSED))
    }
    
    /// Creates a new ``ECPublicKey`` based on an EC point (``ECPoint``).
    /// - Parameter publicKey: The EC point (x,y) to construct the public key
    convenience init(_ point: ECPoint) throws {
        try self.init(domain: NeoConstants.SECP256R1_DOMAIN, w: point)
    }
    
    /// Gets this public key's elliptic curve point encoded as defined in section 2.3.3 of [SEC1]("http://www.secg.org/sec1-v2.pdf").
    /// - Parameter compressed: If the EC point should be encoded in compressed or uncompressed format
    /// - Returns: The encoded public key
    func getEncoded(compressed: Bool) throws -> Bytes {
        return try NeoConstants.SECP256R1_DOMAIN.encodePoint(ecPoint, compressed)
    }
    
    /// Gets this public key's elliptic curve point encoded as defined in section 2.3.3 of [SEC1]("http://www.secg.org/sec1-v2.pdf") in compressed format as hexadecimal.
    /// - Returns: The encoded public key in compressed format as hexadecimal without a prefix
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
    
    /// Deserializes an EC point, which is assumed to be on the secp256r1 curve.
    /// - Parameter reader: The binary reader to read bytes from
    /// - Returns: The deserialized public key
    public static func deserialize(_ reader: BinaryReader) throws -> Self {
        let bytes = try reader.readBytes(NeoConstants.PUBLIC_KEY_SIZE_COMPRESSED)
        return try ECPublicKey(NeoConstants.SECP256R1_DOMAIN.decodePoint(bytes)) as! Self
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
