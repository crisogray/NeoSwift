
/// Represents a NEP-11 non-fungible token contract and provides methods to invoke it.
public class NonFungibleToken: Token {
    
    private static let OWNER_OF = "ownerOf"
    private static let TOKENS_OF = "tokensOf"
    private static let BALANCE_OF = "balanceOf"
    private static let TRANSFER = "transfer"
    private static let TOKENS = "tokens"
    private static let PROPERTIES = "properties"
    
    /// Constructs a new `NFT` representing the contract with the given script hash. Uses the given ``NeoSwift/NeoSwift`` instance for all invocations.
    /// - Parameters:
    ///   - scriptHash: The token contract's script hash
    ///   - neoSwift: The ``NeoSwift/NeoSwift`` instance to use for invocations
    public override init(scriptHash: Hash160, neoSwift: NeoSwift) { super.init(scriptHash: scriptHash, neoSwift: neoSwift) }
    
    // MARK: Token Methods
    
    /// Gets the total amount of NFTs owned by the `owner`.
    ///
    /// The balance is not cached locally. Every time this method is called requests are sent to the Neo node.
    /// - Parameter owner: The script hash of the account to fetch the balance for
    /// - Returns: The token balance of the given account
    public func balanceOf(_ owner: Hash160) async throws -> Int {
        return try await callFunctionReturningInt(NonFungibleToken.BALANCE_OF, [.hash160(owner)])
    }
    
    // MARK: NFT Methods
    
    /// Gets an iterator over the token ids of the tokens that are owned by the `owner`.
    /// - Parameter owner: The owner of the tokens
    /// - Returns: A list of token ids that are owned by the specified owner
    public func tokensOf(_ owner: Hash160) async throws -> Iterator<Bytes> {
        return try await callFunctionReturningIterator(NonFungibleToken.TOKENS_OF, [.hash160(owner)], mapper: { try $0.getByteArray() })
    }
    
    // MARK: Non-divisible NFT Methods
    
    /// Creates a transaction script to transfer a non-fungible token and initializes a `TransactionBuilder` based on this script.
    ///
    /// The token owner is set as signer of the transaction. The returned builder is ready to be signed and sent.
    ///
    /// This method is intended to be used for non-divisible NFTs only.
    /// - Parameters:
    ///   - from: The account of the token owner
    ///   - to: The receiver of the token owner
    ///   - tokenId: The token id
    ///   - data: The data that is passed to the `onNEP11Payment` method of the receiving smart contract
    /// - Returns: A transaction builder
    public func transfer(_ from: Account, _ to: Hash160, _ tokenId: Bytes, _ data: ContractParameter? = nil) async throws -> TransactionBuilder {
        return try await transfer(to, tokenId, data).signers(AccountSigner.calledByEntry(from))
    }
    
    /// Creates a transaction script to transfer a non-fungible token and initializes a ``TransactionBuilder`` based on this script.
    ///
    /// No signers are set on the returned transaction builder. It is up to you to set the correct ones, e.g., a ``ContractSigner`` in case the owner is a contract.
    ///
    /// This method is intended to be used for non-divisible NFTs only.
    /// - Parameters:
    ///   - to: The receiver of the token owner
    ///   - tokenId: The token id
    ///   - data: The data that is passed to the `onNEP11Payment` method of the receiving smart contract
    /// - Returns: A transaction builder
    public func transfer(_ to: Hash160, _ tokenId: Bytes, _ data: ContractParameter? = nil) async throws -> TransactionBuilder {
        try await throwIfDivisibleNFT()
        return try invokeFunction(NonFungibleToken.TRANSFER, [.hash160(to), .byteArray(tokenId), data])
    }
    
