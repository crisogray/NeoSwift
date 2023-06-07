
import BigInt

public struct Hash160: StringDecodable, Hashable {
    
    private let hash: Bytes
    
    public static let ZERO: Hash160 = try! Hash160("0000000000000000000000000000000000000000")
    
    public var string: String {
        return hash.noPrefixHex
    }
    
    public init() {
        self.hash = Bytes(repeating: 0x00, count: NeoConstants.HASH160_SIZE)
    }
    
    public init(_ hash: Bytes) throws {
        guard hash.count == NeoConstants.HASH160_SIZE else {
            throw "Hash must be \(NeoConstants.HASH160_SIZE) bytes long but was \(hash.count) bytes."
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
    
    public func toAddress() -> String {
        return hash.scripthashToAddress
    }
    
    public static func fromAddress(_ address: String) throws -> Hash160 {
        return try .init(address.addressToScriptHash())
    }
    
    public static func fromScript(_ script: Bytes) throws -> Hash160 {
        return try Hash160(script.sha256ThenRipemd160().reversed())
    }
    
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
