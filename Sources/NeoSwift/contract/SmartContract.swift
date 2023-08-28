
public class SmartContract {
    
    public static let DEFAULT_ITERATOR_COUNT = 100
    
    internal let scriptHash: Hash160
    internal let neoSwift: NeoSwift
    
    public init(scriptHash: Hash160, neoSwift: NeoSwift) {
        self.scriptHash = scriptHash
        self.neoSwift = neoSwift
    }
    
    public func invokeFunction(_ function: String, _ params: [ContractParameter?]) throws -> TransactionBuilder {
        let script = try buildInvokeFunctionScript(function, params)
        return TransactionBuilder(neoSwift).script(script)
    }
    
    public func buildInvokeFunctionScript(_ function: String, _ params: [ContractParameter?]) throws -> Bytes {
        guard !function.isEmpty else {
            throw NeoSwiftError.illegalArgument("The invocation function must not be empty.")
        }
        return try ScriptBuilder().contractCall(scriptHash, method: function, params: params).toArray()
    }
    
    public func callFunctionReturningString(_ function: String, _ params: [ContractParameter] = []) async throws -> String {
        let invocationResult = try await callInvokeFunction(function, params).getResult()
        try throwIfFaultState(invocationResult)
        let stackItem = try invocationResult.getFirstStackItem()
        guard case .byteString = stackItem else {
            throw ContractError.unexpectedReturnType(stackItem.jsonValue, [StackItem.BYTE_STRING_VALUE])
        }
        return stackItem.string!
    }

    public func callFunctionReturningInt(_ function: String, _ params: [ContractParameter] = []) async throws -> Int {
        let invocationResult = try await callInvokeFunction(function, params).getResult()
        try throwIfFaultState(invocationResult)
        let stackItem = try invocationResult.getFirstStackItem()
        guard case .integer = stackItem else {
            throw ContractError.unexpectedReturnType(stackItem.jsonValue, [StackItem.INTEGER_VALUE])
        }
        return stackItem.integer!
    }
    
    public func callFunctionReturningBool(_ function: String, _ params: [ContractParameter] = []) async throws -> Bool {
        let invocationResult = try await callInvokeFunction(function, params).getResult()
        try throwIfFaultState(invocationResult)
        let stackItem = try invocationResult.getFirstStackItem()
        switch stackItem {
        case .boolean, .integer, .byteString, .buffer: return stackItem.boolean!
        default: throw ContractError.unexpectedReturnType(stackItem.jsonValue, [StackItem.BYTE_STRING_VALUE])
        }
    }
    
    public func callFunctionReturningScriptHash(_ function: String, _ params: [ContractParameter] = []) async throws -> Hash160 {
        let invocationResult = try await callInvokeFunction(function, params).getResult()
        try throwIfFaultState(invocationResult)
        return try extractScriptHash(invocationResult.stack.first!)
    }
    
    public func extractScriptHash(_ item: StackItem) throws -> Hash160 {
        guard case .byteString = item else {
            throw ContractError.unexpectedReturnType(item.jsonValue, [StackItem.BYTE_STRING_VALUE])
        }
        do {
            return try Hash160(item.hexString!.reversedHex)
        } catch {
            throw ContractError.unexpectedReturnType("Return type did not contain script hash in expected format. \(error.localizedDescription)")
        }
    }
    
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
    
    public func callFunctionAndTraverseIterator<T>(_ function: String, _ params: [ContractParameter] = [],
                                                   maxIteratorResultItems: Int = DEFAULT_ITERATOR_COUNT,
                                                   mapper: @escaping (StackItem) -> T = { $0 }) async throws -> [T] {
        let iterator = try await callFunctionReturningIterator(function, params, mapper: mapper)
        let iteratorItems = try await iterator.traverse(maxIteratorResultItems)
        try await iterator.terminateSession()
        return iteratorItems
    }
    
    public func callFunctionAndUnwrapIterator(_ function: String, _ params: [ContractParameter], _ maxIteratorResultItems: Int, _ signers: [Signer] = []) async throws -> [StackItem] {
        let script = try ScriptBuilder.buildContractCallAndUnwrapIterator(scriptHash, function, params, maxIteratorResultItems)
        let invocationResult = try await neoSwift.invokeScript(script.toHexString(), signers).send().getResult()
        try throwIfFaultState(invocationResult)
        return invocationResult.stack.first?.list ?? []
    }
    
    public func callInvokeFunction(_ function: String, _ params: [ContractParameter] = [], _ signers: [Signer] = []) async throws -> NeoInvokeFunction {
        guard !function.isEmpty else {
            throw NeoSwiftError.illegalArgument("The invocation function must not be empty.")
        }
        return try await neoSwift.invokeFunction(scriptHash, function, params, signers).send()
    }
    
    public func throwIfFaultState(_ invocationResult: InvocationResult) throws {
        if invocationResult.hasStateFault {
            throw ProtocolError.invocationFaultState(String(describing: invocationResult.exception))
        }
    }
    
    public func getManifest() async throws -> ContractManifest {
        return try await neoSwift.getContractState(scriptHash).send().getResult().manifest
    }
    
    public func getName() async throws -> String? {
        return try await getManifest().name
    }
    
    public static func calcNativeContractHash(_ contractName: String) throws -> Hash160 {
        return try calcContractHash(.ZERO, 0, contractName)
    }
    
    public static func calcContractHash(_ sender: Hash160, _ nefCheckkSum: Int, _ contractName: String) throws -> Hash160 {
        return try Hash160.fromScript(ScriptBuilder.buildContractHashScript(sender, nefCheckkSum, contractName))
    }
    
}
