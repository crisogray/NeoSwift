
public struct NEP6Wallet: Codable, Hashable {
    
    public let name: String
    public let version: String
    public let scrypt: ScryptParams
    public let accounts: [NEP6Account]
    public let extra: [String : AnyHashable]?
    
    public static func == (lhs: NEP6Wallet, rhs: NEP6Wallet) -> Bool {
        return lhs.name == rhs.name && lhs.version == rhs.version && lhs.scrypt == rhs.scrypt && lhs.extra == rhs.extra
        && lhs.accounts.count == rhs.accounts.count && lhs.accounts.allSatisfy(rhs.accounts.contains)
    }
    
}
