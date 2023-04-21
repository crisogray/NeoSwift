
public class NeoGetNep17Balances: NeoGetTokenBalances<NeoGetNep17Balances.Nep17Balances> {
    
    public var balances: Nep17Balances? {
        return result
    }
    
    public struct Nep17Balances: TokenBalances {
        
        public let address: String
        public let balances: [Nep17Balance]
        
        enum CodingKeys: String, CodingKey {
            case address, balances = "balance"
        }
        
    }
    
    public struct Nep17Balance: TokenBalance {
        
        public let name: String?
        public let symbol: String?
        public let decimals: String?
        public let amount: String
        public let lastUpdatedBlock: Double
        public let assetHash: Hash160
        
        enum CodingKeys: String, CodingKey {
            case name, symbol, decimals, amount
            case assetHash = "assethash"
            case lastUpdatedBlock = "lastupdatedblock"
        }
        
    }
    
}
