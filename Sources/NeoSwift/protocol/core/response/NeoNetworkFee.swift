
public struct NeoNetworkFee: Codable, Hashable {
    
    public let networkFee: Int
    
    public init(networkFee: Int) {
        self.networkFee = networkFee
    }
    
    enum CodingKeys: String, CodingKey {
        case networkFee = "networkfee"
    }
    
}

