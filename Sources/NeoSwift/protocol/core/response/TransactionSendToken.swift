
public struct TransactionSendToken: Codable, Hashable {
    
    public let token: Hash160
    public let value: Int
    public let address: String
    
    enum CodingKeys: String, CodingKey {
        case token = "asset"
        case value, address
    }
    
}
