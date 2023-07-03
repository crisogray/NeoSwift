
public struct Nep17Contract: Codable, Hashable {
    
    public let scriptHash: Hash160
    public let symbol: String
    public let decimals: Int
    
    public init(scriptHash: Hash160, symbol: String, decimals: Int) {
        self.scriptHash = scriptHash
        self.symbol = symbol
        self.decimals = decimals
    }
    
}
