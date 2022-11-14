
import Foundation
import BigInt

public class Hash256: NeoSerializable, Hashable, Comparable {
    
    private let hash: Bytes
    public var size: Int = NeoConstants.HASH256_SIZE
    
    public static let ZERO: Hash256 = try! Hash256("0000000000000000000000000000000000000000000000000000000000000000")
    
    public var string: String {
        return hash.toHexString().cleanedHexPrefix
    }
    
    init() {
        self.hash = Bytes(repeating: 0x00, count: NeoConstants.HASH256_SIZE)
    }
    
    init(_ hash: Bytes) throws {
        guard hash.count == NeoConstants.HASH256_SIZE else {
            throw "Hash must be \(NeoConstants.HASH256_SIZE) bytes long but was \(hash.count) bytes."
        }
        self.hash = hash
    }
    
    init (_ hash: String) throws {
        guard hash.isValidHex else {
            throw "String argument is not hexadecimal."
        }
        self.hash = hash.bytesFromHex
    }

    public func serialize(_ writer: BinaryWriter) {
        writer.write(hash.reversed())
    }
    
    public static func deserialize(_ reader: BinaryReader) -> Self? {
        return try? Hash256.init(reader.readBytes(NeoConstants.HASH256_SIZE).reversed()) as? Self
    }
    
    public func toArray() -> Bytes {
        return hash
    }
    
    public func toLittleEndianArray() -> Bytes {
        return hash.reversed()
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(hash)
    }
    
    public static func == (lhs: Hash256, rhs: Hash256) -> Bool {
        return lhs.hash == rhs.hash
    }
    
    public static func < (lhs: Hash256, rhs: Hash256) -> Bool {
        return BInt(magnitude: lhs.hash) < BInt(magnitude: rhs.hash)
    }
    
}