    /// Creates a transaction script to transfer a non-fungible token and initializes a ``TransactionBuilder`` based on this script.
    ///
    /// Resolves the text record of the recipient's NNS domain name. The resolved value is expected to be a valid Neo address.
    ///
    /// The token owner is set as signer of the transaction. The returned builder is ready to be signed and sent.
    ///
    /// This method is intended to be used for non-divisible NFTs only.
    /// - Parameters:
    ///   - from: The account of the token owner
    ///   - to: The NNS domain name to resolve
    ///   - tokenId: The token id
    ///   - data: The data that is passed to the `onNEP11Payment` method of the receiving smart contract.
    /// - Returns: A transaction builder
    public func transfer(_ from: Account, _ to: NNSName, _ tokenId: Bytes, _ data: ContractParameter? = nil) async throws -> TransactionBuilder {
        try await throwIfSenderIsNotOwner(from.getScriptHash(), tokenId)
        return try await transfer(to, tokenId, data).signers(AccountSigner.calledByEntry(from))
    }
    
    /// Creates a transaction script to transfer a non-fungible token and initializes a ``TransactionBuilder`` based on this script.
    ///
    /// Resolves the text record of the recipient's NNS domain name. The resolved value is expected to be a valid Neo address.
    ///
    /// No signers are set on the returned transaction builder. It is up to you to set the correct ones, e.g., a ``ContractSigner`` in case the owner is a contract.
    ///
    /// This method is intended to be used for non-divisible NFTs only.
    /// - Parameters:
    ///   - to: The NNS domain name to resolve
    ///   - tokenId: The token id
    ///   - data: The data that is passed to the `onNEP11Payment` method if the receiver is a smart contract
    /// - Returns: A transaction builder
    public func transfer(_ to: NNSName, _ tokenId: Bytes, _ data: ContractParameter? = nil) async throws -> TransactionBuilder {
        try await throwIfDivisibleNFT()
        return try await transfer(resolveNNSTextRecord(to), tokenId, data)
    }
    
    /// Builds a script that invokes the transfer method on this non-fungible token.
    ///
    /// This method is intended to be used for non-divisible NFTs only.
    /// - Parameters:
    ///   - to: The recipient
    ///   - tokenId: The token id
    ///   - data: The data that is passed to the `onPayment` method if the recipient is a contract
    /// - Returns: A transfer script
    public func buildNonDivisibleTransferScript(_ to: Hash160, _ tokenId: Bytes, _ data: ContractParameter) async throws -> Bytes {
        try await throwIfDivisibleNFT()
        return try buildInvokeFunctionScript(NonFungibleToken.TRANSFER, [.hash160(to), .byteArray(tokenId), data])
    }
    
    /// Gets the owner of the token with `tokenId`.
    ///
    /// This method is intended to be used for non-divisible NFTs only.
    /// - Parameter tokenId: The token id
    /// - Returns: The token owner
    public func ownerOf(_ tokenId: Bytes) async throws -> Hash160 {
        try await throwIfDivisibleNFT()
        return try await callFunctionReturningScriptHash(NonFungibleToken.OWNER_OF, [.byteArray(tokenId)])
    }
    
    private func throwIfDivisibleNFT() async throws {
        if try await getDecimals() != 0 {
            throw NeoSwiftError.illegalState("This method is only intended for non-divisible NFTs.")
        }
    }
    
    private func throwIfSenderIsNotOwner(_ from: Hash160, _ tokenId: Bytes) async throws {
        let tokenOwner = try await ownerOf(tokenId)
        if tokenOwner != from {
            throw NeoSwiftError.illegalArgument("The provided from account is not the owner of this token.")
        }
    }
    
    // MARK: Divisible NFT Methods
    
    /// Creates a transaction script to transfer an amount of a divisible non-fungible token and initializes a ``TransactionBuilder`` based on this script.
    ///
    /// The sender is set as a `calledByEntry` signer of the transaction. The returned builder is ready to be signed and sent.
    ///
    /// This method is intended to be used for divisible NFTs only.
    /// - Parameters:
    ///   - from: The sender of the token amount
    ///   - to: The receiver of the token amount
    ///   - amount: The fraction amount to transfer
    ///   - tokenId: The token id
    ///   - data: The data that is passed to the `onNEP11Payment` method if the receiver is a smart contract
    /// - Returns: A transaction builder
    public func transfer(_ from: Account, _ to: Hash160, _ amount: Int, _ tokenId: Bytes, _ data: ContractParameter? = nil) async throws -> TransactionBuilder {
        return try await transfer(from.getScriptHash(), to, amount, tokenId, data).signers(AccountSigner.calledByEntry(from))
    }
    
