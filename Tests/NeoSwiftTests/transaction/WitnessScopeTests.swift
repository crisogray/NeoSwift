
import BigInt
import XCTest
@testable import NeoSwift

class WitnessScopeTests: XCTestCase {
    
    func testCombineScopes() {
        XCTAssertEqual(WitnessScope.combineScopes([.calledByEntry, .customContracts]), 0x11)
        XCTAssertEqual(WitnessScope.combineScopes([.calledByEntry, .customContracts, .customGroups]), 0x31)
        XCTAssertEqual(WitnessScope.combineScopes([.global]), 0x80)
        XCTAssertEqual(WitnessScope.combineScopes([.none]), 0x0)
    }
    
    func testExtractVombinedScopes() {
        XCTAssertEqual(WitnessScope.extractCombinedScopes(0x00), [.none])
        XCTAssertEqual(WitnessScope.extractCombinedScopes(0x80), [.global])
        XCTAssertEqual(Set(WitnessScope.extractCombinedScopes(0x11)), Set([.calledByEntry, .customContracts]))
        XCTAssertEqual(Set(WitnessScope.extractCombinedScopes(0x21)), Set([.calledByEntry, .customGroups]))
        XCTAssertEqual(Set(WitnessScope.extractCombinedScopes(0x31)), Set([.calledByEntry, .customGroups, .customContracts]))
    }
    
    func testDecode() {
        let decoder = JSONDecoder()
        XCTAssertEqual(try! decoder.decode(ScopeWrapper.self, from: wrapJSON("\"None\"")).scope, .none)
        XCTAssertEqual(try! decoder.decode(ScopeWrapper.self, from: wrapJSON("1")).scope, .calledByEntry)
        XCTAssertThrowsError(try decoder.decode(ScopeWrapper.self, from: wrapJSON("\"NonExistent\""))) { error in
            XCTAssertEqual(error.localizedDescription, "WitnessScope value type not found")
        }
    }
    
    private func wrapJSON(_ json: String) -> Data {
        return "{\"scope\": \(json)}".data(using: .utf8)!
    }
    
    private class ScopeWrapper: Codable {
        let scope: WitnessScope
    }
    
}
 
