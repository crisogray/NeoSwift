
public struct NEP6Wallet: Codable, Hashable {
    
    public let name: String
    public let version: String
    public let scrypt: ScryptParams
    public let accounts: [NEP6Account]
    public let extra: [String : AnyHashable]?

}
