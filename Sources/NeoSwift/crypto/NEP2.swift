
import CryptoSwift
import Foundation
import Scrypt

public class NEP2 {
    
    public static let DKLEN: Int = 64
    public static let NEP2_PRIVATE_KEY_LENGTH: Int = 39
    public static let NEP2_PREFIX_1: Byte = 0x01
    public static let NEP2_PREFIX_2: Byte = 0x42
    public static let NEP2_FLAGBYTE: Byte = 0xE0
    
    public static func decrypt(_ password: String, _ nep2String: String, _ params: ScryptParams = .DEFAULT) throws -> ECKeyPair {
        guard let nep2Data = nep2String.base58CheckDecoded, nep2Data.count == NEP2_PRIVATE_KEY_LENGTH,
              nep2Data[0] == NEP2_PREFIX_1, nep2Data[1] == NEP2_PREFIX_2, nep2Data[2] == NEP2_FLAGBYTE else {
            throw "Not valid NEP2 prefix."
        }
        let addresshash = Bytes(nep2Data[3..<7]), encrypted = Bytes(nep2Data[7..<39])
        let derivedKey = try generateDerivedScryptKey(password.bytes, addresshash, params)
        let decryptedBytes = try performCypher(encrypted, Bytes(derivedKey.suffix(32)), decrypt: true)
        let plainPrivateKey = try Bytes(derivedKey.prefix(32)) ^ decryptedBytes
        let keyPair = try ECKeyPair.create(privateKey: plainPrivateKey)
        let newAddressHash = try getAddressHash(keyPair)
        guard newAddressHash == addresshash else {
            throw "Calculated address hash does not match the one in the provided encrypted address."
        }
        return keyPair
    }
    
    public static func encrypt(_ password: String, _ ecKeyPair: ECKeyPair, _ n: Int, _ r: Int, _ p: Int) throws -> String {
        return try encrypt(password, ecKeyPair, .init(n, r, p))
    }
    
    public static func encrypt(_ password: String, _ ecKeyPair: ECKeyPair, _ params: ScryptParams = .DEFAULT) throws -> String {
        let addressHash = try getAddressHash(ecKeyPair), privateKey = ecKeyPair.privateKey.bytes
        let derivedKey = try generateDerivedScryptKey(password.bytes, addressHash, params)
        let derivedHalf1 = Bytes(derivedKey.prefix(32)), derivedHalf2 = Bytes(derivedKey.suffix(32))
        let encryptedHalf1 = try performCypher(
            xorPrivateKeyAndDerivedHalf(privateKey, derivedHalf1, 0..<16),
            derivedHalf2, decrypt: false)
        let encryptedHalf2 = try performCypher(
            xorPrivateKeyAndDerivedHalf(privateKey, derivedHalf1, 16..<32),
            derivedHalf2, decrypt: false)
        return ([NEP2_PREFIX_1, NEP2_PREFIX_2, NEP2_FLAGBYTE] + addressHash + encryptedHalf1 + encryptedHalf2).base58CheckEncoded
    }
    
    private static func xorPrivateKeyAndDerivedHalf(_ privateKey: Bytes, _ half: Bytes, _ range: Range<Int>) throws -> Bytes {
        return try Bytes(privateKey[range]) ^ Bytes(half[range])
    }
    
    private static func performCypher(_ data: Bytes, _ key: Bytes, decrypt: Bool) throws -> Bytes {
        let aes = try AES(key: key, blockMode: ECB(), padding: .noPadding)
        return try decrypt ? aes.decrypt(data) : aes.encrypt(data)
    }
    
    private static func generateDerivedScryptKey(_ password: Bytes, _ salt: Bytes, _ scryptParams: ScryptParams) throws -> Bytes {
        return try scrypt(password: password,
                          salt: salt, length: DKLEN,
                          N: UInt64(scryptParams.n),
                          r: UInt32(scryptParams.r),
                          p: UInt32(scryptParams.p))
    }
    
    private static func getAddressHash(_ keyPair: ECKeyPair) throws -> Bytes {
        return try .init(keyPair.getAddress().hash256().bytesFromHex.prefix(4))
    }
    
}
