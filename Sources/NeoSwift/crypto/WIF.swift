
import Foundation

public extension Bytes {
    
    func wifFromPrivateKey() throws -> String {
        guard count == NeoConstants.PRIVATE_KEY_SIZE else {
            throw "Given key is not of expected length (\(NeoConstants.PRIVATE_KEY_SIZE) bytes)."
        }
        let extendedKey: Bytes = 0x80 + self + 0x01
        let hash = extendedKey.hash256()
        let checksum = Bytes(hash.prefix(upTo: 4))
        return Base58.encode(extendedKey + checksum)
    }
    
}

public extension String {
    
    func privateKeyFromWIF() throws -> Bytes {
        guard let data = base58Decoded, data.count == 38, data.first == 0x80, data[33] == 0x01 else {
            throw "Incorrect WIF format."
        }
        let checksum = data.dropLast(4).hash256()
        guard checksum.prefix(upTo: 4) == data.suffix(4) else {
            throw "Incorrect WIF checksum."
        }
        return Bytes(data[1...32])
    }
    
}


