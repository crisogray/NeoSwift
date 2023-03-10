
public struct NeoWitness: Codable, Hashable {
    
    public let invocation: String
    public let verification: String
    
    public init(_ invocation: String, _ verification: String) {
        self.invocation = invocation
        self.verification = verification
    }
    
    public init(_ witness: Witness) {
        invocation = witness.invocationScript.script.base64Encoded
        verification = witness.verificationScript.script.base64Encoded
    }
    
}
