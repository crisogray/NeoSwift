
import XCTest
@testable import NeoSwift

class Base64Tests: XCTestCase {

    private let inputString = "150c14242dbf5e2f6ac2568b59b7822278d571b75f17be0c14242dbf5e2f6ac2568b59b7822278d571b75f17be13c00c087472616e736665720c14897720d8cd76f4f00abfa37c0edd889c208fde9b41627d5b5238"
    private let outputString = "FQwUJC2/Xi9qwlaLWbeCInjVcbdfF74MFCQtv14vasJWi1m3giJ41XG3Xxe+E8AMCHRyYW5zZmVyDBSJdyDYzXb08Aq/o3wO3YicII/em0FifVtSOA=="
    
    public func testBase64EncodeForString() {
        XCTAssertEqual(inputString.base64Encoded, outputString)
    }
    
    public func testBase64EncodeForBytes() {
        XCTAssertEqual(inputString.bytesFromHex.base64Encoded, outputString)
    }
    
    public func testBase64Decode() {
        XCTAssertEqual(outputString.base64Decoded.toHexString(), inputString)
    }
    
}
