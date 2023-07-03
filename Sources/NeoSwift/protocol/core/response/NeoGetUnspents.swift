
public class NeoGetUnspents: Response<NeoGetUnspents.Unspents> {
    
    public var unspents: Unspents? {
        return result
    }
    
    public struct Unspents: Codable, Hashable {
        
        public let balances: [Balance]
        public let address: String
        
        public init(balances: [Balance], address: String) {
            self.balances = balances
            self.address = address
        }
        
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
        
        public init(unspentTransactions: [UnspentTransaction], assetHash: String, assetName: String, assetSymbol: String, amount: Double) {
            self.unspentTransactions = unspentTransactions
            self.assetHash = assetHash
            self.assetName = assetName
            self.assetSymbol = assetSymbol
            self.amount = amount
        }
        
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
        
        public init(txId: String, index: Int, value: Double) {
            self.txId = txId
            self.index = index
            self.value = value
        }
        
        enum CodingKeys: String, CodingKey {
            case value
            case txId = "txid"
            case index = "n"
        }
        
    }
    
}
