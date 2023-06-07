
import Foundation

public class InvocationScript: NeoSerializable, Hashable {
    
    public let script: Bytes
    
    public var size: Int {
        return script.count.varSize + script.count
    }
    
    public init() {
        self.script = []
    }
    
    public init(_ script: Bytes) {
        self.script = script
    }
    
    public static func fromSignature(_ signature: Sign.SignatureData) -> InvocationScript {
        return .init(ScriptBuilder().pushData(signature.concatenated).toArray())
    }
    
    public static func fromMessageAndKeyPair(_ message: Bytes, _ keyPair: ECKeyPair) throws -> InvocationScript {
        return try .init(ScriptBuilder().pushData(Sign.signMessage(message, keyPair).concatenated).toArray())
    }
    
    public static func fromSignatures(_ signatures: [Sign.SignatureData]) -> InvocationScript {
        let builder = ScriptBuilder()
        signatures.forEach{ _ = builder.pushData($0.concatenated) }
        return .init(builder.toArray())
    }
    
    public func serialize(_ writer: BinaryWriter) {
        writer.writeVarBytes(script)
    }
    
    public static func deserialize(_ reader: BinaryReader) throws -> Self {
        return try InvocationScript(reader.readVarBytes()) as! Self
    }
    
    public static func == (lhs: InvocationScript, rhs: InvocationScript) -> Bool {
        return lhs.script == rhs.script
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(script)
    }
    
    public func getSignatures() -> [Sign.SignatureData] {
        let reader = BinaryReader(script)
        var sigs: [Sign.SignatureData] = []
        while reader.available > 0 && reader.readByte() == OpCode.pushData1.opcode {
            _ = reader.readByte()
            if let signature = try? Sign.SignatureData.fromByteArray(signature: reader.readBytes(NeoConstants.SIGNATURE_SIZE)) {
                sigs.append(signature)
            }
        }
        return sigs
    }
    
}

