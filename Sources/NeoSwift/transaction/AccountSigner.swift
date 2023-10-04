
/// A signer of a transaction. It defines a in which scope the witness/signature of an account is valid, i.e., which contracts can use the witness in an invocation.
public class AccountSigner: Signer {
    
    /// The account of this signer
    public let account: Account
    
    private init(_ account: Account, _ scope: WitnessScope) throws {
        self.account = account
        try super.init(account.getScriptHash(), scope)
    }
    
    /// Creates a signer for the given account with no witness scope ``WitnessScope/none``.
    ///
    /// The signature of this signer is only used for transactions and is disabled in contracts.
    /// - Parameter account: The signer account
    /// - Returns: The signer
    public static func none(_ account: Account) throws -> AccountSigner {
        return try .init(account, .none)
    }
    
    /// Creates a signer for the given account with no witness scope ``WitnessScope/none``.
    ///
    /// The signature of this signer is only used for transactions and is disabled in contracts.
    /// - Parameter account: The script hash of the signer account
    /// - Returns: The signer
    public static func none(_ accountHash: Hash160) throws -> AccountSigner {
        return try .init(.fromAddress(accountHash.toAddress()), .none)
    }
    
    /// Creates a signer for the given account with a scope ``WitnessScope/calledByEntry`` that only allows the entry point contract to use this signer's witness.
    /// - Parameter account: The signer account
    /// - Returns: The signer
    public static func calledByEntry(_ account: Account) throws -> AccountSigner {
        return try .init(account, .calledByEntry)
    }
    
    /// Creates a signer for the given account with a scope ``WitnessScope/calledByEntry`` that only allows the entry point contract to use this signer's witness.
    /// - Parameter account: The script hash of the signer account
    /// - Returns: The signer
    public static func calledByEntry(_ accountHash: Hash160) throws -> AccountSigner {
        return try .init(.fromAddress(accountHash.toAddress()), .calledByEntry)
    }
    
    /// Creates a signer for the given account with global witness scope ``WitnessScope/global``.
    /// - Parameter account: The account
    /// - Returns: The signer
    public static func global(_ account: Account) throws -> AccountSigner {
        return try .init(account, .global)
    }
    
    /// Creates a signer for the given account with global witness scope ``WitnessScope/global``.
    /// - Parameter account: The script hash of the signer account
    /// - Returns: The signer
    public static func global(_ accountHash: Hash160) throws -> AccountSigner {
        return try .init(.fromAddress(accountHash.toAddress()), .global)
    }
    
}
