
import Foundation

public class VerificationScript: NeoSerializable, Hashable {
    
    public let script: Bytes
    
    public var size: Int {
        return script.count.varSize + script.count
    }
    
    public var scriptHash: Hash160? {
        return try? Hash160.fromScript(script)
    }
    
    public init() {
        self.script = []
    }
    
    public init(_ script: Bytes) {
        self.script = script
    }
    
    public init(_ publicKey: ECPublicKey) throws {
        self.script = try ScriptBuilder.buildVerificationScript(publicKey.getEncoded(compressed: true))
    }
    
    public init(_ publicKeys: [ECPublicKey], _ signingThreshold: Int) throws {
        guard signingThreshold >= 1 && signingThreshold <= publicKeys.count else {
            throw NeoSwiftError.illegalArgument("Signing threshold must be at least 1 and not higher than the number of public keys.")
        }
        guard publicKeys.count <= NeoConstants.MAX_PUBLIC_KEYS_PER_MULTISIG_ACCOUNT else {
            throw NeoSwiftError.illegalArgument("At max \(NeoConstants.MAX_PUBLIC_KEYS_PER_MULTISIG_ACCOUNT) public keys can take part in a multi-sig account")
        }
        self.script = try ScriptBuilder.buildVerificationScript(publicKeys, signingThreshold)
    }
    
    public func getSigningThreshold() throws -> Int {
        if isSingleSigScript() { return 1 }
        else if isMultiSigScript() { return try BinaryReader(script).readPushInt() }
        throw TransactionError.scriptFormat("The signing threshold cannot be determined because this script does not apply to the format of a signature verification script.")
    }
    
    public func getNrOfAccounts() throws -> Int {
        return try getPublicKeys().count
    }
    
    public func isSingleSigScript() -> Bool {
        guard script.count == 40 else {
            return false
        }
        let interopService = Bytes(script.suffix(4)).noPrefixHex
        return script[0] == OpCode.pushData1.opcode &&
        script[1] == 33 && script[35] == OpCode.sysCall.opcode &&
        interopService == InteropService.systemCryptoCheckSig.hash
    }
    
    public func isMultiSigScript() -> Bool {
        guard script.count >= 42 else {
            return false
        }
        do {
            let reader = BinaryReader(script), n = try reader.readPushInt()
            guard n > 0 && n <= NeoConstants.MAX_PUBLIC_KEYS_PER_MULTISIG_ACCOUNT else {
                return false
            }
            var m = 0
            while reader.readByte() == OpCode.pushData1.opcode {
                guard script.count >= reader.position + 35, reader.readByte() == 33 else {
                    return false
                }
                _ = try reader.readECPoint()
                m += 1
                reader.mark()
            }
            guard m >= n && m <= NeoConstants.MAX_PUBLIC_KEYS_PER_MULTISIG_ACCOUNT else {
                return false
            }
            reader.reset()
            guard try m == reader.readPushInt(), reader.readByte() == OpCode.sysCall.opcode,
                  try reader.readBytes(4).noPrefixHex == InteropService.systemCryptoCheckMultisig.hash else {
                return false
            }
            return true
        } catch {
            return false
        }
    }
    
    public func getPublicKeys() throws -> [ECPublicKey] {
        let reader = BinaryReader(script)
        do {
            if isSingleSigScript() {
                _ = reader.readByte()
                _ = reader.readByte()
                return [try ECPublicKey(reader.readECPoint())]
            } else if isMultiSigScript() {
                var keys: [ECPublicKey] = []
                try _ = reader.readPushInt()
                while reader.readByte() == OpCode.pushData1.opcode {
                    _ = reader.readByte()
                    try keys.append(ECPublicKey(reader.readECPoint()))
                }
                return keys
            }
        } catch {}
        throw TransactionError.scriptFormat("The verification script is in an incorrect format. No public keys can be read from it.")
    }
    
    public func serialize(_ writer: BinaryWriter) {
        writer.writeVarBytes(script)
    }
    
    public static func deserialize(_ reader: BinaryReader) throws -> Self {
        return try VerificationScript(reader.readVarBytes()) as! Self
    }
    
    public static func == (lhs: VerificationScript, rhs: VerificationScript) -> Bool {
        return lhs.script == rhs.script
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(script)
    }
    
}
