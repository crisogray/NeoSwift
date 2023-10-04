
import BigInt

/// A Hash160 is a 20 bytes long hash created from some data by first applying SHA-256 and then RIPEMD-160. These hashes are mostly used for obtaining the script hash of a smart contract or an account.
public struct Hash160: StringDecodable, Hashable {
    
    /// The hash is stored as an unsigned integer in big-endian order.
    private let hash: Bytes
    
    /// A zero-value hash.
    public static let ZERO: Hash160 = try! Hash160("0000000000000000000000000000000000000000")
    
    /// The script hash as a hexadecimal string in big-endian order without the '0x' prefix.
    public var string: String {
        return hash.noPrefixHex
    }
    
    /// Constructs a new hash with 20 zero bytes.
    public init() {
        self.hash = Bytes(repeating: 0x00, count: NeoConstants.HASH160_SIZE)
    }
    
    /// Constructs a new hash from the given byte array. The byte array must be in big-endian order and 160 bits long.
    /// - Parameter hash: The hash in big-endian order
    public init(_ hash: Bytes) throws {
        guard hash.count == NeoConstants.HASH160_SIZE else {
            throw NeoSwiftError.illegalArgument("Hash must be \(NeoConstants.HASH160_SIZE) bytes long but was \(hash.count) bytes.")
        }
        self.hash = hash
    }
    
    /// Constructs a new hash from the given hexadecimal string. The string must be in big-endian order and 160 bits long.
    /// - Parameter hash: The hash in big-endian order
    public init(_ hash: String) throws {
        guard hash.isValidHex else {
            throw NeoSwiftError.illegalArgument("String argument is not hexadecimal.")
        }
        try self.init(hash.bytesFromHex)
    }
    
    public init(string: String) throws {
        try self.init(string)
    }
    
    /// - Returns: The script hash as a byte array in big-endian order
    public func toArray() -> Bytes {
        return hash
    }
    
    /// - Returns: The script hash as a byte array in little-endian order
    public func toLittleEndianArray() -> Bytes {
        return hash.reversed()
    }
    
    /// - Returns: The address corresponding to this script hash
    public func toAddress() -> String {
        return hash.scripthashToAddress
    }
    
    /// Creates a script hash from the given address.
    /// - Parameter address: The address from which to derive the script hash
    /// - Returns: The script hash
    public static func fromAddress(_ address: String) throws -> Hash160 {
        return try .init(address.addressToScriptHash())
    }
    
    /// Creates a script hash from the given script in byte array form.
    /// - Parameter script: The script to calculate the script hash for
    /// - Returns: The script hash
    public static func fromScript(_ script: Bytes) throws -> Hash160 {
        return try Hash160(script.sha256ThenRipemd160().reversed())
    }
    
    /// Creates a script hash from the given script in hexadecimal string form.
    /// - Parameter script: The script to calculate the script hash for
    /// - Returns: The script hash
    public static func fromScript(_ script: String) throws -> Hash160 {
        return try fromScript(script.bytesFromHex)
    }
    
    public static func fromPublicKey(_ encodedPublicKey: Bytes) throws -> Hash160 {
        return try fromScript(ScriptBuilder.buildVerificationScript(encodedPublicKey))
    }
    
    public static func fromPublicKeys(_ pubKeys: [ECPublicKey], signingThreshold: Int) throws -> Hash160 {
        return try fromScript(ScriptBuilder.buildVerificationScript(pubKeys, signingThreshold))
    }
    
}

extension Hash160: NeoSerializable {
    
    public var size: Int {
        NeoConstants.HASH160_SIZE
    }

    public func serialize(_ writer: BinaryWriter) {
        writer.write(hash.reversed())
    }
    
    public static func deserialize(_ reader: BinaryReader) throws -> Hash160 {
        return try Hash160.init(reader.readBytes(NeoConstants.HASH160_SIZE).reversed())
    }
    
}

extension Hash160: Comparable {
    
    public static func < (lhs: Hash160, rhs: Hash160) -> Bool {
        return BInt(magnitude: lhs.hash) < BInt(magnitude: rhs.hash)
    }
    
}
