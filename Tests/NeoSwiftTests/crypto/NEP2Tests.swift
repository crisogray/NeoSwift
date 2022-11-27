
import XCTest
@testable import NeoSwift

class NEP2Tests: XCTestCase {
 
    func testDecryptWithDefaultScryptParams() {
        XCTAssertEqual(
            try? NEP2.decrypt(defaultAccountPassword, defaultAccountEncryptedPrivateKey).privateKey.bytes,
            defaultAccountPrivateKey.bytesFromHex
        )
    }
    
    func testDecryptWithNonDefaultScryptParams() {
        let params = ScryptParams(256, 1, 1)
        let encrypted = "6PYM7jHL3uwhP8uuHP9fMGMfJxfyQbanUZPQEh1772iyb7vRnUkbkZmdRT"
        XCTAssertEqual(
            try? NEP2.decrypt(defaultAccountPassword, encrypted, params).privateKey.bytes,
            defaultAccountPrivateKey.bytesFromHex
        )
    }
    
    func testEncryptWithDefaultScryptParams() {
        let keyPair = try! ECKeyPair.create(privateKey: defaultAccountPrivateKey.bytesFromHex)
        XCTAssertEqual(
            try? NEP2.encrypt(defaultAccountPassword, keyPair),
            defaultAccountEncryptedPrivateKey
        )
    }
    
    func testEncryptWithNonDefaultScryptParams() {
        let params = ScryptParams(256, 1, 1)
        let expected = "6PYM7jHL3uwhP8uuHP9fMGMfJxfyQbanUZPQEh1772iyb7vRnUkbkZmdRT"
        let keyPair = try! ECKeyPair.create(privateKey: defaultAccountPrivateKey.bytesFromHex)
        XCTAssertEqual(
            try? NEP2.encrypt(defaultAccountPassword, keyPair, params),
            expected
        )
    }

    
}
