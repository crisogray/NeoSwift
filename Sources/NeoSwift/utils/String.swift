
import Foundation

extension String {
    
    var bytesFromHex: Bytes {
        return Bytes(hex: self)
    }
    
    var cleanedHexPrefix: String {
        return starts(with: "0x") ? String(dropFirst(2)) : self
    }
    
    var base64Decoded: Bytes {
        return Data(base64Encoded: self)?.bytes ?? []
    }
    
    var base64Encoded: String {
        return bytesFromHex.base64Encoded
    }
    
    var base58Decoded: Bytes? {
        return Base58.decode(self)
    }
    
    var base58CheckDecoded: Bytes? {
        return Base58.base58CheckDecode(self)
    }
    
    var base58Encoded: String {
        return bytes.base58Encoded
    }
    
}

extension String: LocalizedError {
    public var errorDescription: String? { return self }
    public var localizedDescription: String? { return self }
}
