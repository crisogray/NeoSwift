
import BigInt
import Foundation

public class Bip32ECKeyPair: ECKeyPair {
    
    public static let HARDENED_BIT: Int32 = -2147483648
    public let parentHasPrivate: Bool
    public let childNumber: Int32
    public let depth: Int32
    public let chainCode: Bytes
    public let parentFingerprint: Int32
    public let publicKeyPoint: ECPoint
    public let identifier: Bytes
    public var fingerprint: Int32
    
    public init(privateKey: ECPrivateKey, publicKey: ECPublicKey, childNumber: Int32, chainCode: Bytes, parent: Bip32ECKeyPair?) throws {
        self.parentHasPrivate = parent != nil
        self.childNumber = childNumber
        self.depth = parent != nil ? parent!.depth + 1 : 0
        self.chainCode = chainCode
        self.parentFingerprint = parent != nil ? parent!.fingerprint : 0
        let pKP = try Sign.publicPointFromPrivateKey(privKey: privateKey)
        let id = try pKP.getEncoded(true).sha256ThenRipemd160()
        self.publicKeyPoint = pKP
        self.identifier = id
        let a = Int32(id[3] & 0xFF), b = Int32(id[2] & 0xFF) << 8
        let c = Int32(id[1] & 0xFF) << 16, d = Int32(id[0] & 0xFF) << 24
        fingerprint = a | b | c | d
        super.init(privateKey: privateKey, publicKey: publicKey)
    }

    public static func create(privateKey: ECPrivateKey, chainCode: Bytes) throws -> Bip32ECKeyPair {
        return try create(privateKey: privateKey.int, chainCode: chainCode)
    }
    
    public static func create(privateKey: BInt, chainCode: Bytes) throws -> Bip32ECKeyPair {
        let pK = try ECPrivateKey(privateKey)
        return try Bip32ECKeyPair(privateKey: pK,
                                  publicKey: Sign.publicKeyFromPrivateKey(privKey: pK),
                                  childNumber: 0, chainCode: chainCode, parent: nil)
    }
    
    public static func create(privateKey: Bytes, chainCode: Bytes) throws -> Bip32ECKeyPair {
        return try create(privateKey: privateKey.bInt, chainCode: chainCode)
    }
    
    public static func generateKeyPair(seed: Bytes) throws -> Bip32ECKeyPair {
        let b = "Bitcoin seed".bytes
        let i = try seed.hmacSha512(key: b)
        return try create(privateKey: Bytes(i[0..<32]), chainCode: Bytes(i[32..<64]))
    }
    
    public static func deriveKeyPair(master: Bip32ECKeyPair, path: [Int32]) throws -> Bip32ECKeyPair {
        var currentKeyPair = master
        for childNumber in path {
            currentKeyPair = try currentKeyPair.deriveChildKey(childNumber)
        }
        return currentKeyPair
    }
    
    private func deriveChildKey(_ childNumber: Int32) throws -> Bip32ECKeyPair {
        var data: Bytes = []
        if Self.isHardened(childNumber) {
            data = try privateKey.int.toBytesPadded(length: 33)
        } else  {
            data = try publicKeyPoint.getEncoded(true)
        }
        data.append(contentsOf: childNumber.bytes)
        
        let i = try data.hmacSha512(key: chainCode)
        let il = Bytes(i[0..<32])
        let chainCode = Bytes(i[32..<64])
        let privateKey = try ECPrivateKey((self.privateKey.int + il.bInt)
            .mod(NeoConstants.SECP256R1_DOMAIN.order))
        let publicKey = try Sign.publicKeyFromPrivateKey(privKey: privateKey)
        return try Bip32ECKeyPair(privateKey: privateKey, publicKey: publicKey,
                              childNumber: childNumber, chainCode: chainCode, parent: self)
    }
    
    public static func isHardened(_ a: Int32) -> Bool {
        return (a & HARDENED_BIT) != 0
    }
    
}
