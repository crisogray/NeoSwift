
public struct ContractMethodToken: Codable, Hashable {
    
    public let hash: Hash160
    public let method: String
    public let paramCount: Int
    public let returnValue: Bool
    public let callFlags: String
    
    enum CodingKeys: String, CodingKey {
        case hash, method
        case paramCount = "paramcount"
        case returnValue = "hasreturnvalue"
        case callFlags = "callflags"
    }
    
}
