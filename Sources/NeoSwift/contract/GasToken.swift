
/// Represents the GasToken native contract and provides methods to invoke its functions.
public class GasToken: FungibleToken {
    
    public static let NAME = "GasToken"
    public static let SCRIPT_HASH = try! calcNativeContractHash(NAME)
    public static let DECIMALS = 8
    public static let SYMBOL = "GAS"
    
    /// Constructs a new `GasToken` that uses the given ``NeoSwift`` instance for invocations.
    /// - Parameter neoSwift: The ``NeoSwift`` instance to use for invocations
    public init(_ neoSwift: NeoSwift) {
        super.init(scriptHash: GasToken.SCRIPT_HASH, neoSwift: neoSwift)
    }
    
    /// Returns the name of the GasToken contract.
    ///
    /// Doesn't require a call to the Neo node.
    /// - Returns: The name
    public override func getName() async throws -> String? {
        return GasToken.NAME
    }
    
    /// Returns the symbol of the GasToken contract.
    ///
    /// Doesn't require a call to the Neo node.
    /// - Returns: The symbol
    public override func getSymbol() async throws -> String {
        return GasToken.SYMBOL
    }
    
    /// Returns the number of decimals of the GAS token.
    ///
    /// Doesn't require a call to the Neo node.
    /// - Returns: The number of decimals
    public override func getDecimals() async throws -> Int {
        return GasToken.DECIMALS
    }
    
}
