

public class NeoGetNep11Balances: NeoGetTokenBalances<NeoGetNep11Balances.Nep11Balances> {
    
    public var balances: Nep11Balances? {
        return result
    }
    
    public struct Nep11Balances: TokenBalances {
        
        public let address: String
        public let balances: [Nep11Balance]
        
        public init(address: String, balances: [Nep11Balance]) {
            self.address = address
            self.balances = balances
        }
        
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
        
        public init(name: String, symbol: String, decimals: String, tokens: [Nep11Token], assetHash: Hash160) {
            self.name = name
            self.symbol = symbol
            self.decimals = decimals
            self.tokens = tokens
            self.assetHash = assetHash
        }
        
        enum CodingKeys: String, CodingKey {
            case name, symbol, decimals, tokens
            case assetHash = "assethash"
        }
        
    }
    
    public struct Nep11Token: Codable, Hashable {
        
        public let tokenId: String
        public let amount: String
        public let lastUpdatedBlock: Int
        
        public init(tokenId: String, amount: String, lastUpdatedBlock: Int) {
            self.tokenId = tokenId
            self.amount = amount
            self.lastUpdatedBlock = lastUpdatedBlock
        }
        
        enum CodingKeys: String, CodingKey {
            case amount
            case tokenId = "tokenid"
            case lastUpdatedBlock = "lastupdatedblock"
        }
        
    }
    
}
