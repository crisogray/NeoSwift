
import Foundation

public extension String {
    
    var bytesFromHex: Bytes {
        return Bytes(hex: cleanedHexPrefix)
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
    
    var varSize: Int {
        bytes.varSize
    }
    
    var isValidAddress: Bool {
        guard let data = base58Decoded, data.count == 25,
              data[0] == NeoSwiftConfig.DEFAULT_ADDRESS_VERSION,
              Bytes(data.prefix(21)).hash256().prefix(4) == data.suffix(4) else {
            return false
        }
        return true
    }
    
    var isValidHex: Bool {
        return cleanedHexPrefix.count == cleanedHexPrefix.filter(\.isHexDigit).count && count % 2 == 0
    }
    
    func addressToScriptHash() throws -> Bytes {
        guard isValidAddress, let b58 = base58Decoded else {
            throw "Not a valid NEO address."
        }
        return b58[1..<21].reversed()
    }
    
}

extension String: LocalizedError {
    public var errorDescription: String? { return self }
    public var localizedDescription: String? { return self }
}
