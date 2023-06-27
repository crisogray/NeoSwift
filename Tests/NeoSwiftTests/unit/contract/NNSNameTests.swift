
import XCTest
@testable import NeoSwift

class NNSNameTests: XCTestCase {
    
    public func testInvalidName() {
        let invalidName = "neo..neo"
        XCTAssertThrowsError(try NNSName(invalidName)) { error in
            XCTAssertEqual(error.localizedDescription, "'\(invalidName)' is not a valid NNS name.")
        }
    }
    
    public func testSecondLevelDomain() {
        XCTAssertFalse(try! NNSName("third.level.neo").isSecondLevelDomain)
        XCTAssertTrue(try! NNSName("level.neo").isSecondLevelDomain)
    }
    
    public func testInvalidLength() {
        // length < 3
        XCTAssertFalse(NNSName.isValidNNSName("me", false))
        
        // length 255
        XCTAssertTrue(NNSName.isValidNNSName("abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghij" +
                                             ".abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghij" +
                                             ".abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghij" +
                                             ".abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghij.neo", true))
        // length 256
        XCTAssertFalse(NNSName.isValidNNSName("abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghij" +
                                              ".abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghij" +
                                              ".abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghij" +
                                              ".abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijk.neo", true))
    }
    
    public func testFragmentLength() {
        // length 63
        XCTAssertTrue(NNSName.isValidNNSName("abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijk.neo", false))
        
        // length 64
        XCTAssertFalse(NNSName.isValidNNSName("abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijkl.neo", false))
    }
    
    public func testNrFragments() {
        XCTAssertFalse(NNSName.isValidNNSName("neo", false))
        XCTAssertTrue(NNSName.isValidNNSName("neo1.neo2.neo3.neo4.neo5.neo6.neo7.neo", true))
        XCTAssertFalse(NNSName.isValidNNSName("neo1.neo2.neo3.neo4.neo5.neo6.neo7.neo8.neo", true))
    }
    
    public func testRootStartNotAlpha() {
        XCTAssertFalse(NNSName.isValidNNSName("neo.4ever", false))
    }
    
    public func testFragmentNotAlphaNum() {
        XCTAssertFalse(NNSName.isValidNNSName("neow3j%100.neo", false))
        XCTAssertFalse(NNSName.isValidNNSName("&neow3j100.neo", false))
    }
    
    public func testSingleLengthRoot() {
        XCTAssertTrue(NNSName.isValidNNSName("neow3j.n", false))
    }
    
    public func testGetBytes() {
        let name = "neow3j.neo"
        let nnsName = try! NNSName(name)
        XCTAssertEqual(nnsName.name, name)
        XCTAssertEqual(nnsName.bytes, name.bytes)
    }
    
    public func testRoot() {
        let root = try! NNSName.NNSRoot("neo")
        XCTAssertEqual(root.root, "neo")
    }
    
    public func testRootInvalid() {
        let invalidRoot = "rootrootrootroots"; // too long
        XCTAssertThrowsError(try NNSName.NNSRoot(invalidRoot)) { error in
            XCTAssertEqual(error.localizedDescription, "'\(invalidRoot)' is not a valid NNS root.")
        }
    }
    
}

