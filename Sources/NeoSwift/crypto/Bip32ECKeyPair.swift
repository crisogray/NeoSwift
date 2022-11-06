//
//  Bip32ECKeyPair.swift
//  
//
//  Created by Ben Gray on 02/11/2022.
//

import BigInt
import Foundation
import SwiftECC

public class Bip32ECKeyPair: ECKeyPair {
    
    public static let HARDENED_BIT: Int = -2147483648
    public let parentHasPrivate: Bool
    public let childNumber: Int
    public let depth: Int
    public let chainCode: Bytes
    public var parentFingerprint: Int
    public var publicKeyPoint: ECPoint? {
        return try? Sign.publicPointFromPrivateKey(privKey: privateKey)
    }
    public var identifier: Bytes? {
        let id = try? publicKeyPoint?.getEncoded(true).sha256ThenRipemd160()
        return id
    }
    public var fingerprint: Int? {
        guard let id = identifier else {
            return nil
        }
        let a = Int(id[3] & 0xFF), b = Int(id[2] & 0xFF) << 8
        let c = Int(id[1] & 0xFF) << 16, d = Int(id[0] & 0xFF) << 24
        return a | b | c | d
    }
    
    init(privateKey: ECPrivateKey, publicKey: ECPublicKey, childNumber: Int, chainCode: Bytes, parent: Bip32ECKeyPair?) {
        self.parentHasPrivate = parent != nil
        self.childNumber = childNumber
        self.depth = parent != nil ? parent!.depth + 1 : 0
        self.chainCode = chainCode
        self.parentFingerprint = parent != nil ? parent!.fingerprint ?? 0 : 0
        super.init(privateKey: privateKey, publicKey: publicKey)
    }

    public static func create(privateKey: ECPrivateKey, chainCode: Bytes) throws -> Bip32ECKeyPair {
        return try create(privateKey: privateKey.int, chainCode: chainCode)
    }
    
    public static func create(privateKey: BInt, chainCode: Bytes) throws -> Bip32ECKeyPair {
        let pK = try ECPrivateKey(key: privateKey)
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
    
    public static func deriveKeyPair(master: Bip32ECKeyPair, path: [Int]) throws -> Bip32ECKeyPair {
        var currentKeyPair = master
        for childNumber in path {
            currentKeyPair = try currentKeyPair.deriveChildKey(childNumber)
        }
        return currentKeyPair
    }
    
    private func deriveChildKey(_ childNumber: Int) throws -> Bip32ECKeyPair {
        var data: Bytes = []
        if Self.isHardened(childNumber) {
            data = privateKey.int.toBytesPadded(length: 33)
        } else if let publicKey = try publicKeyPoint?.getEncoded(true) {
            data = publicKey
        }
        data.append(contentsOf: childNumber.bytes)
        
        let i = try data.hmacSha512(key: chainCode)
        let il = Bytes(i[0..<32])
        let chainCode = Bytes(i[32..<64])
        let privateKey = try ECPrivateKey(key: (self.privateKey.int + il.bInt)
            .mod(NeoConstants.SECP256R1_DOMAIN.order))
        let publicKey = try Sign.publicKeyFromPrivateKey(privKey: privateKey)
        return Bip32ECKeyPair(privateKey: privateKey, publicKey: publicKey,
                              childNumber: childNumber, chainCode: chainCode, parent: self)
    }
    
    public static func isHardened(_ a: Int) -> Bool {
        return (a & HARDENED_BIT) != 0
    }
    
}
