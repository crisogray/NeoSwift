
public class FungibleToken: Token {
    
    private static let BALANCE_OF = "balanceOf"
    private static let TRANSFER = "transfer"
    
    public func getBalanceOf(_ account: Account) async throws -> Int {
        return try await getBalanceOf(account.getScriptHash())
    }
    
    public func getBalanceOf(_ scriptHash: Hash160) async throws -> Int {
        return try await callFunctionReturningInt(FungibleToken.BALANCE_OF, [.hash160(scriptHash)])
    }
    
    public func getBalanceOf(_ wallet: Wallet) async throws -> Int {
        var sum = 0
        for account in wallet.accounts { sum += try await getBalanceOf(account) }
        return sum
    }
    
    public func transfer(_ from: Account, _ to: Hash160, _ amount: Int, _ data: ContractParameter? = nil) throws -> TransactionBuilder {
        return try transfer(from.getScriptHash(), to, amount, data).signers([AccountSigner.calledByEntry(from)])
    }
    
    public func transfer(_ from: Hash160, _ to: Hash160, _ amount: Int, _ data: ContractParameter? = nil) throws -> TransactionBuilder {
        guard amount >= 0 else {
            throw NeoSwiftError.illegalArgument("The amount must be greater than or equal to 0.")
        }
        let transferScript = try buildTransferScript(from, to, amount, data)
        return .init(neoSwift).script(transferScript)
    }
    
    public func buildTransferScript(_ from: Hash160, _ to: Hash160, _ amount: Int, _ data: ContractParameter? = nil) throws -> Bytes {
        return try buildInvokeFunctionScript(FungibleToken.TRANSFER, [.hash160(from), .hash160(to), .integer(amount), data])
    }
    
    // MARK: Transfer using NNS
    
    public func transfer(_ from: Account, _ to: NNSName, _ amount: Int, _ data: ContractParameter? = nil) async throws -> TransactionBuilder {
        return try await transfer(from.getScriptHash(), to, amount, data).signers([AccountSigner.calledByEntry(from)])
    }
    
    public func transfer(_ from: Hash160, _ to: NNSName, _ amount: Int, _ data: ContractParameter? = nil) async throws -> TransactionBuilder {
        let scriptHash = try await resolveNNSTextRecord(to)
        return try transfer(from, scriptHash, amount, data)
    }
    
}
