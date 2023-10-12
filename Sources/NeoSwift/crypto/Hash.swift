
import CryptoSwift
import Foundation

public extension Bytes {
    
    /// Applies SHA-256 twice to the input and returns the result.
    ///
    /// Neo uses the name `hash256` for hashes created in this way.
    /// - Returns: The hash value as byte array
    func hash256() -> Bytes {
        return sha256().sha256()
    }
    
    /// RipeMD-160 hash function.
    /// - Returns: The hash value as hex-encoded string
    func ripemd160() -> Bytes {
        var md = RIPEMD160()
        md.update(data: Data(self))
        return md.finalize().bytes
    }
    
    /// Performs a SHA256 followed by a RIPEMD160.
    /// - Returns: The hash value as byte array
    func sha256ThenRipemd160() -> Bytes {
        return sha256().ripemd160()
    }
    
    /// Generates the HMAC SHA-512 digest for the bytes with the given key.
    /// - Parameter key: The key
    /// - Returns: The hash value for the given input
    func hmacSha512(key: Bytes) throws -> Bytes {
        return try HMAC(key: key, variant: .sha2(.sha512)).authenticate(self)
    }
    
}

public extension String {
    
    /// Applies SHA-256 twice to the input and returns the result.
    ///
    /// Neo uses the name `hash256` for hashes created in this way.
    /// - Returns: The hash value
    func hash256() -> String {
        return bytes.hash256().toHexString()
    }
    
    /// RipeMD-160 hash function.
    /// - Returns: The hash value as hex-encoded string
    func ripemd160() -> String {
        return bytes.ripemd160().toHexString()
    }
    
    /// Performs a SHA256 followed by a RIPEMD160.
    /// - Returns: The hash value
    func sha256ThenRipemd160() -> String {
        return bytes.sha256ThenRipemd160().toHexString()
    }
    
    /// Generates the HMAC SHA-512 digest for the bytes with the given key.
    /// - Parameter key: The key
    /// - Returns: The hash value for the given input
    func hmacSha512(key: String) throws -> String {
        return try bytes.hmacSha512(key: key.bytes).toHexString()
    }
    
}

