
import XCTest
@testable import NeoSwift

class Hash160Tests: XCTestCase {
    
    public func testFromValidHash() {
        XCTAssertEqual(
            try? Hash160("0x23ba2703c53263e8d6e522dc32203339dcd8eee9").string,
            "23ba2703c53263e8d6e522dc32203339dcd8eee9"
        )
        XCTAssertEqual(
            try? Hash160("23ba2703c53263e8d6e522dc32203339dcd8eee9").string,
            "23ba2703c53263e8d6e522dc32203339dcd8eee9"
        )
    }
    
    public func testCreationThrows() {
        assertErrorMessage("String argument is not hexadecimal.") {
            try Hash160("0x23ba2703c53263e8d6e522dc32203339dcd8eee")
        }
        assertErrorMessage("String argument is not hexadecimal.") {
            try Hash160("g3ba2703c53263e8d6e522dc32203339dcd8eee9")
        }
        assertErrorMessage("Hash must be 20 bytes long but was 19 bytes.") {
            try Hash160("23ba2703c53263e8d6e522dc32203339dcd8ee")
        }
        assertErrorMessage("Hash must be 20 bytes long but was 32 bytes.") {
            try Hash160("c56f33fc6ecfcd0c225c4ab356fee59390af8560be0e930faebe74a6daff7c9b")
        }
    }
    
    public func testToArray() {
        XCTAssertEqual(
            try? Hash160("23ba2703c53263e8d6e522dc32203339dcd8eee9").toLittleEndianArray(),
            "23ba2703c53263e8d6e522dc32203339dcd8eee9".bytesFromHex.reversed()
        )
    }
    
    public func testSerializeAndDeserialize() {
        let writer = BinaryWriter()
        let string = "23ba2703c53263e8d6e522dc32203339dcd8eee9"
        let data: Bytes = string.bytesFromHex.reversed()
        
        try? Hash160(string).serialize(writer)
        
        XCTAssertEqual(writer.toArray(), data)
        XCTAssertEqual(Hash160.from(data)?.string, string)
    }
    
    public func testEquals() {
        let hash1 = try! Hash160.fromScript("01a402d8".bytesFromHex)
        let hash2 = try! Hash160.fromScript("d802a401".bytesFromHex)
        XCTAssertNotEqual(hash1, hash2)
        XCTAssertEqual(hash1, hash1)
    }
    
    public func testFromValidAddress() {
        let hash = try! Hash160.fromAddress("NLnyLtep7jwyq1qhNPkwXbJpurC4jUT8ke")
        let expectedHash = "09a55874c2da4b86e5d49ff530a1b153eb12c7d6".bytesFromHex
        XCTAssertEqual(hash.toLittleEndianArray(), expectedHash)
    }
    
    public func testFromInvalidAddress() {
        assertErrorMessage("Not a valid NEO address.") {
            try Hash160.fromAddress("NLnyLtep7jwyq1qhNPkwXbJpurC4jUT8keas")
        }
    }
    
    public func testFromPublicKeyBytes() {
        let key = "035fdb1d1f06759547020891ae97c729327853aeb1256b6fe0473bc2e9fa42ff50"
        let script = "\(OpCode.pushData1.string)21\(key)\(OpCode.sysCall.string)\(InteropService.systemCryptoCheckSig.hash)"
        let hash = try! Hash160.fromPublicKey(key.bytesFromHex)
        XCTAssertEqual(hash.toLittleEndianArray(), script.bytesFromHex.sha256ThenRipemd160())
    
        let publicKey = try! ECPublicKey(publicKey: defaultAccountPublicKey)
        let hash2 = try! Hash160.fromPublicKeys([publicKey], signingThreshold: 1)
        XCTAssertEqual(hash2.string, committeeAccountScriptHash)
    }

    public func testFromContractScript() {
        let hash = try! Hash160.fromScript("110c21026aa8fe6b4360a67a530e23c08c6a72525afde34719c5436f9d3ced759f939a3d110b41138defaf")
        XCTAssertEqual(hash.string, "afaed076854454449770763a628f379721ea9808")
        XCTAssertEqual(hash.toLittleEndianArray().toHexString(), "0898ea2197378f623a7670974454448576d0aeaf")
    }
        
    public func testToAddress() {
        let hash = try! Hash160.fromPublicKey(defaultAccountPublicKey.bytesFromHex)
        XCTAssertEqual(hash.toAddress(), defaultAccountAddress)
    }
    
    public func testCompareTo() {
        let hash1 = try! Hash160.fromScript("01a402d8".bytesFromHex)
        let hash2 = try! Hash160.fromScript("d802a401".bytesFromHex)
        let hash3 = try! Hash160.fromScript("a7b3a191".bytesFromHex)
        XCTAssertGreaterThan(hash2, hash1)
        XCTAssertGreaterThan(hash3, hash1)
        XCTAssertGreaterThan(hash2, hash3)
    }
    
    public func testSize() {
        let hash = try! Hash160("23ba2703c53263e8d6e522dc32203339dcd8eee9")
        XCTAssertEqual(hash.size, 20)
    }
    
    private func assertErrorMessage(_ message: String, _ expression: () throws -> Any) {
        XCTAssertThrowsError(try expression()) { error in
            XCTAssertEqual(error.localizedDescription, message)
        }
    }
    
}
