
public class NeoGetNep17Balances: NeoGetTokenBalances<NeoGetNep17Balances.Nep17Balances> {
    
    public var balances: Nep17Balances? {
        return result
    }
    
    public struct Nep17Balances: TokenBalances {
        
        public let address: String
        public let balances: [Nep17Balance]
        
        public init(address: String, balances: [Nep17Balance]) {
            self.address = address
            self.balances = balances
        }
        
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
        
        public init(name: String?, symbol: String?, decimals: String?, amount: String, lastUpdatedBlock: Double, assetHash: Hash160) {
            self.name = name
            self.symbol = symbol
            self.decimals = decimals
            self.amount = amount
            self.lastUpdatedBlock = lastUpdatedBlock
            self.assetHash = assetHash
        }
        
        enum CodingKeys: String, CodingKey {
            case name, symbol, decimals, amount
            case assetHash = "assethash"
            case lastUpdatedBlock = "lastupdatedblock"
        }
        
    }
    
}
