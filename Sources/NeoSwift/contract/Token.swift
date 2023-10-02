
import Foundation

/// Represents a token wrapper class that contains shared methods for the fungible NEP-17 and non-fungible NEP-11 token standards.
public class Token: SmartContract {
        
    private static let TOTAL_SUPPLY = "totalSupply"
    private static let SYMBOL = "symbol"
    private static let DECIMALS = "decimals"
    
    private var totalSupply: Int? = nil
    private var decimals: Int? = nil
    private var symbol: String? = nil
    
    /// Gets the total supply of this token in fractions.
    ///
    /// The return value is retrieved form the neo-node only once and then cached.
    /// - Returns: <#description#>
    public func getTotalSupply() async throws -> Int {
        guard let totalSupply = totalSupply else {
            return try await callFunctionReturningInt(Token.TOTAL_SUPPLY)
        }
        return totalSupply
    }
    
    /// Gets the number of fractions that one unit of this token can be divided into.
    ///
    /// The return value is retrieved form the neo-node only once and then cached.
    /// - Returns: The number of fractions
    public func getDecimals() async throws -> Int {
        guard let decimals = decimals else {
            return try await callFunctionReturningInt(Token.DECIMALS)
        }
        return decimals
    }
    
    /// Gets the symbol of this token.
    ///
    /// The return value is retrieved form the neo-node only once and then cached.
    /// - Returns: The symbol
    public func getSymbol() async throws -> String {
        guard let symbol = symbol else {
            return try await callFunctionReturningString(Token.SYMBOL)
        }
        return symbol
    }
    
    /// Converts the token amount from a decimal point number to the amount in token fractions according to this token's number of dceimals
    ///
    /// Use this method to convert e.g. 1.5 GAS to its fraction value 150_000_000.
    /// - Parameter amount: The token amount in decimals
    /// - Returns: The token amount in fractions
    public func toFractions(_ amount: Decimal) async throws -> Int {
        return try await Token.toFractions(amount, getDecimals())
    }
    
    /// Converts the token amount from a decimal point number to the amount in token fractions according to this token's number of dceimals
    ///
    /// Use this method to convert e.g. a token amount of 25.5 for a token with 4 decimals to 255_000.
    /// - Parameter amount: The token amount in decimals
    /// - Returns: The token amount in fractions
    public static func toFractions(_ amount: Decimal, _ decimals: Int) throws -> Int {
        guard amount.scale <= decimals else {
            throw NeoSwiftError.illegalArgument("The provided amount has too many decimal points. Make sure the decimals of the provided amount do not exceed the supported token decimals.")
        }
        
        return (amount * Decimal(10.toPowerOf(decimals)) as NSDecimalNumber).intValue
    }
    
    /// Converts the token amount from token fractions to its decimal point value according to this token's number of decimals.
    ///
    /// Use this method to convert e.g. 600_000 GAS to its decimal value 0.006.
    /// - Parameter amount: The token amount in fractions
    /// - Returns: The token amount in decimals
    public func toDecimals(_ amount: Int) async throws -> Decimal {
        return try await Token.toDecimals(amount, getDecimals())
    }

    /// Converts the token amount from token fractions to its decimal point value according to this token's number of decimals.
    ///
    /// Use this method to convert e.g. 600_000 GAS to its decimal value 0.006.
    /// - Parameter amount: The token amount in fractions
    /// - Returns: The token amount in decimals
    public static func toDecimals(_ amount: Int, _ decimals: Int) throws -> Decimal {
        return Decimal(amount) * (decimals < 0 ? pow(Decimal(10), -decimals) : (1 / pow(Decimal(10), decimals)))
    }
        
    internal func resolveNNSTextRecord(_ name: NNSName) async throws -> Hash160 {
        let resolvedAddress = try await NeoNameService(neoSwift: neoSwift).resolve(name, .txt)
        return try .fromAddress(resolvedAddress)
    }
        
}
