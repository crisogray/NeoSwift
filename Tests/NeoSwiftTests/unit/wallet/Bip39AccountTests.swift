
import XCTest
@testable import NeoSwift

class Bip39AccountTests: XCTestCase {
    
    func testGenerateAndRecoverBip39Account() {
        let pw = "Insecure Pa55w0rd"
        let a1 = try! Bip39Account.create(pw)
        let a2 = try! Bip39Account.fromBip39Mneumonic(pw, a1.mnemonic)
        XCTAssertEqual(a1.address, a2.address)
        XCTAssertNotNil(a1.keyPair)
        XCTAssertEqual(a1.keyPair, a2.keyPair)
        XCTAssertEqual(a1.mnemonic, a2.mnemonic)
        XCTAssert(!a1.mnemonic.isEmpty)
        print(a1.mnemonic)
    }
    
}
