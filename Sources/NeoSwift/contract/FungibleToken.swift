
/// Represents a fungible token contract that is compliant with the NEP-17 standard and provides methods to invoke it.
public class FungibleToken: Token {
    
    private static let BALANCE_OF = "balanceOf"
    private static let TRANSFER = "transfer"
    
    /// Gets the token balance for the given account.
    ///
    /// The token amount is returned in token fractions. E.g., an amount of 1 GAS is returned as 1*10^8 GAS fractions.
    /// The balance is not cached locally. Every time this method is called requests are sent to the Neo node.
    /// - Parameter account: The account to fetch the balance for
    /// - Returns: The token balance
    public func getBalanceOf(_ account: Account) async throws -> Int {
        return try await getBalanceOf(account.getScriptHash())
    }
    
    /// Gets the token balance for the given account script hash.
    ///
    /// The token amount is returned in token fractions. E.g., an amount of 1 GAS is returned as 1*10^8 GAS fractions.
    /// The balance is not cached locally. Every time this method is called requests are sent to the Neo node.
    /// - Parameter scriptHash: The script hash to fetch the balance for
    /// - Returns: The token balance
    public func getBalanceOf(_ scriptHash: Hash160) async throws -> Int {
        return try await callFunctionReturningInt(FungibleToken.BALANCE_OF, [.hash160(scriptHash)])
    }
    
    /// Gets the token balance for the given wallet, i.e., all accounts in the wallet.
    ///
    /// The token amount is returned in token fractions. E.g., an amount of 1 GAS is returned as 1*10^8 GAS fractions.
    /// The balance is not cached locally. Every time this method is called requests are sent to the Neo node.
    /// - Parameter wallet: The wallet to fetch the balance for
    /// - Returns: The token balance
    public func getBalanceOf(_ wallet: Wallet) async throws -> Int {
        var sum = 0
        for account in wallet.accounts { sum += try await getBalanceOf(account) }
        return sum
    }
    
    /// Creates a transfer transaction. The `from` account is set as a signer of the transaction.
    ///
    /// Only use this method when the recipient is a deployed smart contract to avoid unnecessary additional fees.
    /// Otherwise, use the method without a contract parameter for data.
    /// - Parameters:
    ///   - from: The sender account
    ///   - to: The script hash of the recipient
    ///   - amount: The amount to transfer in token fractions
    ///   - data: The data that is passed to the `onPayment` method if the recipient is a contract
    /// - Returns: A transaction builder ready for signing
    public func transfer(_ from: Account, _ to: Hash160, _ amount: Int, _ data: ContractParameter? = nil) throws -> TransactionBuilder {
        return try transfer(from.getScriptHash(), to, amount, data).signers([AccountSigner.calledByEntry(from)])
    }
    
    /// Creates a transfer transaction. The `from` account is set as a signer of the transaction.
    ///
    /// No signers are set on the returned transaction builder. It is up to you to set the correct ones,
    /// e.g., a ``ContractSigner`` in case the `from` address is a contract.
    /// - Parameters:
    ///   - from: The script hash of the sender
    ///   - to: The script hash of the recipient
    ///   - amount: The amount to transfer in token fractions
    ///   - data: The data that is passed to the `onPayment` method if the recipient is a contract
    /// - Returns: A transaction builder ready for signing
    public func transfer(_ from: Hash160, _ to: Hash160, _ amount: Int, _ data: ContractParameter? = nil) throws -> TransactionBuilder {
        guard amount >= 0 else {
            throw NeoSwiftError.illegalArgument("The amount must be greater than or equal to 0.")
        }
        let transferScript = try buildTransferScript(from, to, amount, data)
        return .init(neoSwift).script(transferScript)
    }
    
    /// Builds a script that invokes the transfer method on the fungible token.
    /// - Parameters:
    ///   - from: The sender
    ///   - to: The recipient
    ///   - amount: The transfer amount
    ///   - data: The data that is passed to the `onPayment` method if the recipient is a contract
    /// - Returns: A transfer script
    public func buildTransferScript(_ from: Hash160, _ to: Hash160, _ amount: Int, _ data: ContractParameter? = nil) throws -> Bytes {
        return try buildInvokeFunctionScript(FungibleToken.TRANSFER, [.hash160(from), .hash160(to), .integer(amount), data])
    }
    
    // MARK: Transfer using NNS
    
    /// Creates a transfer transaction.
    ///
    /// Resolves the text record of the recipient's NNS domain name. The resolved value is expected to be a valid Neo address.
    /// The `from` account is set as a signer of the transaction.
    /// Only use this method when the recipient is a deployed smart contract to avoid unnecessary additional fees.
    /// Otherwise, use the method without a contract parameter for data.
    /// - Parameters:
    ///   - from: The sender account
    ///   - to: The NNS domain name to resolve
    ///   - amount: The amount to transfer in token fractions
    ///   - data: The data that is passed to the `onPayment` method if the recipient is a contract
    /// - Returns: A transaction builder ready for signing
    public func transfer(_ from: Account, _ to: NNSName, _ amount: Int, _ data: ContractParameter? = nil) async throws -> TransactionBuilder {
        return try await transfer(from.getScriptHash(), to, amount, data).signers([AccountSigner.calledByEntry(from)])
    }
    
    // MARK: Transfer using NNS
    
    /// Creates a transfer transaction.
    ///
    /// No signers are set on the returned transaction builder. It is up to you to set the correct ones,
    /// e.g., a ``ContractSigner`` in case the `from` address is a contract.
    /// - Parameters:
    ///   - from: The sender hash
    ///   - to: The NNS domain name to resolve
    ///   - amount: The amount to transfer in token fractions
    ///   - data: The data that is passed to the `onPayment` method if the recipient is a contract
    /// - Returns: A transaction builder ready for signing
    public func transfer(_ from: Hash160, _ to: NNSName, _ amount: Int, _ data: ContractParameter? = nil) async throws -> TransactionBuilder {
        let scriptHash = try await resolveNNSTextRecord(to)
        return try transfer(from, scriptHash, amount, data)
    }
    
}
