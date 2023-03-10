
public class NeoGetTokenBalances<T: TokenBalances>: Response<T> { }

public protocol TokenBalances: Codable, Hashable {
    
    associatedtype Balance: TokenBalance
    
    var address: String { get }
    var balances: [Balance] { get}
    
}

public protocol TokenBalance: Codable, Hashable {
    
    var assetHash: Hash160 { get }
    
}
