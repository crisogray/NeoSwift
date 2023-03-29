
import XCTest
@testable import NeoSwift

class WIFTests: XCTestCase {
    
    private let validWif = "L25kgAQJXNHnhc7Sx9bomxxwVSMsZdkaNQ3m2VfHrnLzKWMLP13A"
    private let privateKey = "9117f4bf9be717c9a90994326897f4243503accd06712162267e77f18b49c3a3"
    
    public func testValidWifToPrivateKey() {
        guard let privateKeyFromWIF = try? validWif.privateKeyFromWIF() else {
            XCTFail()
            return
        }
        XCTAssertEqual(privateKey, privateKeyFromWIF.toHexString())
    }
    
    public func testWronglySizedWifs() {
        let tooLarge = "L25kgAQJXNHnhc7Sx9bomxxwVSMsZdkaNQ3m2VfHrnLzKWMLP13Ahc7S"
        let tooSmall = "L25kgAQJXNHnhc7Sx9bomxxwVSMsZdkaNQ3m2VfHrnLzKWML"
        assertThrowsWrongWifFormat(tooLarge)
        assertThrowsWrongWifFormat(tooSmall)
    }
    
    public func testWrongFirstByteWif() {
        var base58 = validWif.base58Decoded!
        base58[0] = 0x81
        let wrongFistByteWif = base58.base58Encoded
        assertThrowsWrongWifFormat(wrongFistByteWif)
    }
    
    public func testWrongByte33Wif() {
        var base58 = validWif.base58Decoded!
        base58[33] = 0x00
        let wrongByte33Wif = base58.base58Encoded
        assertThrowsWrongWifFormat(wrongByte33Wif)
    }
    
    private func assertThrowsWrongWifFormat(_ input: String) {
        XCTAssertThrowsError(try input.privateKeyFromWIF()) { error in
            XCTAssertEqual(error.localizedDescription, "Incorrect WIF format.")
        }
    }
    
    public func testValidPrivateKeyToWif() {
        guard let wifFromPrivateKey = try? privateKey.bytesFromHex.wifFromPrivateKey() else {
            XCTFail()
            return
        }
        XCTAssertEqual(wifFromPrivateKey, validWif)
    }
    
    public func testWronglySizedPrivateKey() {
        let wronglySizedPrivateKey = "9117f4bf9be717c9a90994326897f4243503accd06712162267e77f18b49c3"
        XCTAssertThrowsError(try wronglySizedPrivateKey.bytesFromHex.wifFromPrivateKey()) { error in
            XCTAssertEqual(error.localizedDescription, "Given key is not of expected length (32 bytes).")
        }
    }
    
}
