
import Foundation

public struct Witness: Hashable {
    
    public let invocationScript: InvocationScript
    public let verificationScript: VerificationScript
    
    init() {
        self.invocationScript = InvocationScript()
        self.verificationScript = VerificationScript()
    }
    
    init(_ invocationScript: Bytes, _ verificationScript: Bytes) {
        self.invocationScript = InvocationScript(invocationScript)
        self.verificationScript = VerificationScript(verificationScript)
    }
    
    init(_ invocationScript: InvocationScript, _ verificationScript: VerificationScript) {
        self.invocationScript = invocationScript
        self.verificationScript = verificationScript
    }
    
}

extension Witness {
    
    public static func create(_ messageToSign: Bytes, _ keyPair: ECKeyPair) throws -> Witness {
        return try Witness(InvocationScript.fromMessageAndKeyPair(messageToSign, keyPair), VerificationScript(keyPair.publicKey))
    }
    
    public static func creatMultiSigWitness(_ signingThreshold: Int, _ signatures: [Sign.SignatureData],
                                            _ publicKeys: [ECPublicKey]) throws -> Witness {
        return try creatMultiSigWitness(signatures, VerificationScript(publicKeys, signingThreshold))
    }
    
    public static func creatMultiSigWitness(_ signatures: [Sign.SignatureData],
                                            _ verificationScript: VerificationScript) throws -> Witness {
        let threshold = try verificationScript.getSigningThreshold()
        guard signatures.count >= threshold else {
            throw "Not enough signatures provided for the required signing threshold."
        }
        return Witness(InvocationScript.fromSignatures(Array(signatures[0..<threshold])), verificationScript)
    }

    public static func createContractWitness(_ verifyParams: [ContractParameter]) -> Witness {
        if verifyParams.isEmpty {
            return Witness()
        }
        let builder = ScriptBuilder()
        let _ = verifyParams.map(builder.pushParam(_:))
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
