
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
    
    public init(_ neoSwift: NeoSwift) {
        super.init(scriptHash: PolicyContract.SCRIPT_HASH, neoSwift: neoSwift)
    }
    
    public func getFeePerByte() async throws -> Int {
        return try await callFunctionReturningInt(PolicyContract.GET_FEE_PER_BYTE)
    }
    
    public func getExecFeeFactor() async throws -> Int {
        return try await callFunctionReturningInt(PolicyContract.GET_EXEC_FEE_FACTOR)
    }
    
    public func getStoragePrice() async throws -> Int {
        return try await callFunctionReturningInt(PolicyContract.GET_STORAGE_PRICE)
    }
    
    public func isBlocked() async throws -> Bool {
        return try await callFunctionReturningBool(PolicyContract.IS_BLOCKED)
    }
    
    public func setFeePerByte(_ fee: Int) throws -> TransactionBuilder {
        return try invokeFunction(PolicyContract.SET_FEE_PER_BYTE, [.integer(fee)])
    }
    
    public func setExecFeeFactor(_ fee: Int) throws -> TransactionBuilder {
        return try invokeFunction(PolicyContract.SET_EXEC_FEE_FACTOR, [.integer(fee)])
    }
    
    public func setStoragePrice(_ price: Int) throws -> TransactionBuilder {
        return try invokeFunction(PolicyContract.SET_STORAGE_PRICE, [.integer(price)])
    }
    
    public func blockAccount(_ account: Hash160) throws -> TransactionBuilder {
        return try invokeFunction(PolicyContract.BLOCK_ACCOUNT, [.hash160(account)])
    }
    
    public func blockAccount(_ account: String) throws -> TransactionBuilder {
        return try blockAccount(.fromAddress(account))
    }
    
    public func unblockAccount(_ account: Hash160) throws -> TransactionBuilder {
        return try invokeFunction(PolicyContract.UNBLOCK_ACCOUNT, [.hash160(account)])
    }
    
    public func unblockAccount(_ account: String) throws -> TransactionBuilder {
        return try unblockAccount(.fromAddress(account))
    }
    
}