    /// Creates a transaction script to transfer an amount of a divisible non-fungible token and initializes a ``TransactionBuilder`` based on this script.
    ///
    /// No signers are set on the returned transaction builder. It is up to you to set the correct ones, e.g., a ``ContractSigner`` in case the `from` address is a contract.
    ///
    /// This method is intended to be used for divisible NFTs only.
    /// - Parameters:
    ///   - from: The sender of the token amount
    ///   - to: The receiver of the token amount
    ///   - amount: The fraction amount to transfer
    ///   - tokenId: The token id
    ///   - data: The data that is passed to the `onNEP11Payment` method if the receiver is a smart contract
    /// - Returns: A transaction builder
    public func transfer(_ from: Hash160, _ to: Hash160, _ amount: Int, _ tokenId: Bytes, _ data: ContractParameter? = nil) async throws -> TransactionBuilder {
        try await throwIfNonDivisibleNFT()
        return try invokeFunction(NonFungibleToken.TRANSFER, [.hash160(from), .hash160(to), .integer(amount), .byteArray(tokenId), data])
    }
    
    /// Creates a transaction script to transfer an amount of a divisible non-fungible token and initializes a ``TransactionBuilder`` based on this script.
    ///
    /// The sender is set as a `calledByEntry` signer of the transaction. The returned builder is ready to be signed and sent.
    ///
    /// This method is intended to be used for divisible NFTs only.
    /// - Parameters:
    ///   - from: The sender of the token amount
    ///   - to: The receiver of the token amount
    ///   - amount: The fraction amount to transfer
    ///   - tokenId: The token id
    ///   - data: The data that is passed to the `onNEP11Payment` method if the receiver is a smart contract
    /// - Returns: A transaction builder
    public func transfer(_ from: Account, _ to: NNSName, _ amount: Int, _ tokenId: Bytes, _ data: ContractParameter? = nil) async throws -> TransactionBuilder {
        return try await transfer(from.getScriptHash(), to, amount, tokenId, data).signers(AccountSigner.calledByEntry(from))
    }
    
    /// Creates a transaction script to transfer an amount of a divisible non-fungible token and initializes a ``TransactionBuilder`` based on this script.
    ///
    /// No signers are set on the returned transaction builder. It is up to you to set the correct ones, e.g., a ``ContractSigner`` in case the `from` address is a contract.
    ///
    /// This method is intended to be used for divisible NFTs only.
    /// - Parameters:
    ///   - from: The sender of the token amount
    ///   - to: The receiver of the token amount
    ///   - amount: The fraction amount to transfer
    ///   - tokenId: The token id
    ///   - data: The data that is passed to the `onNEP11Payment` method if the receiver is a smart contract
    /// - Returns: A transaction builder
    public func transfer(_ from: Hash160, _ to: NNSName, _ amount: Int, _ tokenId: Bytes, _ data: ContractParameter? = nil) async throws -> TransactionBuilder {
        try await throwIfNonDivisibleNFT()
        return try await transfer(from, resolveNNSTextRecord(to), amount, tokenId, data)
    }
    
    /// Builds a script that invokes the transfer method on this non-fungible token.
    ///
    /// This method is intended to be used for divisible NFTs only.
    /// - Parameters:
    ///   - from: The sender
    ///   - to: The recipient
    ///   - amount: The amount to transfer
    ///   - tokenId: The token id
    ///   - data: The data that is passed to the `onPayment` method if the recipient is a smart contract
    /// - Returns: A transfer script
    public func buildDivisibleTransferScript(_ from: Hash160, _ to: Hash160, _ amount: Int, _ tokenId: Bytes, _ data: ContractParameter? = nil) throws -> Bytes {
        return try buildInvokeFunctionScript(NonFungibleToken.TRANSFER, [.hash160(from), .hash160(to), .integer(amount), .byteArray(tokenId), data])
    }
    
