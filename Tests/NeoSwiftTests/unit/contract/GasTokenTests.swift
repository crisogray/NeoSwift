
import XCTest
@testable import NeoSwift

class GasTokenTests: XCTestCase {
        
    private let neoSwift = NeoSwift.build(HttpService())
    
    public func testName() async {
        let name = try! await GasToken(neoSwift).getName()
        XCTAssertEqual(name, "GasToken")
    }
    
    public func testSymbol() async {
        let symbol = try! await GasToken(neoSwift).getSymbol()
        XCTAssertEqual(symbol, "GAS")
    }
    
    public func testDecimals() async {
        let decimals = try! await GasToken(neoSwift).getDecimals()
        XCTAssertEqual(decimals, 8)
    }
    
    public func testScriptHash() {
        XCTAssertEqual(GasToken(neoSwift).scriptHash.string, "d2a4cff31913016155e38e474a2c06d08be276cf")
    }
    
}
