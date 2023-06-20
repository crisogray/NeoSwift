
import XCTest
@testable import NeoSwift

class TokenTests: XCTestCase {
    
    var neoSwift: NeoSwift!
    var mockUrlSession: MockURLSession!
    
    let SOME_TOKEN_SCRIPT_HASH = try! Hash160("f7014e6d52fe8f94f7c57acd8cfb875b4ac2a1c6")
    var someToken: Token!
    
    override func setUp() {
        super.setUp()
        mockUrlSession = MockURLSession()
        neoSwift = NeoSwift.build(HttpService(urlSession: mockUrlSession))
        someToken = Token(scriptHash: SOME_TOKEN_SCRIPT_HASH, neoSwift: neoSwift)
    }
    
    public func testGetSymbol() async {
        let invokeJson = JSON.from("invokefunction_symbol")
        _ = mockUrlSession.data(invokeJson)
        let symbol = try! await someToken.getSymbol()
        XCTAssertEqual(symbol, "ant")
    }
    
    public func testGetDecimals() async {
        let invokeJson = JSON.from("invokefunction_decimals_nep17")
        _ = mockUrlSession.data(invokeJson)
        let decimals = try! await someToken.getDecimals()
        XCTAssertEqual(decimals, 2)
    }
    
    public func testGetTotalSupply() async {
        let invokeJson = JSON.from("invokefunction_totalSupply")
        _ = mockUrlSession.data(invokeJson)
        let totalSupply = try! await someToken.getTotalSupply()
        XCTAssertEqual(totalSupply, 3_000_000_000_000_000)
    }
    
    public func testToFractions() async {
        let invokeJson = JSON.from("invokefunction_decimals_nep17")
        _ = mockUrlSession.data(invokeJson)
        let fractions = try! await someToken.toFractions(Decimal(string: "1.02")!)
        XCTAssertEqual(fractions, 102)
    }
    
    public func testToFractionsTooHighScale() async {
        let invokeJson = JSON.from("invokefunction_decimals_nep17")
        _ = mockUrlSession.data(invokeJson)
        do {
            _ = try await someToken.toFractions(Decimal(string: "1.023")!)
            XCTFail("No exception")
        } catch {
            XCTAssert(error.localizedDescription.contains("The provided amount has too many decimal points."))
        }
    }
    
    public func testToFractionsWithSpecificDecimals() async {
        XCTAssertEqual(try! Token.toFractions(Decimal(string: "1.014")!, 6), 1014000)
    }
    
    public func testToDecimals() async {
        let invokeJson = JSON.from("invokefunction_decimals_gas")
        _ = mockUrlSession.data(invokeJson)
        let decimals = try! await someToken.toDecimals(123456789)
        XCTAssertEqual(decimals, Decimal(string: "1.23456789"))
    }
    
    public func testToDecimalsWithSpecificDecimals() async {
        XCTAssertEqual(try! Token.toDecimals(123456, 3), Decimal(string: "123.456"))
    }
    
}
