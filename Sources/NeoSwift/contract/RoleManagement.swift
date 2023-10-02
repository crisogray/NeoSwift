
/// Represents the RoleManagement contract that is used to assign roles to and check roles of designated nodes.
public class RoleManagement: SmartContract {
    
    private static let NAME = "RoleManagement"
    public static let SCRIPT_HASH = try! calcNativeContractHash(NAME)

    public static let GET_DESIGNATED_BY_ROLE = "getDesignatedByRole"
    public static let DESIGNATE_AS_ROLE = "designateAsRole"
    
    /// Constructs a new ``RoleManagement`` that uses the given ``NeoSwift/NeoSwift`` instance for invocations.
    /// - Parameter neoSwift: The ``NeoSwift/NeoSwift`` instance to use for invocations
    public init(_ neoSwift: NeoSwift) {
        super.init(scriptHash: RoleManagement.SCRIPT_HASH, neoSwift: neoSwift)
    }
    
    /// Gets the nodes that where assigned to the given role at the given block index.
    /// - Parameters:
    ///   - role: The role
    ///   - blockIndex: The block
    /// - Returns: The ``ECPublicKey``s of the designated nodes
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
    
    /// Creates a transaction script to designate nodes as a ``Role`` and initializes a ``TransactionBuilder`` based on this script.
    ///
    /// This method can only be successfully invoked by the committee, i.e., the transaction has to be signed by the committee members.
    /// - Parameters:
    ///   - role: The designation role
    ///   - pubKeys: The public keys of the nodes that are designated
    /// - Returns: A transaction builder
    public func designateAsRole(_ role: Role, _ pubKeys: [ECPublicKey]) throws -> TransactionBuilder {
        guard !pubKeys.isEmpty else {
            throw NeoSwiftError.illegalArgument("At least one public key is required for designation.")
        }
        let publicKeysParams = try pubKeys.map { try ContractParameter.publicKey($0.getEncoded(compressed: true)) }
        return try invokeFunction(RoleManagement.DESIGNATE_AS_ROLE, [.integer(role.byte), .array(publicKeysParams)])
    }
    
}
