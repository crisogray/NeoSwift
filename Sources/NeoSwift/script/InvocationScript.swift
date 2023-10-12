
import Foundation

/// An invocation script is part of a witness and is simply a sequence of neo-vm instructions.
/// The invocation script usually is the input to the verification script.
/// In most cases it will contain a signature that is checked in the verification script.
public class InvocationScript: NeoSerializable, Hashable {
    
    /// This invocation script as a byte array
    public let script: Bytes
    
    public var size: Int {
        return script.count.varSize + script.count
    }
    
    /// Constructs an empty invocation script.
    public init() {
        self.script = []
    }
    
    /// Creates an invocation script with the given script.
    ///
    /// It is recommended to use ``InvocationScript/fromSignature(_:)`` or ``InvocationScript/fromMessageAndKeyPair(_:_:)`` when you need a signature invocation script.
    /// - Parameter script: The script in an array of bytes
    public init(_ script: Bytes) {
        self.script = script
    }
    
    /// Creates an invocation script from the given signature.
    /// - Parameter signature: The signature to use in the script
    /// - Returns: The constructed invocation script
    public static func fromSignature(_ signature: Sign.SignatureData) -> InvocationScript {
        return .init(ScriptBuilder().pushData(signature.concatenated).toArray())
    }
    
    /// Creates an invocation script from the signature of the given message signed with the given key pair.
    /// - Parameters:
    ///   - message: The message to sign
    ///   - keyPair: The key to use for signing
    /// - Returns: The constructed invocation script
    public static func fromMessageAndKeyPair(_ message: Bytes, _ keyPair: ECKeyPair) throws -> InvocationScript {
        return try .init(ScriptBuilder().pushData(Sign.signMessage(message, keyPair).concatenated).toArray())
    }
    
    /// Constructs an invocation script from the given signatures.
    /// - Parameter signatures: The signatures
    /// - Returns: The invocation script
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
    
    /// Unbundles the script into a list of signatures if this invocation script contains signatures.
    /// - Returns: The list of signatures found in this script
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

