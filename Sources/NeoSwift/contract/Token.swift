
import Foundation

public class Token: SmartContract {
        
    private static let TOTAL_SUPPLY = "totalSupply"
    private static let SYMBOL = "symbol"
    private static let DECIMALS = "decimals"
    
    private var totalSupply: Int? = nil
    private var decimals: Int? = nil
    private var symbol: String? = nil
    
    public func getTotalSupply() async throws -> Int {
        if totalSupply == nil {
            totalSupply = try await callFunctionReturningInt(Token.TOTAL_SUPPLY)
        }
        return totalSupply!
    }
    
    public func getDecimals() async throws -> Int {
        if decimals == nil {
            decimals = try await callFunctionReturningInt(Token.DECIMALS)
        }
        return decimals!
    }
    
    public func getSymbol() async throws -> String {
        if symbol == nil {
            symbol = try await callFunctionReturningString(Token.SYMBOL)
        }
        return symbol!
    }
    
    public func toFractions(_ amount: Decimal) async throws -> Int {
        return try await Token.toFractions(amount, getDecimals())
    }
    
    public static func toFractions(_ amount: Decimal, _ decimals: Int) throws -> Int {
        guard amount.scale <= decimals else {
            throw NeoSwiftError.illegalArgument("The provided amount has too many decimal points. Make sure the decimals of the provided amount do not exceed the supported token decimals.")
        }
        
        return (amount * Decimal(10.toPowerOf(decimals)) as NSDecimalNumber).intValue
    }
    
    public func toDecimals(_ amount: Int) async throws -> Decimal {
        return try await Token.toDecimals(amount, getDecimals())
    }
    
    public static func toDecimals(_ amount: Int, _ decimals: Int) throws -> Decimal {
        return Decimal(amount) * (decimals < 0 ? pow(Decimal(10), -decimals) : (1 / pow(Decimal(10), decimals)))
    }
    
    // TODO: NeoNameService
    
    internal func resolveNNSTextRecord(_ name: NNSName) throws -> Hash160 {
        return .ZERO
    }
        
}
