
public struct NeoAccountState: Codable, Hashable {
    
    public let balance: Int
    public let balanceHeight: Int?
    public var publicKey: ECPublicKey? = nil
    
    public init(balance: Int, balanceHeight: Int?, publicKey: ECPublicKey?) {
        self.balance = balance
        self.balanceHeight = balanceHeight
        self.publicKey = publicKey
    }
    
    public static func withNoVote(_ balance: Int, _ updateHeight: Int) -> NeoAccountState {
        return .init(balance: balance, balanceHeight: updateHeight, publicKey: nil)
    }
    
    public static func withNoBalance() -> NeoAccountState {
        return .init(balance: 0, balanceHeight: nil, publicKey: nil)
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.balance = try container.decode(Int.self, forKey: .balance)
        self.balanceHeight = try container.decodeIfPresent(Int.self, forKey: .balanceHeight)
        if let publicKeyString = try container.decodeIfPresent(String.self, forKey: .publicKey) {
            self.publicKey = try .init(publicKeyString)
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(balance, forKey: .balance)
        try container.encodeIfPresent(balanceHeight, forKey: .balanceHeight)
        try container.encodeIfPresent(publicKey?.getEncodedCompressedHex(), forKey: .publicKey)
    }
    
    enum CodingKeys: String, CodingKey {
        case balance, balanceHeight
        case publicKey = "voteTo"
    }
    
}
