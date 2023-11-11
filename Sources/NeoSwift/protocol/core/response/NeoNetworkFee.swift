
public struct NeoNetworkFee: Codable, Hashable {
    
    @StringDecode public private(set) var networkFee: Int
    
    public init(networkFee: Int) {
        self.networkFee = networkFee
    }
    
    enum CodingKeys: String, CodingKey {
        case networkFee = "networkfee"
    }
    
}

