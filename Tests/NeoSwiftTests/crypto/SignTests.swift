
import BigInt
import XCTest
@testable import NeoSwift

class SignTests: XCTestCase {

    private let privateKey = try! ECPrivateKey(key: BInt("9117f4bf9be717c9a90994326897f4243503accd06712162267e77f18b49c3a3", radix: 16)!)
    private let publicKey = try! ECPublicKey(publicKey: BInt("0265bf906bf385fbf3f777832e55a87991bcfbe19b097fb7c5ca2e4025a4d5e5d6", radix: 16)!)
    private let data = Sign.SignatureData(v: 27,
                                  r: "147e5f3c929dd830d961626551dbea6b70e4b2837ed2fe9089eed2072ab3a655".bytesFromHex,
                                  s: "523ae0fa8711eee4769f1913b180b9b3410bbb2cf770f529c85f6886f22cbaaf".bytesFromHex)
    private let testMessage = "A test message"
    private let expectedR = "147e5f3c929dd830d961626551dbea6b70e4b2837ed2fe9089eed2072ab3a655"
    private let expectedS = "523ae0fa8711eee4769f1913b180b9b3410bbb2cf770f529c85f6886f22cbaaf"
    
    private var testMessageBytes: Bytes {
        return testMessage.bytes
    }
    
    private var keyPair: ECKeyPair {
        return ECKeyPair(privateKey: privateKey, publicKey: publicKey)
    }
    
 
    public func testSignMessage() {
        let expected = Sign.SignatureData(v: 27, r: expectedR.bytesFromHex, s: expectedS.bytesFromHex)

        let signatureData = try? Sign.signMessage(testMessageBytes, keyPair)
        XCTAssertEqual(signatureData, expected)

        let signatureDataHex = try? Sign.signHexMessage(testMessageBytes.toHexString(), keyPair)
        XCTAssertEqual(signatureDataHex, expected)
    }
    
    public func testRecoverSigningScriptHash() {
        let signatureData = Sign.SignatureData(v: 27,
                                               r: "147e5f3c929dd830d961626551dbea6b70e4b2837ed2fe9089eed2072ab3a655".bytesFromHex,
                                               s: "523ae0fa8711eee4769f1913b180b9b3410bbb2cf770f529c85f6886f22cbaaf".bytesFromHex)
        XCTAssertEqual(
            try! Sign.recoverSigningScriptHash(message: testMessageBytes, signatureData: signatureData),
            try! keyPair.getScriptHash()
        )
    }
    
    public func testSignatureDataFromBytes() {
        let bytes = "147e5f3c929dd830d961626551dbea6b70e4b2837ed2fe9089eed2072ab3a655523ae0fa8711eee4769f1913b180b9b3410bbb2cf770f529c85f6886f22cbaaf".bytesFromHex
        let signatureData = Sign.SignatureData(signature: bytes)
        
        XCTAssertEqual(signatureData.v, 0x00)
        XCTAssertEqual(signatureData.r, expectedR.bytesFromHex)
        XCTAssertEqual(signatureData.s, expectedS.bytesFromHex)
        
        let signatureData27 = Sign.SignatureData(v: 0x27, signature: bytes)
        
        XCTAssertEqual(signatureData27.v, 0x27)
        XCTAssertEqual(signatureData27.r, expectedR.bytesFromHex)
        XCTAssertEqual(signatureData27.s, expectedS.bytesFromHex)
    }
    
    public func testPublicKeyFromSignedMessage() {
        let signatureData = try! Sign.signMessage(testMessageBytes, keyPair)
        let pK = try? Sign.signedMessageToKey(message: testMessageBytes, signatureData: signatureData)
        XCTAssertEqual(publicKey, pK)
    }
    
    public func testPublicKeyFromPrivateKey() {
        let pK = try? Sign.publicKeyFromPrivateKey(privKey: privateKey)
        XCTAssertEqual(publicKey, pK)
    }
    
    public func testKeyFromSignedMessageWithInvalidSignature() {
        let invalidSignature = Sign.SignatureData(v: 27, r: [1], s: [0])
        XCTAssertThrowsError(try Sign.signedMessageToKey(message: testMessageBytes, signatureData: invalidSignature)) { error in
            XCTAssertEqual(error.localizedDescription, "r must be 32 bytes.")
        }
        
        let invalidSignatureWithValidR = Sign.SignatureData(v: 27, r: Bytes(repeating: 0x00, count: 32), s: [0])
        XCTAssertThrowsError(try Sign.signedMessageToKey(message: testMessageBytes, signatureData: invalidSignatureWithValidR)) { error in
            XCTAssertEqual(error.localizedDescription, "s must be 32 bytes.")
        }
    }
    
    public func testVerifySignature() {
        let signatureData = try! Sign.signMessage(testMessageBytes, keyPair)
        XCTAssertTrue(Sign.verifySignature(message: testMessageBytes, sig: signatureData, pubKey: publicKey))
    }
        
}
