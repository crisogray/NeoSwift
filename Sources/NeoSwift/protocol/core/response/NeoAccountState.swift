
public struct NeoAccountState: Codable, Hashable {
    
    public let balance: Int
    public let balanceHeight: Int?
    private let publicKeyString: String?
    
    public lazy var publicKey: ECPublicKey? = {
        return try? ECPublicKey(publicKeyString ?? "")
    }()
    
    init(balance: Int, balanceHeight: Int?, publicKeyString: String?) {
        self.balance = balance
        self.balanceHeight = balanceHeight
        self.publicKeyString = publicKeyString
    }
    
    public static func withNoVote(_ balance: Int, _ updateHeight: Int) -> NeoAccountState {
        return .init(balance: balance, balanceHeight: updateHeight, publicKeyString: nil)
    }
    
    public static func withNoBalance() -> NeoAccountState {
        return .init(balance: 0, balanceHeight: nil, publicKeyString: nil)
    }
    
    enum CodingKeys: String, CodingKey {
        case balance, balanceHeight
        case publicKeyString = "voteTo"
    }
    
}
