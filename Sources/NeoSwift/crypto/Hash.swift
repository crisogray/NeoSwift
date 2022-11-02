
import CryptoSwift
import Foundation

extension Bytes {
    
    func hash256() -> Bytes {
        return sha256().sha256()
    }
    
    func ripemd160() -> Bytes {
        var md = RIPEMD160()
        md.update(data: Data(self))
        return md.finalize().bytes
    }
    
    func sha256ThenRipemd160() -> Bytes {
        return sha256().ripemd160()
    }
    
    func hmacSha512(key: Bytes) throws -> Bytes {
        return try HMAC(key: key, variant: .sha2(.sha512)).authenticate(self)
    }
    
}

extension String {
    
    func hash256() -> String {
        return bytes.hash256().toHexString()
    }
    
    func ripemd160() -> String {
        return bytes.ripemd160().toHexString()
    }
    
    func sha256ThenRipemd160() -> String {
        return bytes.sha256ThenRipemd160().toHexString()
    }
    
    func hmacSha512(key: String) throws -> String {
        return try bytes.hmacSha512(key: key.bytes).toHexString()
    }
    
}

