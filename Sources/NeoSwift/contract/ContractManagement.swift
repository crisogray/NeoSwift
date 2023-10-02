
import Foundation

/// Represents a Management contract and provides methods to invoke it.
public class ContractManagement: SmartContract {
    
    private static let NAME = "ContractManagement"
    private static let GET_MINIMUM_DEPLOYMENT_FEE = "getMinimumDeploymentFee"
    private static let SET_MINIMUM_DEPLOYMENT_FEE = "setMinimumDeploymentFee"
    private static let GET_CONTRACT_BY_ID = "getContractById"
    private static let GET_CONTRACT_HASHES = "getContractHashes"
    private static let HAS_METHOD = "hasMethod"
    private static let DEPLOY = "deploy"
    public static var SCRIPT_HASH = { try! calcNativeContractHash(NAME) }()

    /// Constructs a new ``ContractManagement`` that uses the given ``NeoSwift`` instance for invocations.
    /// - Parameter neoSwift: The ``NeoSwift`` instance to use for invocations
    public init(_ neoSwift: NeoSwift) {
        super.init(scriptHash: ContractManagement.SCRIPT_HASH, neoSwift: neoSwift)
    }
    
    /// Gets the minimum fee required for deployment.
    /// - Returns: The minimum required fee for contract deployment
    public func getMinimumDeploymentFee() async throws -> Int {
        return try await callFunctionReturningInt(ContractManagement.GET_MINIMUM_DEPLOYMENT_FEE)
    }
    
    /// Creates a transaction script to set the minimum deployment fee and initializes a ``TransactionBuilder`` based on this script.
    ///
    /// This method can only be successfully invoked by the committee, i.e., the transaction has to be signed by the committee members.
    /// - Parameter minimumFee: The minimum deployment fee
    /// - Returns: A transaction builder
    public func setMinimumDeploymentFee(_ minimumFee: Int) async throws -> Int {
        return try await callFunctionReturningInt(ContractManagement.SET_MINIMUM_DEPLOYMENT_FEE, [.integer(minimumFee)])
    }
    
    /// Gets the contract state of the contract with `contractHash`.
    ///
    /// Makes use of the RPC ``NeoSwift/NeoSwift/getContractState(_:)``
    /// - Parameter contractHash: The contract hash
    /// - Returns: The contract state
    public func getContract(_ contractHash: Hash160) async throws -> ContractState {
        return try await neoSwift.getContractState(contractHash).send().getResult()
    }
    
    /// Gets the contract state of the contract with `id`.
    ///
    /// Makes use of the RPC ``NeoSwift/NeoSwift/getContractState(_:)``
    /// - Parameter id: The contract id
    /// - Returns: The contract state
    public func getContractById(_ id: Int) async throws -> ContractState {
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
    
    /// Get all non native contract hashes and ids.
    /// - Returns: All non native contract hashes and ids
    public func getContractHashes() async throws -> Iterator<ContractState.ContractIdentifiers> {
        return try await callFunctionReturningIterator(ContractManagement.GET_CONTRACT_HASHES,
                                                       mapper: ContractState.ContractIdentifiers.fromStackItem)
    }
    
    /// Get all non native contract hashes and ids.
    ///
    /// Use this method if sessions are disabled on the Neo node.
    /// This method returns at most ``NeoConstants/MAX_ITERATOR_ITEMS_DEFAULT`` values.
    /// If there are more values, connect to a Neo node that supports sessions and use ``ContractManagement/getContractHashes()``
    /// - Returns: All non native contract hashes and ids
    public func getContractHashesUnwrapped() async throws -> [ContractState.ContractIdentifiers] {
        let list = try await callFunctionAndUnwrapIterator(ContractManagement.GET_CONTRACT_HASHES, [], ContractManagement.DEFAULT_ITERATOR_COUNT)
        return try list.map(ContractState.ContractIdentifiers.fromStackItem)
    }
    
    /// Checks if a method exists in a contract.
    /// - Parameters:
    ///   - contractHash: The contract hash
    ///   - method: The method
    ///   - paramCount: The number of parameters
    /// - Returns: `true` if the method exists. Otherwise `false`
    public func hasMethod(_ contractHash: Hash160, _ method: String, _ paramCount: Int) async throws -> Bool {
        return try await callFunctionReturningBool(ContractManagement.HAS_METHOD, [.hash160(contractHash), .string(method), .integer(paramCount)])
    }
    
    /// Creates a script and a containing transaction builder for a transaction that deploys the contract with the given NEF and manifest.
    /// - Parameters:
    ///   - nef: The NEF file
    ///   - manifest: The manifest
    ///   - data: Data to pass to the deployed contract's `_deploy` method
    /// - Returns: A transaction builder containing the deployment script
    public func deploy(_ nef: NefFile, _ manifest: ContractManifest, _ data: ContractParameter? = nil) throws -> TransactionBuilder {
        let manifestBytes = try JSONEncoder().encode(manifest).bytes
        guard manifestBytes.count <= NeoConstants.MAX_MANIFEST_SIZE else {
            throw NeoSwiftError.illegalArgument("The given contract manifest is too long. Manifest was \(manifestBytes.count) bytes big, but a max of \(NeoConstants.MAX_MANIFEST_SIZE) bytes is allowed.")
        }
        var params: [ContractParameter] = [.byteArray(nef.toArray()), .byteArray(manifestBytes)]
        if let data = data { params.append(data) }
        return try invokeFunction(ContractManagement.DEPLOY, params)
    }
    
}
