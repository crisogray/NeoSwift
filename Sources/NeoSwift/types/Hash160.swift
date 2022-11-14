
import Foundation
import BigInt

public class Hash160: NeoSerializable, Hashable, Comparable {
    
    private let hash: Bytes
    public var size: Int = NeoConstants.HASH160_SIZE
    
    public static let ZERO: Hash160 = try! Hash160("0000000000000000000000000000000000000000")
    
    public var string: String {
        return hash.toHexString().cleanedHexPrefix
    }
    
    init() {
        self.hash = Bytes(repeating: 0x00, count: NeoConstants.HASH160_SIZE)
    }
    
    init(_ hash: Bytes) throws {
        guard hash.count == NeoConstants.HASH160_SIZE else {
            throw "Hash must be \(NeoConstants.HASH160_SIZE) bytes long but was \(hash.count) bytes."
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
        return try? Hash160.init(reader.readBytes(NeoConstants.HASH160_SIZE).reversed()) as? Self
    }
    
    public func toArray() -> Bytes {
        return hash
    }
    
    public func toLittleEndianArray() -> Bytes {
        return hash.reversed()
    }
    
    public func toAddress() -> String {
        return hash.scripthashToAddress
    }
    
    public static func fromAddress(_ address: String) throws -> Hash160 {
        return try .init(address.addressToScriptHash())
    }
        
    public static func fromScript(script: Bytes) throws -> Hash160 {
        return try Hash160(script.sha256ThenRipemd160().reversed())
    }
    
    // TODO: From public keys
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(hash)
    }
    
    public static func == (lhs: Hash160, rhs: Hash160) -> Bool {
        return lhs.hash == rhs.hash
    }
    
    public static func < (lhs: Hash160, rhs: Hash160) -> Bool {
        return BInt(magnitude: lhs.hash) < BInt(magnitude: rhs.hash)
    }
    
}
