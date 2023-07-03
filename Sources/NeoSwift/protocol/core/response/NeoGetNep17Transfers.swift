
public class NeoGetNep17Transfers: NeoGetTokenTransfers<NeoGetNep17Transfers.Nep17Transfers> {
    
    public var nep17Transfers: Nep17Transfers? {
        return result
    }
    
    public struct Nep17Transfers: TokenTransfers {
        
        public let sent: [Nep17Transfer]
        public let received: [Nep17Transfer]
        public let transferAddress: String
        
        public init(sent: [Nep17Transfer], received: [Nep17Transfer], transferAddress: String) {
            self.sent = sent
            self.received = received
            self.transferAddress = transferAddress
        }
        
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
        
        public init(timestamp: Int, assetHash: Hash160, transferAddress: String, amount: Int, blockIndex: Int, transferNotifyIndex: Int, txHash: Hash256) {
            self.timestamp = timestamp
            self.assetHash = assetHash
            self.transferAddress = transferAddress
            self.amount = amount
            self.blockIndex = blockIndex
            self.transferNotifyIndex = transferNotifyIndex
            self.txHash = txHash
        }
        
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

