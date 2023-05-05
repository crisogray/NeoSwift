
public class SmartContract {
    
    public static let DEFAULT_ITERATOR_COUNT = 100
    
    internal let scriptHash: Hash160
    internal let neoSwift: NeoSwift
    
    public init(scriptHash: Hash160, neoSwift: NeoSwift) {
        self.scriptHash = scriptHash
        self.neoSwift = neoSwift
    }
    
    public func invokeFunction(_ function: String, _ params: [ContractParameter]) throws -> TransactionBuilder {
        let script = try buildInvokeFunctionScript(function, params)
        return TransactionBuilder(neoSwift).script(script)
    }
    
    public func buildInvokeFunctionScript(_ function: String, _ params: [ContractParameter]) throws -> Bytes {
        guard !function.isEmpty else {
            throw "The invocation function must not be empty."
        }
        return ScriptBuilder().contractCall(scriptHash, method: function, params: params).toArray()
    }
    
    public func callFunctionReturningString(_ function: String, _ params: [ContractParameter] = []) async throws -> String {
        let invocationResult = try await callInvokeFunction(function, params).getResult()
        try throwIfFaultState(invocationResult)
        guard let stackItem = invocationResult.stack.first, case .byteString = stackItem else {
            throw "Got stack item of type \(String(describing: invocationResult.stack.first?.jsonValue)) but expected \(StackItem.BYTE_STRING_VALUE)."
        }
        return stackItem.string!
    }

    public func callFunctionReturningInt(_ function: String, _ params: [ContractParameter] = []) async throws -> Int {
        let invocationResult = try await callInvokeFunction(function, params).getResult()
        try throwIfFaultState(invocationResult)
        guard let stackItem = invocationResult.stack.first, case .integer = stackItem else {
            throw "Got stack item of type \(String(describing: invocationResult.stack.first?.jsonValue)) but expected \(StackItem.INTEGER_VALUE)."
        }
        return stackItem.integer!
    }
    
    public func callFunctionReturningBool(_ function: String, _ params: [ContractParameter] = []) async throws -> Bool {
        let invocationResult = try await callInvokeFunction(function, params).getResult()
        try throwIfFaultState(invocationResult)
        let stackItem = invocationResult.stack.first
        switch stackItem {
        case .boolean, .integer, .byteString, .buffer: return stackItem!.boolean!
        default: throw "Got stack item of type \(String(describing: stackItem?.jsonValue)) but expected \(StackItem.BYTE_STRING_VALUE)."
        }
    }
    
    public func callFunctionReturningScriptHash(_ function: String, _ params: [ContractParameter] = []) async throws -> Hash160 {
        let invocationResult = try await callInvokeFunction(function, params).getResult()
        try throwIfFaultState(invocationResult)
        return try extractScriptHash(invocationResult.stack.first!)
    }
    
    public func extractScriptHash(_ item: StackItem) throws -> Hash160 {
        guard case .byteString = item else {
            throw "Got stack item of type \(item.jsonValue) but expected \(StackItem.BYTE_STRING_VALUE)."
        }
        do {
            return try Hash160(item.hexString!.reversedHex)
        } catch {
            throw "Return type did not contain script hash in expected format. \(error.localizedDescription)"
        }
    }
    
    public func callFunctionReturningIterator<T>(_ function: String, _ params: [ContractParameter] = [], _ mapper: @escaping (StackItem) -> T = { $0 }) async throws -> Iterator<T> {
        let invocationResult = try await callInvokeFunction(function, params).getResult()
        try throwIfFaultState(invocationResult)
        guard let stackItem = invocationResult.stack.first, case .interopInterface = stackItem else {
            throw "Got stack item of type \(String(describing: invocationResult.stack.first?.jsonValue)) but expected \(StackItem.INTEROP_INTERFACE_VALUE)."
        }
        guard let sessionId = invocationResult.sessionId else {
            throw "No session id was found. The connected Neo node might not support sessions."
        }
        return .init(neoSwift: neoSwift, sessionId: sessionId, iteratorId: stackItem.iteratorId!, mapper: mapper)
    }
    
    public func callFunctionAndTraverseIterator<T>(_ maxIteratorResultItems: Int = DEFAULT_ITERATOR_COUNT,_ function: String,
                                                   _ params: [ContractParameter], _ mapper: @escaping (StackItem) -> T = { $0 }) async throws -> [T] {
        let iterator = try await callFunctionReturningIterator(function, params, mapper)
        let iteratorItems = try await iterator.traverse(maxIteratorResultItems)
        try await iterator.terminateSession()
        return iteratorItems
    }
    
    public func callFunctionAndUnwrapIterator(_ function: String, _ params: [ContractParameter], _ maxIteratorResultItems: Int, _ signers: [Signer]) async throws -> [StackItem] {
        let script = ScriptBuilder.buildContractCallAndUnwrapIterator(scriptHash, function, params, maxIteratorResultItems)
        let invocationResult = try await neoSwift.invokeScript(script.toHexString(), signers).send().getResult()
        try throwIfFaultState(invocationResult)
        return invocationResult.stack.first?.list ?? []
    }
    
    public func callInvokeFunction(_ function: String, _ params: [ContractParameter] = [], _ signers: [Signer] = []) async throws -> NeoInvokeFunction {
        guard !function.isEmpty else {
            throw "The invocation function must not be null or empty."
        }
        return try await neoSwift.invokeFunction(scriptHash, function, params, signers).send()
    }
    
    public func throwIfFaultState(_ invocationResult: InvocationResult) throws {
        if invocationResult.hasStateFault {
            throw "The invocation resulted in a FAULT VM state. The VM exited due to the following exception: \(String(describing: invocationResult.exception))"
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
