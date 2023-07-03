
public struct TransactionSendToken: Codable, Hashable {
    
    public let token: Hash160
    public let value: Int
    public let address: String
    
    public init(token: Hash160, value: Int, address: String) {
        self.token = token
        self.value = value
        self.address = address
    }
    
    enum CodingKeys: String, CodingKey {
        case token = "asset"
        case value, address
    }
    
}
