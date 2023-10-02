
/// Represents a smart contract on the Neo blockchain and provides methods to invoke and deploy it.
public class SmartContract {
    
    public static let DEFAULT_ITERATOR_COUNT = 100
    
    /// The script hash of this smart contract.
    internal let scriptHash: Hash160
    internal let neoSwift: NeoSwift
    
    /// Constructs a `SmartContract` representing the smart contract with the given script hash. Uses the given ``NeoSwift/NeoSwift`` instance for all invocations.
    /// - Parameters:
    ///   - scriptHash: The smart contract's script's hash
    ///   - neoSwift: The ``NeoSwift/NeoSwift`` instance to use for invocations
    public init(scriptHash: Hash160, neoSwift: NeoSwift) {
        self.scriptHash = scriptHash
        self.neoSwift = neoSwift
    }
    
    /// Initializes a ``TransactionBuilder`` for an invocation of this contract with the provided function and parameters. The order of the parameters is relevant.
    /// - Parameters:
    ///   - function: The function to invoke
    ///   - params: The parameters to pass with the invocation
    /// - Returns: A transaction builder allowing to set further details of the invocation
    public func invokeFunction(_ function: String, _ params: [ContractParameter?]) throws -> TransactionBuilder {
        let script = try buildInvokeFunctionScript(function, params)
        return TransactionBuilder(neoSwift).script(script)
    }
    
    /// Builds a script to invoke a function on this smart contract.
    /// - Parameters:
    ///   - function: The function to invoke
    ///   - params: The parameters to pass with the invocation
    /// - Returns: The script
    public func buildInvokeFunctionScript(_ function: String, _ params: [ContractParameter?]) throws -> Bytes {
        guard !function.isEmpty else {
            throw NeoSwiftError.illegalArgument("The invocation function must not be empty.")
        }
        return try ScriptBuilder().contractCall(scriptHash, method: function, params: params).toArray()
    }
    
    /// Sends an `invokefunction` RPC call to the given contract function expecting a String as return type.
    /// - Parameters:
    ///   - function: The function to call
    ///   - params: The contract parameters to include in the call
    /// - Returns: The string returned by the contract
    public func callFunctionReturningString(_ function: String, _ params: [ContractParameter] = []) async throws -> String {
        let invocationResult = try await callInvokeFunction(function, params).getResult()
        try throwIfFaultState(invocationResult)
        let stackItem = try invocationResult.getFirstStackItem()
        guard case .byteString = stackItem else {
            throw ContractError.unexpectedReturnType(stackItem.jsonValue, [StackItem.BYTE_STRING_VALUE])
        }
        return stackItem.string!
    }
    
    /// Sends an `invokefunction` RPC call to the given contract function expecting an Integer as return type.
    /// - Parameters:
    ///   - function: The function to call
    ///   - params: The contract parameters to include in the call
    /// - Returns: The integer returned by the contract
    public func callFunctionReturningInt(_ function: String, _ params: [ContractParameter] = []) async throws -> Int {
        let invocationResult = try await callInvokeFunction(function, params).getResult()
        try throwIfFaultState(invocationResult)
        let stackItem = try invocationResult.getFirstStackItem()
        guard case .integer = stackItem else {
            throw ContractError.unexpectedReturnType(stackItem.jsonValue, [StackItem.INTEGER_VALUE])
        }
        return stackItem.integer!
    }
    
    /// Sends an `invokefunction` RPC call to the given contract function expecting an Integer as return type.
    /// - Parameters:
    ///   - function: The function to call
    ///   - params: The contract parameters to include in the call
    /// - Returns: The integer returned by the contract
    public func callFunctionReturningBool(_ function: String, _ params: [ContractParameter] = []) async throws -> Bool {
        let invocationResult = try await callInvokeFunction(function, params).getResult()
        try throwIfFaultState(invocationResult)
        let stackItem = try invocationResult.getFirstStackItem()
        switch stackItem {
        case .boolean, .integer, .byteString, .buffer: return stackItem.boolean!
        default: throw ContractError.unexpectedReturnType(stackItem.jsonValue, [StackItem.BYTE_STRING_VALUE])
        }
    }
    
    /// Sends an `invokefunction` RPC call to the given contract function expecting a Boolean as return type.
    /// - Parameters:
    ///   - function: The function to call
    ///   - params: The contract parameters to include in the call
    /// - Returns: The boolean returned by the contract
    public func callFunctionReturningScriptHash(_ function: String, _ params: [ContractParameter] = []) async throws -> Hash160 {
        let invocationResult = try await callInvokeFunction(function, params).getResult()
        try throwIfFaultState(invocationResult)
        return try extractScriptHash(invocationResult.stack.first!)
    }
    
    private func extractScriptHash(_ item: StackItem) throws -> Hash160 {
        guard case .byteString = item else {
            throw ContractError.unexpectedReturnType(item.jsonValue, [StackItem.BYTE_STRING_VALUE])
        }
        do {
            return try Hash160(item.hexString!.reversedHex)
        } catch {
            throw ContractError.unexpectedReturnType("Return type did not contain script hash in expected format. \(error.localizedDescription)")
        }
    }
    
