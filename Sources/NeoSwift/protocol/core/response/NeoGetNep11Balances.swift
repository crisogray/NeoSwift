

public class NeoGetNep11Balances: NeoGetTokenBalances<NeoGetNep11Balances.Nep11Balances> {
    
    public var balances: Nep11Balances? {
        return result
    }
    
    public struct Nep11Balances: TokenBalances {
        
        public let address: String
        public let balances: [Nep11Balance]
        
        enum CodingKeys: String, CodingKey {
            case address, balances = "balance"
        }
        
    }
    
    public struct Nep11Balance: TokenBalance {
        
        public let name: String
        public let symbol: String
        public let decimals: String
        public let tokens: [Nep11Token]
        public let assetHash: Hash160
        
        enum CodingKeys: String, CodingKey {
            case name, symbol, decimals, tokens
            case assetHash = "assethash"
        }
        
    }
    
    public struct Nep11Token: Codable, Hashable {
        
        public let tokenId: String
        public let amount: String
        public let lastUpdatedBlock: Int
        
        enum CodingKeys: String, CodingKey {
            case amount
            case tokenId = "tokenid"
            case lastUpdatedBlock = "lastupdatedblock"
        }
        
    }
    
}
