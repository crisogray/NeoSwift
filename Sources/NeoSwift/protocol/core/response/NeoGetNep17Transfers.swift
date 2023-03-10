
public class NeoGetNep17Transfers: NeoGetTokenTransfers<NeoGetNep17Transfers.Nep17Transfers> {
    
    public var nep17Transfers: Nep17Transfers? {
        return result
    }
    
    public struct Nep17Transfers: TokenTransfers {
        
        public let sent: [Nep17Transfer]
        public let received: [Nep17Transfer]
        public let transferAddress: String
        
        enum CodingKeys: String, CodingKey {
            case sent, received
            case transferAddress = "address"
        }
        
    }
    
    public struct Nep17Transfer: TokenTransfer {
        
        public let timestamp: Int
        public let assetHash: Hash160
        public let transferAddress: String
        @StringDecode public private(set) var amount: Int
        public let blockIndex: Int
        public let transferNotifyIndex: Int
        public let txHash: Hash256
        
        enum CodingKeys: String, CodingKey {
            case timestamp, amount
            case assetHash = "assethash"
            case transferAddress = "transferaddress"
            case blockIndex = "blockindex"
            case transferNotifyIndex = "transfernotifyindex"
            case txHash = "txhash"
        }
        
    }
    
}

