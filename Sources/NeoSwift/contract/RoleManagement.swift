
public class RoleManagement: SmartContract {
    
    private static let NAME = "RoleManagement"
    public static let SCRIPT_HASH = try! calcNativeContractHash(NAME)

    public static let GET_DESIGNATED_BY_ROLE = "getDesignatedByRole"
    public static let DESIGNATE_AS_ROLE = "designateAsRole"
    
    public init(_ neoSwift: NeoSwift) {
        super.init(scriptHash: RoleManagement.SCRIPT_HASH, neoSwift: neoSwift)
    }
    
    public func getDesignatedByRole(_ role: Role, blockIndex: Int) async throws -> [ECPublicKey] {
        try await checkBlockIndexValidity(blockIndex)
        let invocation = try await callInvokeFunction(RoleManagement.GET_DESIGNATED_BY_ROLE, [.integer(role.byte), .integer(blockIndex)])
        guard let arrayOfDesignates = try invocation.getResult().stack[0].list else {
            throw NeoSwiftError.illegalState("The invocation result did not have a list of roles")
        }
        return try arrayOfDesignates.map { try .init($0.getByteArray()) }
    }
    
    private func checkBlockIndexValidity(_ blockIndex: Int) async throws {
        guard blockIndex >= 0 else {
            throw NeoSwiftError.illegalArgument("The block index has to be positive.")
        }
        let currentBlockCount = try await neoSwift.getBlockCount().send().getResult()
        guard blockIndex <= currentBlockCount else {
            throw NeoSwiftError.illegalArgument("The provided block index (\(blockIndex)) is too high. The current block count is \(currentBlockCount).")
        }
    }
    
    public func designateAsRole(_ role: Role, _ pubKeys: [ECPublicKey]) throws -> TransactionBuilder {
        guard !pubKeys.isEmpty else {
            throw NeoSwiftError.illegalArgument("At least one public key is required for designation.")
        }
        let publicKeysParams = try pubKeys.map { try ContractParameter.publicKey($0.getEncoded(compressed: true)) }
        return try invokeFunction(RoleManagement.DESIGNATE_AS_ROLE, [.integer(role.byte), .array(publicKeysParams)])
    }
    
}
