
import BigInt
import XCTest
@testable import NeoSwift

class ECKeyPairTests: XCTestCase {
    
    let encodedPoint = "03b4af8d061b6b320cce6c63bc4ec7894dce107bfc5f5ef5c68a93b4ad1e136816"

    public func testNewPublicKeyFromPoint() {
        let publicKey = try? ECPublicKey(publicKey: encodedPoint)
        
        XCTAssertEqual(try? publicKey?.getEncoded(compressed: true), encodedPoint.bytesFromHex)
        XCTAssertEqual(try? publicKey?.getEncodedCompressedHex(), encodedPoint)
    }
    
    public func testNewPublicKeyFromUncompressedPoint() {
        let uncompressedPoint =
        "04b4af8d061b6b320cce6c63bc4ec7894dce107bfc5f5ef5c68a93b4ad1e1368165f4f7fb1c5862465543c06dd5a2aa414f6583f92a5cc3e1d4259df79bf6839c9"
        XCTAssertEqual(try? ECPublicKey(publicKey: uncompressedPoint).getEncodedCompressedHex(), encodedPoint)
    }
    
    public func testNewPublicKeyFromStringWithInvalidSize() {
        let tooSmall = String(encodedPoint.dropLast(2))
        XCTAssertThrowsError(try ECPublicKey(publicKey: tooSmall)) { error in
            XCTAssertEqual(error.localizedDescription, "Point decode exception")
        }
    }
    
    public func testNewPublicKeyFromPointWithHexPrefix() {
        let prefixed = "0x03b4af8d061b6b320cce6c63bc4ec7894dce107bfc5f5ef5c68a93b4ad1e136816"
        XCTAssertEqual(try? ECPublicKey(publicKey: prefixed).getEncodedCompressedHex(), encodedPoint)
    }

    public func testPublicKeySize() {
        let key = try! ECPublicKey(publicKey: "036b17d1f2e12c4247f8bce6e563a440f277037d812deb33a0f4a13945d898c296")
        XCTAssertEqual(key.size, 33)
    }
    
    public func testPublicKeyWif() {
        let privateKey = "c7134d6fd8e73d819e82755c64c93788d8db0961929e025a53363c4cc02a6962"
        guard let keyPair = try? ECKeyPair.create(privateKey: privateKey.bytesFromHex) else {
            XCTFail()
            return
        }
        XCTAssertEqual(try? keyPair.exportAsWif(),
                       "L3tgppXLgdaeqSGSFw1Go3skBiy8vQAM7YMXvTHsKQtE16PBncSU")
    }
    
    public func testPublicKeyComparable() {
        let encodedKey2 = "036b17d1f2e12c4247f8bce6e563a440f277037d812deb33a0f4a13945d898c296"
        let encodedKey1Uncompressed =
        "04b4af8d061b6b320cce6c63bc4ec7894dce107bfc5f5ef5c68a93b4ad1e1368165f4f7fb1c5862465543c06dd5a2aa414f6583f92a5cc3e1d4259df79bf6839c9"

        let key1 = try! ECPublicKey(publicKey: encodedPoint)
        let key2 = try! ECPublicKey(publicKey: encodedKey2)
        let key1Uncompressed = try! ECPublicKey(publicKey: encodedKey1Uncompressed)
        
        XCTAssertTrue(key1 > key2)
        XCTAssertTrue(key1 == key1Uncompressed)
        XCTAssertFalse(key1 < key1Uncompressed)
        XCTAssertFalse(key1 > key1Uncompressed)
    }
    
}
