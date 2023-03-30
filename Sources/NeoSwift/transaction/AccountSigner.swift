
public class AccountSigner: Signer {
    
    public let account: Account
    
    private init(_ account: Account, _ scope: WitnessScope) throws {
        self.account = account
        try super.init(account.getScriptHash(), scope)
    }
    
    public static func none(_ account: Account) throws -> AccountSigner {
        return try .init(account, .none)
    }
    
    public static func none(_ accountHash: Hash160) throws -> AccountSigner {
        return try .init(.fromAddress(accountHash.toAddress()), .none)
    }
    
    public static func calledByEntry(_ account: Account) throws -> AccountSigner {
        return try .init(account, .calledByEntry)
    }
    
    public static func calledByEntry(_ accountHash: Hash160) throws -> AccountSigner {
        return try .init(.fromAddress(accountHash.toAddress()), .calledByEntry)
    }
    
    public static func global(_ account: Account) throws -> AccountSigner {
        return try .init(account, .global)
    }
    
    public static func global(_ accountHash: Hash160) throws -> AccountSigner {
        return try .init(.fromAddress(accountHash.toAddress()), .global)
    }
    
}
