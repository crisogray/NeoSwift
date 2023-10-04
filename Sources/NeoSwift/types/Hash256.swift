
import BigInt

/// A Hash256 is a 32 bytes long hash created from some data by applying SHA-256. These hashes are mostly used for obtaining transaction or block hashes.
public struct Hash256: StringDecodable, Hashable {
    
    /// The hash is stored as an unsigned integer in big-endian order.
    private let hash: Bytes
    
    /// A zero address hash.
    public static let ZERO: Hash256 = try! Hash256("0000000000000000000000000000000000000000000000000000000000000000")
    
    /// The hash as hexadecimal string in big-endian order without the '0x' prefix.
    public var string: String {
        return hash.noPrefixHex
    }
    
    /// Constructs a new hash with 32 zero bytes.
    public init() {
        self.hash = Bytes(repeating: 0x00, count: NeoConstants.HASH256_SIZE)
    }
    
    ///  Constructs a new hash from the given byte array. The byte array must be in big-endian order and 256 bits long.
    /// - Parameter hash: The hash in big-endian order
    public init(_ hash: Bytes) throws {
        guard hash.count == NeoConstants.HASH256_SIZE else {
            throw NeoSwiftError.illegalArgument("Hash must be \(NeoConstants.HASH256_SIZE) bytes long but was \(hash.count) bytes.")
        }
        self.hash = hash
    }
    
    /// Constructs a new hash from the given hexadecimal string. The string must be in big-endian order and 256 bits long.
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
    
    /// - Returns: The hash as a byte array in big-endian order
    public func toArray() -> Bytes {
        return hash
    }
    
    /// - Returns: The hash as a byte array in little-endian order
    public func toLittleEndianArray() -> Bytes {
        return hash.reversed()
    }
        
}

extension Hash256: NeoSerializable {
    
    public var size: Int {
        return NeoConstants.HASH256_SIZE
    }

    public func serialize(_ writer: BinaryWriter) {
        writer.write(hash.reversed())
    }
    
    public static func deserialize(_ reader: BinaryReader) throws -> Hash256 {
        return try Hash256.init(reader.readBytes(NeoConstants.HASH256_SIZE).reversed())
    }
    
}

extension Hash256: Comparable {
    
    public static func < (lhs: Hash256, rhs: Hash256) -> Bool {
        return BInt(magnitude: lhs.hash) < BInt(magnitude: rhs.hash)
    }
    
}
