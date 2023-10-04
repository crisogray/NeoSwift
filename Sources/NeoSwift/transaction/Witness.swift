
import Foundation

/// A script (invocation and verification script) used to validate a transaction.
/// Usually, a witness is made up of a signature (invocation script) and a check-signature script (verification script) that together prove that the signer has witnessed the signed data.
public struct Witness: Hashable {
    
    public let invocationScript: InvocationScript
    public let verificationScript: VerificationScript
    
    /// Constructs an empty witness.
    public init() {
        self.invocationScript = InvocationScript()
        self.verificationScript = VerificationScript()
    }
    
    /// Creates a new witness from the given invocation and verification script.
    /// - Parameters:
    ///   - invocationScript: The invocation script
    ///   - verificationScript: The verification script
    public init(_ invocationScript: Bytes, _ verificationScript: Bytes) {
        self.invocationScript = InvocationScript(invocationScript)
        self.verificationScript = VerificationScript(verificationScript)
    }
    
    /// Creates a new script from the given invocation and verification script.
    /// - Parameters:
    ///   - invocationScript: The invocation script
    ///   - verificationScript: The verification script
    public init(_ invocationScript: InvocationScript, _ verificationScript: VerificationScript) {
        self.invocationScript = invocationScript
        self.verificationScript = verificationScript
    }
    
    /// Creates a witness (invocation and verification scripts) from the given message, using the given keys for signing the message.
    /// - Parameters:
    ///   - messageToSign: The message from which the signature is added to the invocation script
    ///   - keyPair: The key pair which is used for signing. The verification script is created from the public key
    /// - Returns: The constructed witness/script.
    public static func create(_ messageToSign: Bytes, _ keyPair: ECKeyPair) throws -> Witness {
        return try Witness(InvocationScript.fromMessageAndKeyPair(messageToSign, keyPair), VerificationScript(keyPair.publicKey))
    }
    
    /// Creates a witness in which the invocation script contains the given signatures and the verification script checks the signatures according to the given public keys and signing threshold.
    ///
    /// The signatures must appear in the same order as their associated public keys.
    /// Example: Given the public keys {p1, p2, p3} and signatures {s1, s2}. Where s1 belongs to p1 and s2 to p2.
    /// Assume that the natural ordering of the keys is p3 &lt; p2 &lt; p1. Then you need to pass the signatures in the ordering {s2, s1}.
    /// - Parameters:
    ///   - signingThreshold: The minimum number of signatures required for successful multi-sig verification
    ///   - signatures: The signatures to add to the invocation script
    ///   - publicKeys: The public keys to add to verification script
    /// - Returns: The witness
    public static func creatMultiSigWitness(_ signingThreshold: Int, _ signatures: [Sign.SignatureData],
                                            _ publicKeys: [ECPublicKey]) throws -> Witness {
        return try creatMultiSigWitness(signatures, VerificationScript(publicKeys, signingThreshold))
    }
    
    /// Constructs a witness with the given verification script and an invocation script containing the given signatures.
    /// The number of signatures must reach the signing threshold given in the verification script.
    ///
    /// Note, the signatures must be in the order of their associated public keys in the verifications script.
    /// E.g., if we have public keys {p1, p2, p3} appear in the verification script as {p3, p2, p1} (due to their natural ordering),
    /// then the signatures {s1, s3} would have to be ordered {s3, s1} when passed as an argument.
    /// - Parameters:
    ///   - signatures: The signatures to add to the invocation script
    ///   - verificationScript: The verification script to use in the witness
    /// - Returns: The witness
    public static func creatMultiSigWitness(_ signatures: [Sign.SignatureData],
                                            _ verificationScript: VerificationScript) throws -> Witness {
        let threshold = try verificationScript.getSigningThreshold()
        guard signatures.count >= threshold else {
            throw NeoSwiftError.illegalArgument("Not enough signatures provided for the required signing threshold.")
        }
        return Witness(InvocationScript.fromSignatures(Array(signatures[0..<threshold])), verificationScript)
    }
    
    /// Constructs a witness with an invocation script based on the provided parameters for the contract's verify method.
    ///
    /// This method is used if no signature is present, i.e. if the signer is a contract.
    /// In that case the invocation script is built based on the parameters of its verify method. No verification script is needed.
    /// - Parameter verifyParams: The parameters for the contract's verify method
    /// - Returns: The witness
    public static func createContractWitness(_ verifyParams: [ContractParameter]) throws -> Witness {
        if verifyParams.isEmpty {
            return Witness()
        }
        let builder = ScriptBuilder()
        let _ = try verifyParams.map(builder.pushParam(_:))
        return Witness(builder.toArray(), [])
    }
    
}

extension Witness: NeoSerializable {
    
    public var size: Int {
        return invocationScript.size + verificationScript.size
    }
    
    public func serialize(_ writer: BinaryWriter) {
        invocationScript.serialize(writer)
        verificationScript.serialize(writer)
    }
    
    public static func deserialize(_ reader: BinaryReader) throws -> Witness {
        let invocationScript = try InvocationScript.deserialize(reader)
        let verificationScript = try VerificationScript.deserialize(reader)
        return Witness(invocationScript, verificationScript)
    }
}
