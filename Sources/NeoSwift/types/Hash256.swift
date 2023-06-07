
import BigInt

public struct Hash256: StringDecodable, Hashable {
    
    private let hash: Bytes
    
    public static let ZERO: Hash256 = try! Hash256("0000000000000000000000000000000000000000000000000000000000000000")
    
    public var string: String {
        return hash.noPrefixHex
    }
    
    public init() {
        self.hash = Bytes(repeating: 0x00, count: NeoConstants.HASH256_SIZE)
    }
    
    public init(_ hash: Bytes) throws {
        guard hash.count == NeoConstants.HASH256_SIZE else {
            throw "Hash must be \(NeoConstants.HASH256_SIZE) bytes long but was \(hash.count) bytes."
        }
        self.hash = hash
    }
    
    public init(_ hash: String) throws {
        guard hash.isValidHex else {
            throw "String argument is not hexadecimal."
        }
        try self.init(hash.bytesFromHex)
    }
    
    public init(string: String) throws {
        try self.init(string)
    }
    
    public func toArray() -> Bytes {
        return hash
    }
    
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