    /// Sends an `invokefunction` RPC call to the given contract function expecting an ``InteropInterfaceStackItem`` as a return type.
    ///
    /// Traverse the returned iterator with ``Iterator/traverse(_:)`` to retrieve the iterator items.
    ///
    /// In order to traverse the returned iterator, sessions need to be enabled on the Neo node. If sessions are disabled on the Neo node, use ``SmartContract/callFunctionAndUnwrapIterator(_:_:_:_:)``.
    /// - Parameters:
    ///   - function: The function to call
    ///   - params: The contract parameters to include in the call
    ///   - mapper: The function to apply on the stack items in the iterator
    /// - Returns: The iterator
    public func callFunctionReturningIterator<T>(_ function: String, _ params: [ContractParameter] = [],
                                                 mapper: @escaping (StackItem) throws -> T = { $0 }) async throws -> Iterator<T> {
        let invocationResult = try await callInvokeFunction(function, params).getResult()
        try throwIfFaultState(invocationResult)
        let stackItem = try invocationResult.getFirstStackItem()
        guard case .interopInterface = stackItem else {
            throw ContractError.unexpectedReturnType(stackItem.jsonValue, [StackItem.INTEROP_INTERFACE_VALUE])
        }
        guard let sessionId = invocationResult.sessionId else {
            throw NeoSwiftError.illegalState("No session id was found. The connected Neo node might not support sessions.")
        }
        return .init(neoSwift: neoSwift, sessionId: sessionId, iteratorId: stackItem.iteratorId!, mapper: mapper)
    }
    
    /// Sends an `invokefunction` RPC call to the given contract function expecting an ``StackItem/interopInterface(_:_:)``  as a return type.
    /// Then, traverses the iterator to retrieve the first ``SmartContract/DEFAULT_ITERATOR_COUNT`` stack items mapped with the provided mapper function.
    ///
    /// Consider that the returned list might be limited in size and not reveal all entries that exist in the iterator.
    ///
    /// This method requires sessions to be enabled on the Neo node. If sessions are disabled on the Neo node, use ``SmartContract/callFunctionAndUnwrapIterator(_:_:_:_:)``
    /// - Parameters:
    ///   - function: The function to call
    ///   - params: The contract parameters to include in the call
    ///   - maxIteratorResultItems: The maximal number of items to return
    ///   - mapper: The function to apply on the stack items in the iterator
    /// - Returns: The mapped iterator items
    public func callFunctionAndTraverseIterator<T>(_ function: String, _ params: [ContractParameter] = [],
                                                   maxIteratorResultItems: Int = DEFAULT_ITERATOR_COUNT,
                                                   mapper: @escaping (StackItem) -> T = { $0 }) async throws -> [T] {
        let iterator = try await callFunctionReturningIterator(function, params, mapper: mapper)
        let iteratorItems = try await iterator.traverse(maxIteratorResultItems)
        try await iterator.terminateSession()
        return iteratorItems
    }
    
    /// Calls `function` of this contract and expects an iterator as the return value.
    /// That iterator is then traversed and its entries are put in an array which is returned.
    /// Note, that this all happens on the NeoVM.
    /// Thus, this method is useful for Neo nodes that don't have iterator sessions enabled.
    /// - Parameters:
    ///   - function: The function to call
    ///   - params: The contract parameters to include in the call
    ///   - maxIteratorResultItems: The maximal number of iterator result items to include in the array. This value must not exceed NeoVM limits.
    ///   - signers: The list of signers for this request
    /// - Returns: A list of stack items of the returned iterator
    public func callFunctionAndUnwrapIterator(_ function: String, _ params: [ContractParameter], _ maxIteratorResultItems: Int, _ signers: [Signer] = []) async throws -> [StackItem] {
        let script = try ScriptBuilder.buildContractCallAndUnwrapIterator(scriptHash, function, params, maxIteratorResultItems)
        let invocationResult = try await neoSwift.invokeScript(script.toHexString(), signers).send().getResult()
        try throwIfFaultState(invocationResult)
        return invocationResult.stack.first?.list ?? []
    }
    
    /// Sends an `invokefunction` RPC call to the given contract function.
    /// - Parameters:
    ///   - function: The function to call
    ///   - params: The contract parameters to include in the call
    ///   - signers: The list of signers for this request
    /// - Returns: The call's response
    public func callInvokeFunction(_ function: String, _ params: [ContractParameter] = [], _ signers: [Signer] = []) async throws -> NeoInvokeFunction {
        guard !function.isEmpty else {
            throw NeoSwiftError.illegalArgument("The invocation function must not be empty.")
        }
        return try await neoSwift.invokeFunction(scriptHash, function, params, signers).send()
    }
    
    internal func throwIfFaultState(_ invocationResult: InvocationResult) throws {
        if invocationResult.hasStateFault {
            throw ProtocolError.invocationFaultState(String(describing: invocationResult.exception))
        }
    }
    
    /// Gets the manifest of this smart contract.
    /// - Returns: The manifest of this smart contract
    public func getManifest() async throws -> ContractManifest {
        return try await neoSwift.getContractState(scriptHash).send().getResult().manifest
    }
    
    /// Gets the name of this smart contract.
    ///
    /// - Returns: The name of this smart contract
    public func getName() async throws -> String? {
        return try await getManifest().name
    }
    
    internal static func calcNativeContractHash(_ contractName: String) throws -> Hash160 {
        return try calcContractHash(.ZERO, 0, contractName)
    }
    
    /// Calculates the hash of the contract deployed by `sender`.
    ///
    ///  A contract's hash doesn't change after deployment. Even if the contract's script is updated the hash stays the same.
    ///  It depends on the initial NEF checksum, contract name, and the sender of the deployment transaction.
    /// - Parameters:
    ///   - sender: The sender of the contract deployment transaction
    ///   - nefCheckkSum: The checksum of the contract's NEF file
    ///   - contractName: The contract's name
    /// - Returns: The hash of the contract
    public static func calcContractHash(_ sender: Hash160, _ nefCheckkSum: Int, _ contractName: String) throws -> Hash160 {
        return try Hash160.fromScript(ScriptBuilder.buildContractHashScript(sender, nefCheckkSum, contractName))
    }
    
}