    /// Gets an iterator of the owners of the token with `tokenId`.
    ///
    /// Traverse the returned iterator with ``Iterator/traverse(_:)`` to retrieve the owners.
    ///
    /// This method is intended to be used for divisible NFTs only.
    /// - Parameter tokenId: The token id
    /// - Returns: A list of owners of the token.
    public func ownersOf(_ tokenId: Bytes) async throws -> Iterator<Hash160> {
        try await throwIfNonDivisibleNFT()
        return try await callFunctionReturningIterator(NonFungibleToken.OWNER_OF, [.byteArray(tokenId)], mapper: { try Hash160.fromAddress($0.address!) })
    }
    
    private func throwIfNonDivisibleNFT() async throws {
        if try await getDecimals() == 0 {
            throw NeoSwiftError.illegalState("This method is only intended for divisible NFTs.")
        }
    }
    
    /// Gets the balance of the token with `tokenId` for the given account.
    ///
    /// The balance is returned in token fractions. E.g., a balance of 0.5 of a token with 2 decimals is returned as 50 (0.5 * 10^2) token fractions.
    ///
    /// The balance is not cached locally. Every time this method is called requests are sent to the Neo node.
    ///
    /// This method is intended to be used for divisible NFTs only.
    /// - Parameters:
    ///   - owner: The script hash of the account to fetch the balance for
    ///   - tokenID: The token id
    /// - Returns: The token balance of the given account
    public func balanceOf(_ owner: Hash160, _ tokenID: Bytes) async throws -> Int {
        try await throwIfNonDivisibleNFT()
        return try await callFunctionReturningInt(NonFungibleToken.BALANCE_OF, [.hash160(owner), .byteArray(tokenID)])
    }
    
    // MARK: Optional Methods
    
    /// Gets an iterator of the tokens that exist on this contract.
    ///
    /// Traverse the returned iterator with ``Iterator/traverse(_:)`` to retrieve the owners.
    ///
    /// This method is optional for the NEP-11 standard.
    /// - Returns: An iterator of the tokens that exist on this contract
    public func tokens() async throws -> Iterator<Bytes> {
        return try await callFunctionReturningIterator(NonFungibleToken.TOKENS, [], mapper: { try $0.getByteArray() })
    }
    
    /// Gets the properties of the token with `tokenId`.
    ///
    /// This method is optional for the NEP-11 standard.
    ///
    /// Use this method if the token's properties only contain `String` values. For custom value types, use the method ``customProperties(_:)``.
    /// - Parameter tokenId: The token id
    /// - Returns: The properties of the token
    public func properties(_ tokenId: Bytes) async throws -> [String : String] {
        let invocationResult = try await callInvokeFunction(NonFungibleToken.PROPERTIES, [.byteArray(tokenId)]).getResult()
        return try deserializeProperties(mapStackItem(invocationResult))
    }
    
    /// Gets the properties of the token with `tokenId`.
    ///
    /// This method is optional for the NEP-11 standard.
    ///
    /// Use this method to handle custom value types in the token's property values.
    /// - Parameter tokenId: The token id
    /// - Returns: The properties of the token
    public func customProperties(_ tokenId: Bytes) async throws -> [String : StackItem] {
        let invocationResult = try await callInvokeFunction(NonFungibleToken.PROPERTIES, [.byteArray(tokenId)]).getResult()
        return try deserializeProperties(mapStackItem(invocationResult), isClass: true)
    }
    
    private func deserializeProperties<T>(_ stackItem: StackItem, isClass: Bool = false) throws -> [String : T] {
        return try stackItem.map!.reduce(into: .init()) { partialResult, keyValue in
            if case .any(let v) = keyValue.value, v == nil { return }
            try partialResult[keyValue.key.getString()] = (isClass ? keyValue.value as! T : keyValue.value.getString() as! T)
        }
    }
    
    // MARK: Helpers
    
    internal func mapStackItem(_ invocationResult: InvocationResult) throws -> StackItem {
        let stackItem = try invocationResult.getFirstStackItem()
        guard case .map = stackItem else {
            throw ContractError.unexpectedReturnType(stackItem.jsonValue, [StackItem.MAP_VALUE])
        }
        return stackItem
    }
    
}
