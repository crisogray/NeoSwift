

public class NeoGetNep11Transfers: NeoGetTokenTransfers<NeoGetNep11Transfers.Nep11Transfers> {
    
    public var nep11Transfers: Nep11Transfers? {
        return result
    }
    
    public struct Nep11Transfers: TokenTransfers {
        
        public let sent: [Nep11Transfer]
        public let received: [Nep11Transfer]
        public let transferAddress: String
        
        enum CodingKeys: String, CodingKey {
            case sent, received
            case transferAddress = "address"
        }
        
    }
    
    public struct Nep11Transfer: TokenTransfer {
        
        public let tokenId: String
        public let timestamp: Int
        public let assetHash: Hash160
        public let transferAddress: String
        @StringDecode public private(set) var amount: Int
        public let blockIndex: Int
        public let transferNotifyIndex: Int
        public let txHash: Hash256
        
        enum CodingKeys: String, CodingKey {
            case timestamp, amount
            case tokenId = "tokenid"
            case assetHash = "assethash"
            case transferAddress = "transferaddress"
            case blockIndex = "blockindex"
            case transferNotifyIndex = "transfernotifyindex"
            case txHash = "txhash"
        }
        
    }
    
}

