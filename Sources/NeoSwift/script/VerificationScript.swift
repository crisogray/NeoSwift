
import Foundation

/// A verification script is part of a witness and is simply a sequence of neo-vm instructions.
/// The verification script is the part of a witness that describes what has to be verified such that the witness is valid.
/// E.g. for a regular signature witness the verification script is made up of a check-signature call and it expects a signature as input.
public class VerificationScript: NeoSerializable, Hashable {
    
    /// The verification script as a byte array.
    public let script: Bytes
    
    public var size: Int {
        return script.count.varSize + script.count
    }
    
    /// The script hash of this verification script.
    public var scriptHash: Hash160? {
        return try? Hash160.fromScript(script)
    }
    
    /// Creates an empty verification script
    public init() {
        self.script = []
    }
    
    /// Creates a verification script from the given byte array.
    /// - Parameter script: The script
    public init(_ script: Bytes) {
        self.script = script
    }
    
    /// Creates a verification script for the given public key.
    /// The resulting verification script contains a signature check with the given public key as the expected signer.
    /// - Parameter publicKey: The public key to create the script for
    public init(_ publicKey: ECPublicKey) throws {
        self.script = try ScriptBuilder.buildVerificationScript(publicKey.getEncoded(compressed: true))
    }
    
    /// Creates a multi-sig verification script for the given keys and signing threshold.
    /// The resulting verification script contains a multi-signature check with the given public keys as the expected signer.
    /// - Parameters:
    ///   - publicKeys: The public keys to create the script for
    ///   - signingThreshold: The minimum number of public keys needed to sign transactions from the given public keys
    public init(_ publicKeys: [ECPublicKey], _ signingThreshold: Int) throws {
        guard signingThreshold >= 1 && signingThreshold <= publicKeys.count else {
            throw NeoSwiftError.illegalArgument("Signing threshold must be at least 1 and not higher than the number of public keys.")
        }
        guard publicKeys.count <= NeoConstants.MAX_PUBLIC_KEYS_PER_MULTISIG_ACCOUNT else {
            throw NeoSwiftError.illegalArgument("At max \(NeoConstants.MAX_PUBLIC_KEYS_PER_MULTISIG_ACCOUNT) public keys can take part in a multi-sig account")
        }
        self.script = try ScriptBuilder.buildVerificationScript(publicKeys, signingThreshold)
    }
    
    /// Extracts the number of signatures required for signing this verification script.
    /// - Returns: The signing threshold
    public func getSigningThreshold() throws -> Int {
        if isSingleSigScript() { return 1 }
        else if isMultiSigScript() { return try BinaryReader(script).readPushInt() }
        throw TransactionError.scriptFormat("The signing threshold cannot be determined because this script does not apply to the format of a signature verification script.")
    }
    
    /// Gets the number of accounts taking part in this verification script.
    /// - Returns: The number of accounts
    public func getNrOfAccounts() throws -> Int {
        return try getPublicKeys().count
    }
    
    /// Checks if this verification script is from single signature account.
    /// - Returns: `true` if this script is from a single signature account. Otherwise `false`.
    public func isSingleSigScript() -> Bool {
        guard script.count == 40 else {
            return false
        }
        let interopService = Bytes(script.suffix(4)).noPrefixHex
        return script[0] == OpCode.pushData1.opcode &&
        script[1] == 33 && script[35] == OpCode.sysCall.opcode &&
        interopService == InteropService.systemCryptoCheckSig.hash
    }
    
    /// Checks if this verification script is from a multi signature account.
    /// - Returns: `true` if this script is from a multi signature account. Otherwise `false`.
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
    
    /// Gets the public keys that are encoded in this verification script.
    /// If this script is from a single signature account the resulting list will only contain one key.
    ///
    /// In case of a multi-sig script, the public keys are returned in their natural ordering (public key value).
    /// This is also the order in which they appear in the script.
    /// - Returns: The list of public keys encoded in this script
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
