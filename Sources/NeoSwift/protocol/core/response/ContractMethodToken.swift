
public struct ContractMethodToken: Codable, Hashable {
    
    public let hash: Hash160
    public let method: String
    public let paramCount: Int
    public let returnValue: Bool
    public let callFlags: String
    
    public init(hash: Hash160, method: String, paramCount: Int, returnValue: Bool, callFlags: String) {
        self.hash = hash
        self.method = method
        self.paramCount = paramCount
        self.returnValue = returnValue
        self.callFlags = callFlags
    }
    
    enum CodingKeys: String, CodingKey {
        case hash, method
        case paramCount = "paramcount"
        case returnValue = "hasreturnvalue"
        case callFlags = "callflags"
    }
    
}
