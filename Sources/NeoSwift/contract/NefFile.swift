import Foundation

public struct NefFile {
    
    private static let MAGIC = 0x3346454E
    private static let MAGIC_SIZE = 4
    private static let COMPILER_SIZE = 64
    private static let MAX_SOURCE_URL_SIZE = 256
    private static let MAX_SCRIPT_LENGTH = 512 * 1024
    private static let CHECKSUM_SIZE = 4
    private static let HEADER_SIZE = MAGIC_SIZE + COMPILER_SIZE
    
    public let compiler: String?
    public let sourceUrl: String
    public let methodTokens: [MethodToken]
    public let script: Bytes
    public private(set) var checksum: Bytes

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
    
    public init(compiler: String?, sourceUrl: String = "", methodTokens: [MethodToken], script: Bytes) throws {
        let compilerSize = compiler?.bytes.count ?? 0
        guard compilerSize <= NefFile.COMPILER_SIZE else {
            throw NeoSwiftError.illegalArgument("The compiler name and version string can be max \(NefFile.COMPILER_SIZE) bytes long, but was \(compilerSize) bytes long.")
        }
        self.compiler = compiler
        self.sourceUrl = sourceUrl
        self.methodTokens = methodTokens
        guard sourceUrl.bytes.count <= NefFile.MAX_SOURCE_URL_SIZE else {
            throw NeoSwiftError.illegalArgument("The source URL must not be longer than \(NefFile.MAX_SOURCE_URL_SIZE) bytes.")
        }
        self.script = script
        self.checksum = .init(repeating: 0, count: NefFile.CHECKSUM_SIZE)
        self.checksum = NefFile.computeChecksum(self)
    }
    
    public static func getChecksumAsInteger(_ bytes: Bytes) -> Int {
        return bytes.toNumeric(littleEndian: true)
    }
    
    public static func computeChecksum(_ file: NefFile) -> Bytes {
        return computeChecksumFromBytes(file.toArray())
    }
    
    public static func computeChecksumFromBytes(_ bytes: Bytes) -> Bytes {
        let fileBytes = Bytes(bytes.dropLast(NefFile.CHECKSUM_SIZE))
        return Bytes(fileBytes.hash256().prefix(NefFile.CHECKSUM_SIZE))
    }
    
    public static func readFromFile(_ file: URL) throws -> NefFile {
        let fileBytes = try Data(contentsOf: file).bytes
        guard fileBytes.count <= 0x100000 else {
            throw NeoSwiftError.illegalArgument("The given NEF file is too large. File was \(fileBytes.count) bytes, but a max of 2^20 bytes is allowed.")
        }
        return try BinaryReader(fileBytes).readSerializable()
    }
    
    public static func readFromStackItem(_ stackItem: StackItem) throws -> NefFile {
        guard case .byteString = stackItem else {
            throw ContractError.unexpectedReturnType(stackItem.jsonValue, [StackItem.BYTE_STRING_VALUE])
        }
        let nefBytes = try stackItem.getByteArray()
        return try BinaryReader(nefBytes).readSerializable()
    }
    
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
        guard sourceUrl.bytes.count <= NefFile.MAX_SOURCE_URL_SIZE else {
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
