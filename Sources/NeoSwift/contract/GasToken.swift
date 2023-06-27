
public class GasToken: FungibleToken {
    
    public static let NAME = "GasToken"
    public static let SCRIPT_HASH = try! calcNativeContractHash(NAME)
    public static let DECIMALS = 8
    public static let SYMBOL = "GAS"
    
    public init(_ neoSwift: NeoSwift) {
        super.init(scriptHash: GasToken.SCRIPT_HASH, neoSwift: neoSwift)
    }
    
    public override func getName() async throws -> String? {
        return GasToken.NAME
    }
    
    public override func getSymbol() async throws -> String {
        return GasToken.SYMBOL
    }
    
    public override func getDecimals() async throws -> Int {
        return GasToken.DECIMALS
    }
    
}
