
public class NeoGetClaimable: Response<NeoGetClaimable.Claimables> {
    
    public var claimables: Claimables? {
        return result
    }
    
    public struct Claimables: Codable, Hashable {
        
        public let claims: [Claim]
        public let address: String
        public let totalUnclaimed: String
        
        enum CodingKeys: String, CodingKey {
            case address
            case claims = "claimable"
            case totalUnclaimed = "unclaimed"
        }
        
    }

    public struct Claim: Codable, Hashable {
        
        public let txId: String
        public let index: Int
        public let neoValue: Int
        public let startHeight: Int
        public let endHeight: Int
        public let generatedGas: String
        public let systemFee: String
        public let unclaimedGas: String
        
        enum CodingKeys: String, CodingKey {
            case txId = "txid"
            case index = "n"
            case neoValue = "value"
            case startHeight = "start_height"
            case endHeight = "end_height"
            case generatedGas = "generated"
            case systemFee = "sysfee"
            case unclaimedGas = "unclaimed"
        }

    }
    
}
