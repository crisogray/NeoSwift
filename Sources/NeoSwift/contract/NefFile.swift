
import BigInt
import Foundation

/*
┌───────────────────────────────────────────────────────────────────────┐
│                    NEO Executable Format 3 (NEF3)                     │
├──────────┬───────────────┬────────────────────────────────────────────┤
│  Field   │     Type      │                  Comment                   │
├──────────┼───────────────┼────────────────────────────────────────────┤
│ Magic    │ uint32        │ Magic header                               │
│ Compiler │ byte[64]      │ Compiler name and version                  │
├──────────┼───────────────┼────────────────────────────────────────────┤
│ Source   │ byte[]        │ The url of the source files, max 255 bytes │
│ Reserve  │ byte[2]       │ Reserved for future extensions. Must be 0. │
│ Tokens   │ MethodToken[] │ Method tokens                              │
│ Reserve  │ byte[2]       │ Reserved for future extensions. Must be 0. │
│ Script   │ byte[]        │ Var bytes for the payload                  │
├──────────┼───────────────┼────────────────────────────────────────────┤
│ Checksum │ uint32        │ First four bytes of double SHA256 hash     │
└──────────┴───────────────┴────────────────────────────────────────────┘
 */

public struct NefFile {
    
    private static let MAGIC = 0x3346454E
    private static let MAGIC_SIZE = 4
    private static let COMPILER_SIZE = 64
    private static let MAX_SOURCE_URL_SIZE = 256
    private static let MAX_SCRIPT_LENGTH = 512 * 1024
    private static let CHECKSUM_SIZE = 4
    private static let HEADER_SIZE = MAGIC_SIZE + COMPILER_SIZE
    
    /// The compiler name and version with which this NEF file has been generated.
    public let compiler: String?
    /// The source code URL.
    public let sourceUrl: String
    /// The contract's method tokens. The tokens represent calls to other contracts.
    public let methodTokens: [MethodToken]
    /// The contract script
    public let script: Bytes
    /// The check sum
    public private(set) var checksum: Bytes
    
    /// The NEF file's check sum as an integer.
    /// The check sum bytes of the NEF file are read as a little endian unsigned integer.
    public var checksumInteger: Int {
        return NefFile.getChecksumAsInteger(checksum)
    }
    
    public init() {
        compiler = nil
        sourceUrl = ""
        methodTokens = []
        script = []
        checksum = []
    }
    
    /// Constructs a new `NefFile` from the given contract information.
    /// - Parameters:
    ///   - compiler: The compiler name and version with which the contract has been compiled
    ///   - sourceUrl: The URL to the source code of the contract
    ///   - methodTokens: The method tokens of the contract
    ///   - script: The contract's script
    public init(compiler: String?, sourceUrl: String = "", methodTokens: [MethodToken], script: Bytes) throws {
        let compilerSize = compiler?.bytes.count ?? 0
        guard compilerSize <= NefFile.COMPILER_SIZE else {
            throw NeoSwiftError.illegalArgument("The compiler name and version string can be max \(NefFile.COMPILER_SIZE) bytes long, but was \(compilerSize) bytes long.")
        }
        self.compiler = compiler
        self.sourceUrl = sourceUrl
        self.methodTokens = methodTokens
        guard sourceUrl.bytes.count < NefFile.MAX_SOURCE_URL_SIZE else {
            throw NeoSwiftError.illegalArgument("The source URL must not be longer than \(NefFile.MAX_SOURCE_URL_SIZE) bytes.")
        }
        self.script = script
        self.checksum = Bytes(repeating: 0, count: NefFile.CHECKSUM_SIZE)
        self.checksum = NefFile.computeChecksum(self)
    }
    
    /// Converts check sum bytes to an integer.
    ///
    /// The check sum is expected to be 4 bytes, and it is interpreted as a little endian unsigned integer.
    /// - Parameter bytes: The check sum bytes
    /// - Returns: The check sum as an integer
    public static func getChecksumAsInteger(_ bytes: Bytes) -> Int {
        return BInt(magnitude: bytes.reversed()).asInt()!
    }
    
    /// Computes the checksum for the given NEF file.
    /// - Parameter file: The NEF file
    /// - Returns: The checksum
    public static func computeChecksum(_ file: NefFile) -> Bytes {
        return computeChecksumFromBytes(file.toArray())
    }
    
    /// Computes the checksum from the bytes of a NEF file.
    /// - Parameter bytes: The bytes of the NEF file
    /// - Returns: The checksum
    public static func computeChecksumFromBytes(_ bytes: Bytes) -> Bytes {
        let fileBytes = Bytes(bytes.dropLast(NefFile.CHECKSUM_SIZE))
        return Bytes(fileBytes.hash256().prefix(NefFile.CHECKSUM_SIZE))
    }
    
    /// Reads and constructs an `NefFile` instance from the given file.
    /// - Parameter file: The file to read from
    /// - Returns: The deserialized `NefFile` instance
    public static func readFromFile(_ file: URL) throws -> NefFile {
        let fileBytes = try Data(contentsOf: file).bytes
        guard fileBytes.count <= 0x100000 else {
            throw NeoSwiftError.illegalArgument("The given NEF file is too large. File was \(fileBytes.count) bytes, but a max of 2^20 bytes is allowed.")
        }
        return try BinaryReader(fileBytes).readSerializable()
    }
    
