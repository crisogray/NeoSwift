
import XCTest
@testable import NeoSwift

class ScriptReaderTests: XCTestCase {
    
    public func testConvertToOpCodeString() {
        let script = "0c0548656c6c6f0c05576f726c642150419bf667ce41e63f18841140"
        XCTAssertEqual(
            ScriptReader.convertToOpCodeString(script),
            "PUSHDATA1 5 48656c6c6f\nPUSHDATA1 5 576f726c64\nNOP\n"
            + "SWAP\nSYSCALL 9bf667ce\nSYSCALL e63f1884\nPUSH1\nRET\n"
        )
    }
    
}
