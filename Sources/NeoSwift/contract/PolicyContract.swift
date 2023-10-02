
/// Represents a Policy contract and provides methods to invoke it.
public class PolicyContract: SmartContract {
    
    private static let NAME = "PolicyContract"
    public static let SCRIPT_HASH = try! calcNativeContractHash(NAME)
    
    private static let GET_FEE_PER_BYTE = "getFeePerByte"
    private static let GET_EXEC_FEE_FACTOR = "getExecFeeFactor"
    private static let GET_STORAGE_PRICE = "getStoragePrice"
    private static let IS_BLOCKED = "isBlocked"
    private static let SET_FEE_PER_BYTE = "setFeePerByte"
    private static let SET_EXEC_FEE_FACTOR = "setExecFeeFactor"
    private static let SET_STORAGE_PRICE = "setStoragePrice"
    private static let BLOCK_ACCOUNT = "blockAccount"
    private static let UNBLOCK_ACCOUNT = "unblockAccount"
    
    /// Constructs a new ``PolicyContract`` that uses the given ``NeoSwift/NeoSwift`` instance for invocations.
    /// - Parameter neoSwift: The ``NeoSwift/NeoSwift`` instance to use for invocations
    public init(_ neoSwift: NeoSwift) {
        super.init(scriptHash: PolicyContract.SCRIPT_HASH, neoSwift: neoSwift)
    }
    
    /// Gets the fee paid per byte of transaction.
    /// - Returns: The system fee per transaction byte
    public func getFeePerByte() async throws -> Int {
        return try await callFunctionReturningInt(PolicyContract.GET_FEE_PER_BYTE)
    }
    
    /// Gets the execution fee factor.
    /// - Returns: The execution fee factor
    public func getExecFeeFactor() async throws -> Int {
        return try await callFunctionReturningInt(PolicyContract.GET_EXEC_FEE_FACTOR)
    }
    
    /// Gets the GAS price for one byte of smart contract storage.
    /// - Returns: The storage price per byte
    public func getStoragePrice() async throws -> Int {
        return try await callFunctionReturningInt(PolicyContract.GET_STORAGE_PRICE)
    }
    
    /// Checks whether an account is blocked in the Neo network.
    /// - Parameter scriptHash: The script hash of the account
    /// - Returns: `true` if the account is blocked. Otherwise `false`
    public func isBlocked(_ scriptHash: Hash160) async throws -> Bool {
        return try await callFunctionReturningBool(PolicyContract.IS_BLOCKED, [.hash160(scriptHash)])
    }
    
    /// Creates a transaction script to set the fee per byte and initializes a ``TransactionBuilder`` based on this script.
    ///
    /// This method can only be successfully invoked by the committee, i.e., the transaction has to be signed by the committee members.
    /// - Parameter fee: The fee per byte
    /// - Returns: A transaction builder
    public func setFeePerByte(_ fee: Int) throws -> TransactionBuilder {
        return try invokeFunction(PolicyContract.SET_FEE_PER_BYTE, [.integer(fee)])
    }
    
    /// Creates a transaction script to set the execution fee factor and initializes a ``TransactionBuilder`` based on this script.
    /// - Parameter fee: The execution fee factor
    /// - Returns: A transaction builder
    public func setExecFeeFactor(_ fee: Int) throws -> TransactionBuilder {
        return try invokeFunction(PolicyContract.SET_EXEC_FEE_FACTOR, [.integer(fee)])
    }
    
    /// Creates a transaction script to set the storage price and initializes a ``TransactionBuilder`` based on this script.
    /// - Parameter price: The storage price
    /// - Returns: A transaction builder
    public func setStoragePrice(_ price: Int) throws -> TransactionBuilder {
        return try invokeFunction(PolicyContract.SET_STORAGE_PRICE, [.integer(price)])
    }
    
    /// Creates a transaction script to block an account in the neo-network and initializes a ``TransactionBuilder`` based on this script.
    ///
    /// This method can only be successfully invoked by the committee, i.e., the transaction has to be signed by the committee members.
    /// - Parameter account: The account to block
    /// - Returns: A transaction builder
    public func blockAccount(_ account: Hash160) throws -> TransactionBuilder {
        return try invokeFunction(PolicyContract.BLOCK_ACCOUNT, [.hash160(account)])
    }
    
    /// Creates a transaction script to block an account in the neo-network and initializes a ``TransactionBuilder`` based on this script.
    ///
    /// This method can only be successfully invoked by the committee, i.e., the transaction has to be signed by the committee members.
    /// - Parameter account: The address of the account to block
    /// - Returns: A transaction builder
    public func blockAccount(_ address: String) throws -> TransactionBuilder {
        return try blockAccount(.fromAddress(address))
    }
    
    /// Creates a transaction script to unblock an account in the neo-network and initializes a ``TransactionBuilder`` based on this script.
    ///
    /// This method can only be successfully invoked by the committee, i.e., the transaction has to be signed by the committee members.
    /// - Parameter account: The account to block
    /// - Returns: A transaction builder
    public func unblockAccount(_ account: Hash160) throws -> TransactionBuilder {
        return try invokeFunction(PolicyContract.UNBLOCK_ACCOUNT, [.hash160(account)])
    }
    
    /// Creates a transaction script to unblock an account in the neo-network and initializes a ``TransactionBuilder`` based on this script.
    ///
    /// This method can only be successfully invoked by the committee, i.e., the transaction has to be signed by the committee members.
    /// - Parameter account: The address of the account to block
    /// - Returns: A transaction builder
    public func unblockAccount(_ address: String) throws -> TransactionBuilder {
        return try unblockAccount(.fromAddress(address))
    }
    
}

