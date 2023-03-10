
public class NeoGetUnspents: Response<NeoGetUnspents.Unspents> {
    
    public var unspents: Unspents? {
        return result
    }
    
    public struct Unspents: Codable, Hashable {
        
        public let balances: [Balance]
        public let address: String
        
        enum CodingKeys: String, CodingKey {
            case address
            case balances = "balance"
        }
        
    }
    
    public struct Balance: Codable, Hashable {
        
        public let unspentTransactions: [UnspentTransaction]
        public let assetHash: String
        public let assetName: String
        public let assetSymbol: String
        public let amount: Double
        
        enum CodingKeys: String, CodingKey {
            case unspentTransactions = "unspent"
            case assetHash = "assethash"
            case assetName = "asset"
            case assetSymbol = "asset_symbol"
            case amount
        }

    }
    
    public struct UnspentTransaction: Codable, Hashable {
        
        public let txId: String
        public let index: Int
        public let value: Double
        
        enum CodingKeys: String, CodingKey {
            case value
            case txId = "txid"
            case index = "n"
        }
        
    }
    
}
