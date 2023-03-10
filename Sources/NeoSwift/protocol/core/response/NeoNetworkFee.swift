
public struct NeoNetworkFee: Codable, Hashable {
    
    public let networkFee: Int
    
    enum CodingKeys: String, CodingKey {
        case networkFee = "networkfee"
    }
    
}

