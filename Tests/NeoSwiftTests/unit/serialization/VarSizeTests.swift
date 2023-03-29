
import XCTest
@testable import NeoSwift

class VarSizeTests: XCTestCase {
    
    func testIntVarSize() {
        assertVarSize(0, 1)
        assertVarSize(252, 1)
        assertVarSize(253, 3)
        assertVarSize(254, 3)
        assertVarSize(65_534, 3)
        assertVarSize(65_535, 3)
        assertVarSize(65_536, 5)
        assertVarSize(2_147_483_647, 5)
    }
    
    private func assertVarSize(_ input: Int, _ expected: Int) {
        XCTAssertEqual(input.varSize, expected)
    }
    
}
