
public class Wallet {
    
    private static let DEFAULT_WALLET_NAME = "NeoSwiftWallet"
    public static let CURRENT_VERSION = "3.0"
    
    public private(set) var name: String
    public private(set) var version: String
    public private(set) var scryptParams: ScryptParams
    private var accountsMap: [Hash160: Account] = [:]
    private var defaultAccountHash: Hash160!
    
    public var accounts: [Account] {
        return accountsMap.sorted(by: { return $0.key < $1.key }).map(\.value)
    }
    
    public var defaultAccount: Account? {
        return accountsMap[defaultAccountHash]!
    }
    
    init() {
        name = Wallet.DEFAULT_WALLET_NAME
        version = Wallet.CURRENT_VERSION
        scryptParams = .DEFAULT
    }
    
    public func defaultAccount(_ account: Account) throws -> Wallet {
        return try defaultAccount(account.getScriptHash())
    }
    
    public func defaultAccount(_ accountHash160: Hash160) throws -> Wallet {
        guard accountsMap.keys.contains(accountHash160) else {
            throw "Cannot set default account on wallet. Wallet does not contain the account with script hash \(accountHash160.string)."
        }
        self.defaultAccountHash = accountHash160
        return self
    }
    
    public func isDefault(_ account: Account) -> Bool {
        return isDefault(account.scriptHash)
    }
    
    public func isDefault(_ accountHash: Hash160?) -> Bool {
        return defaultAccount?.scriptHash == accountHash && accountHash != nil
    }
    
    public func name(_ name: String) -> Wallet {
        self.name = name
        return self
    }
    
    public func version(_ version: String) -> Wallet {
        self.version = version
        return self
    }
    
    public func scryptParams(_ scryptParams: ScryptParams) -> Wallet {
        self.scryptParams = scryptParams
        return self
    }
    
    public func addAccounts(_ accounts: [Account]) throws -> Wallet {
        let accounts = try accounts.filter { try !accountsMap.keys.contains($0.getScriptHash()) }
        if let account = accounts.first(where: { $0.wallet != nil }) {
            throw "The account \(account.address) is already contained in a wallet. Please remove this account from its containing wallet before adding it to another wallet."
        }
        try accounts.forEach { account in
            try self.accountsMap[account.getScriptHash()] = account
            _ = account.wallet(self)
        }
        return self
    }
    
    public func removeAccount(_ account: Account) throws -> Bool {
        return try removeAccount(account.getScriptHash())
    }
    
    public func removeAccount(_ accountHash: Hash160) throws -> Bool {
        guard accountsMap.keys.contains(accountHash) else { return false }
        guard accountsMap.count > 1 else {
            throw "The account \(accountHash.toAddress()) is the only account in the wallet. It cannot be removed."
        }
        _ = accountsMap[accountHash]?.wallet(nil)
        if accountHash == defaultAccount?.scriptHash {
            let newDefault = accountsMap.keys.first(where: { $0 != accountHash })!
            try _ = defaultAccount(newDefault)
        }
        return accountsMap.removeValue(forKey: accountHash) != nil
    }
    
    public func decryptAllAccounts(_ password: String) throws {
        try accountsMap.values.forEach { try $0.decryptPrivateKey(password, scryptParams) }
    }
    
    public func encryptAllAccounts(_ password: String) throws {
        try accountsMap.values.forEach { try $0.encryptPrivateKey(password, scryptParams) }
    }
    
    public func toNEP6Wallet() throws -> NEP6Wallet {
        let accounts = try accountsMap.values.map { try $0.toNEP6Account() }
        return .init(name: name, version: version, scrypt: scryptParams, accounts: accounts, extra: nil)
    }
    
    // TODO: NEP6Wallet Methods
    
    public func getNep17TokenBalances(_ neoSwift: NeoSwift) async throws -> [Hash160: Int] {
        var balances: [Hash160: Int] = [:]
        for (_, account) in accountsMap {
            for (key, value) in try await account.getNep17Balances(neoSwift) {
                if balances[key] != nil { balances[key]! += value }
                else { balances[key] = value }
            }
        }
        return balances
    }
    
    public static func create() throws -> Wallet {
        let account = try Account.create()
        return try Wallet().addAccounts([account]).defaultAccount(account.getScriptHash())
    }
    
    public static func create(_ password: String) throws -> Wallet {
        let wallet = try create()
        try wallet.encryptAllAccounts(password)
        return wallet
    }
    
    // TODO: NEP6Wallet create
    
    public static func withAccounts(_ accounts: [Account]) throws -> Wallet {
        guard !accounts.isEmpty else {
            throw "No accounts provided to initialize a wallet."
        }
        return try Wallet().addAccounts(accounts).defaultAccount(accounts.first!.getScriptHash())
    }
    
    public func holdsAccount(_ accountHash: Hash160) -> Bool {
        return accountsMap[accountHash] != nil
    }
    
    public func getAccount(_ accountHash: Hash160) -> Account? {
        return accountsMap[accountHash]
    }
    
}

