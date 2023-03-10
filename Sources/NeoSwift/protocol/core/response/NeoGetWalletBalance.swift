
public class NeoGetWalletBalance: Response<NeoGetWalletBalance.Balance> {
    
    public var walletBalance: Balance? {
        return result
    }
    
    public struct Balance: Codable, Hashable {
        
        public let balance: String
        
        enum CodingKeys: String, CodingKey {
            case balance, _balance = "Balance"
        }
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            balance = try (try? container.decode(String.self, forKey: .balance)) ?? container.decode(String.self, forKey: ._balance)
        }
        
        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(balance, forKey: .balance)
        }
        
    }
    
}
