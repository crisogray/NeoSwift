
public class ContractManagement: SmartContract {
    
    private static let NAME = "ContractManagement"
    public static var SCRIPT_HASH = {
        try! calcNativeContractHash(NAME)
    }()

    private static let GET_MINIMUM_DEPLOYMENT_FEE = "getMinimumDeploymentFee"
    private static let SET_MINIMUM_DEPLOYMENT_FEE = "setMinimumDeploymentFee"
    private static let GET_CONTRACT_BY_ID = "getContractById"
    private static let GET_CONTRACT_HASHES = "getContractHashes"
    private static let HAS_METHOD = "hasMethod"
    private static let DEPLOY = "deploy"
    
    public init(_ neoSwift: NeoSwift) {
        super.init(scriptHash: ContractManagement.SCRIPT_HASH, neoSwift: neoSwift)
    }
    
    public func getMinimumDeploymentFee() async throws -> Int {
        return try await callFunctionReturningInt(ContractManagement.GET_MINIMUM_DEPLOYMENT_FEE)
    }
    
    public func setMinimumDeploymentFee(_ minimumFee: Int) async throws -> Int {
        return try await callFunctionReturningInt(ContractManagement.SET_MINIMUM_DEPLOYMENT_FEE, [.integer(minimumFee)])
    }
    
    public func getContract(_ contractHash: Hash160) async throws -> ContractState {
        return try await neoSwift.getContractState(contractHash).send().getResult()
    }
    
    public func getContractByID(_ id: Int) async throws -> ContractState {
        return try await getContract(getContractHashById(id))
    }
    
    private func getContractHashById(_ id: Int) async throws -> Hash160 {
        let invocationResult = try await callInvokeFunction(ContractManagement.GET_CONTRACT_BY_ID, [.integer(id)]).getResult()
        do {
            let list = try invocationResult.getFirstStackItem().getList()
            guard list.count >= 3 else { throw NeoSwiftError.illegalState() }
            return try Hash160(list[2].getByteArray())
        } catch {
            throw NeoSwiftError.illegalArgument("Could not get the contract hash for the provided id.")
        }
    }
    
    public func getContractHashes() async throws -> Iterator<ContractState.ContractIdentifiers> {
        return try await callFunctionReturningIterator(ContractManagement.GET_CONTRACT_HASHES,
                                                       mapper: ContractState.ContractIdentifiers.fromStackItem)
    }
    
    public func getContractHashesUnwrapped() async throws -> [ContractState.ContractIdentifiers] {
        let list = try await callFunctionAndUnwrapIterator(ContractManagement.GET_CONTRACT_HASHES, [], ContractManagement.DEFAULT_ITERATOR_COUNT)
        return try list.map(ContractState.ContractIdentifiers.fromStackItem)
    }
    
    public func hasMethod(_ contractHash: Hash160, _ method: String, _ paramCount: Int) async throws -> Bool {
        return try await callFunctionReturningBool(ContractManagement.HAS_METHOD, [.hash160(contractHash), .string(method), .integer(paramCount)])
    }
    
    // TODO: Deploy
    
}
