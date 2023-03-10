
public class NeoGetTokenTransfers<T: TokenTransfers>: Response<T> { }

public protocol TokenTransfers: Codable, Hashable {
    
    associatedtype Transfer: TokenTransfer
    
    var sent: [Transfer] { get }
    var received: [Transfer] { get }
    var transferAddress: String { get }
    
}

public protocol TokenTransfer: Codable, Hashable {
    
    var timestamp: Int { get }
    var assetHash: Hash160 { get }
    var transferAddress: String { get }
    var amount: Int { get }
    var blockIndex: Int { get }
    var transferNotifyIndex: Int { get }
    var txHash: Hash256 { get }
    
}

