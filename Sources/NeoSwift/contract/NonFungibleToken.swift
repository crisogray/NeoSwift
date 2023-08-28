
public class NonFungibleToken: Token {
    
    private static let OWNER_OF = "ownerOf"
    private static let TOKENS_OF = "tokensOf"
    private static let BALANCE_OF = "balanceOf"
    private static let TRANSFER = "transfer"
    private static let TOKENS = "tokens"
    private static let PROPERTIES = "properties"

    // MARK: Token Methods
    
    public func balanceOf(_ owner: Hash160) async throws -> Int {
        return try await callFunctionReturningInt(NonFungibleToken.BALANCE_OF, [.hash160(owner)])
    }
    
    // MARK: NFT Methods
    
    public func tokensOf(_ owner: Hash160) async throws -> Iterator<Bytes> {
        return try await callFunctionReturningIterator(NonFungibleToken.TOKENS_OF, [.hash160(owner)], mapper: { try $0.getByteArray() })
    }
    
    // MARK: Non-divisible NFT Methods
    
    public func transfer(_ from: Account, _ to: Hash160, _ tokenId: Bytes, _ data: ContractParameter? = nil) async throws -> TransactionBuilder {
        return try await transfer(to, tokenId, data).signers(AccountSigner.calledByEntry(from))
    }
    
    public func transfer(_ to: Hash160, _ tokenId: Bytes, _ data: ContractParameter? = nil) async throws -> TransactionBuilder {
        try await throwIfDivisibleNFT()
        return try invokeFunction(NonFungibleToken.TRANSFER, [.hash160(to), .byteArray(tokenId), data])
    }
    
    public func transfer(_ from: Account, _ to: NNSName, _ tokenId: Bytes, _ data: ContractParameter? = nil) async throws -> TransactionBuilder {
        try await throwIfSenderIsNotOwner(from.getScriptHash(), tokenId)
        return try await transfer(to, tokenId, data).signers(AccountSigner.calledByEntry(from))
    }
    
    public func transfer(_ to: NNSName, _ tokenId: Bytes, _ data: ContractParameter? = nil) async throws -> TransactionBuilder {
        try await throwIfDivisibleNFT()
        return try await transfer(resolveNNSTextRecord(to), tokenId, data)
    }
    
    public func buildNonDivisibleTransferScript(_ to: Hash160, _ tokenId: Bytes, _ data: ContractParameter) async throws -> Bytes {
        try await throwIfDivisibleNFT()
        return try buildInvokeFunctionScript(NonFungibleToken.TRANSFER, [.hash160(to), .byteArray(tokenId), data])
    }
    
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
    
    public func transfer(_ from: Account, _ to: Hash160, _ amount: Int, _ tokenId: Bytes, _ data: ContractParameter? = nil) async throws -> TransactionBuilder {
        return try await transfer(from.getScriptHash(), to, amount, tokenId, data).signers(AccountSigner.calledByEntry(from))
    }
    
    public func transfer(_ from: Hash160, _ to: Hash160, _ amount: Int, _ tokenId: Bytes, _ data: ContractParameter? = nil) async throws -> TransactionBuilder {
        try await throwIfNonDivisibleNFT()
        return try invokeFunction(NonFungibleToken.TRANSFER, [.hash160(from), .hash160(to), .integer(amount), .byteArray(tokenId), data])
    }
    
    public func transfer(_ from: Account, _ to: NNSName, _ amount: Int, _ tokenId: Bytes, _ data: ContractParameter? = nil) async throws -> TransactionBuilder {
        return try await transfer(from.getScriptHash(), to, amount, tokenId, data).signers(AccountSigner.calledByEntry(from))
    }
    
    public func transfer(_ from: Hash160, _ to: NNSName, _ amount: Int, _ tokenId: Bytes, _ data: ContractParameter? = nil) async throws -> TransactionBuilder {
        try await throwIfNonDivisibleNFT()
        return try await transfer(from, resolveNNSTextRecord(to), amount, tokenId, data)
    }
    
    public func buildDivisibleTransferScript(_ from: Hash160, _ to: Hash160, _ amount: Int, _ tokenId: Bytes, _ data: ContractParameter? = nil) throws -> Bytes {
        return try buildInvokeFunctionScript(NonFungibleToken.TRANSFER, [.hash160(from), .hash160(to), .integer(amount), .byteArray(tokenId), data])
    }
    
    public func ownersOf(_ tokenId: Bytes) async throws -> Iterator<Hash160> {
        try await throwIfNonDivisibleNFT()
        return try await callFunctionReturningIterator(NonFungibleToken.OWNER_OF, [.byteArray(tokenId)], mapper: { try Hash160.fromAddress($0.address!) })
    }
    
    private func throwIfNonDivisibleNFT() async throws {
        if try await getDecimals() == 0 {
            throw NeoSwiftError.illegalState("This method is only intended for divisible NFTs.")
        }
    }
    
    public func balanceOf(_ owner: Hash160, _ tokenID: Bytes) async throws -> Int {
        try await throwIfNonDivisibleNFT()
        return try await callFunctionReturningInt(NonFungibleToken.BALANCE_OF, [.hash160(owner), .byteArray(tokenID)])
    }
    
    // MARK: Optional Methods
    
    public func tokens() async throws -> Iterator<Bytes> {
        return try await callFunctionReturningIterator(NonFungibleToken.TOKENS, [], mapper: { try $0.getByteArray() })
    }
    
    public func properties(_ tokenId: Bytes) async throws -> [String : String] {
        let invocationResult = try await callInvokeFunction(NonFungibleToken.PROPERTIES, [.byteArray(tokenId)]).getResult()
        return try deserializeProperties(mapStackItem(invocationResult))
    }
    
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