    /// Deserializes and constructs a `NefFile` from the given stack item.
    ///
    /// It is expected that the stack item is of type ``StackItem/byteString(_:)`` and its content is simply a serialized NEF file.
    /// - Parameter stackItem: The stack item to deserialize
    /// - Returns: The deserialized `NefFile`
    public static func readFromStackItem(_ stackItem: StackItem) throws -> NefFile {
        guard case .byteString = stackItem else {
            throw ContractError.unexpectedReturnType(stackItem.jsonValue, [StackItem.BYTE_STRING_VALUE])
        }
        let nefBytes = try stackItem.getByteArray()
        return try BinaryReader(nefBytes).readSerializable()
    }
    
    /// Represents a static call to another contract from within a smart contract.
    /// Method tokens are referenced in the smart contract's script whenever the referenced method is called.
    public struct MethodToken: NeoSerializable, Hashable {
        
        private static let PARAMS_COUNT_SIZE = 0x3346454E
        private static let HAS_RETURN_VALUE_SIZE = 4
        private static let CALL_FLAGS_SIZE = 64
        
        public let hash: Hash160
        public let method: String
        public let parametersCount: Int
        public let hasReturnValue: Bool
        public let callFlags: CallFlags
        
        public init(hash: Hash160, method: String, parametersCount: Int, hasReturnValue: Bool, callFlags: CallFlags) {
            self.hash = hash
            self.method = method
            self.parametersCount = parametersCount
            self.hasReturnValue = hasReturnValue
            self.callFlags = callFlags
        }
        
        public var size: Int {
            NeoConstants.HASH160_SIZE
            + method.varSize
            + MethodToken.PARAMS_COUNT_SIZE
            + MethodToken.HAS_RETURN_VALUE_SIZE
            + MethodToken.CALL_FLAGS_SIZE
        }
        
        public func serialize(_ writer: BinaryWriter) {
            writer.writeSerializableFixed(hash)
            writer.writeVarString(method)
            writer.writeUInt16(UInt16(parametersCount))
            writer.writeBoolean(hasReturnValue)
            writer.writeByte(callFlags.value)
        }
        
        public static func deserialize(_ reader: BinaryReader) throws -> NefFile.MethodToken {
            do {
                let hash: Hash160 = try reader.readSerializable()
                let method = try reader.readVarString()
                let parametersCount = Int(reader.readUInt16())
                let hasReturnValue = reader.readBoolean()
                let callFlags = try CallFlags.fromValue(reader.readByte())
                return .init(hash: hash, method: method, parametersCount: parametersCount,
                             hasReturnValue: hasReturnValue, callFlags: callFlags)
            } catch {
                throw NeoSwiftError.deserialization(error.localizedDescription)
            }
        }
        
    }
    
}

extension NefFile: NeoSerializable {
    
    /// The byte size of this NEF file when serialized.
    public var size: Int {
        return NefFile.HEADER_SIZE + sourceUrl.varSize + 1
        + methodTokens.varSize + 2
        + script.varSize + NefFile.CHECKSUM_SIZE
    }

    public func serialize(_ writer: BinaryWriter) {
        writer.writeUInt32(UInt32(NefFile.MAGIC))
        // Errors suppressed as compiler length is checked at initialisation
        try! writer.writeFixedString(compiler, length: NefFile.COMPILER_SIZE)
        writer.writeVarString(sourceUrl)
        writer.writeByte(0)
        writer.writeSerializableVariable(methodTokens)
        writer.writeUInt16(0)
        writer.writeVarBytes(script)
        writer.write(checksum)
    }

    public static func deserialize(_ reader: BinaryReader) throws -> Self {
        guard reader.readInt32() == NefFile.MAGIC else {
            throw NeoSwiftError.deserialization("Wrong magic number in NEF file.")
        }
        let compilerBytes = try reader.readBytes(NefFile.COMPILER_SIZE)
        let compiler = String(bytes: compilerBytes.trimTrailingBytes(of: 0), encoding: .utf8)
        let sourceUrl = try reader.readVarString()
        guard sourceUrl.bytes.count < NefFile.MAX_SOURCE_URL_SIZE else {
            throw NeoSwiftError.deserialization("Source URL must not be longer than \(NefFile.MAX_SOURCE_URL_SIZE) bytes.")
        }
        guard reader.readByte() == 0 else {
            throw NeoSwiftError.deserialization("Reserve bytes in NEF file must be 0.")
        }
        let methodTokens: [MethodToken] = reader.readSerializableList()
        guard reader.readUInt16() == 0 else {
            throw NeoSwiftError.deserialization("Reserve bytes in NEF file must be 0.")
        }
        let script = try reader.readVarBytes(NefFile.MAX_SCRIPT_LENGTH)
        guard script.count > 0 else {
            throw NeoSwiftError.deserialization("Script cannot be empty in NEF file.")
        }
        let file = try NefFile(compiler: compiler, sourceUrl: sourceUrl, methodTokens: methodTokens, script: script)
        let checksum = try reader.readBytes(NefFile.CHECKSUM_SIZE)
        guard file.checksum == checksum else {
            print(file.checksum, checksum)
            throw NeoSwiftError.deserialization("The checksums did not match.")
        }
        return file
    }

}
