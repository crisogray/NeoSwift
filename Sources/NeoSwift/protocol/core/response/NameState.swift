
public struct NameState: Codable, Hashable {
    
    public let name: String
    public let expiration: Int?
    public let admin: Hash160?
    
    public init(name: String, expiration: Int?, admin: Hash160?) {
        self.name = name
        self.expiration = expiration
        self.admin = admin
    }
    
}
