
import XCTest
@testable import NeoSwift

class VerificationScriptTests: XCTestCase {
    
    public func testFromPublicKey() {
        let key = "035fdb1d1f06759547020891ae97c729327853aeb1256b6fe0473bc2e9fa42ff50"
        let ecKey = try! ECPublicKey(key)
        let script = try! VerificationScript(ecKey)
        let expected = "\(OpCode.pushData1.string)21\(key)\(OpCode.sysCall.string)\(InteropService.systemCryptoCheckSig.hash)"
        XCTAssertEqual(script.script, expected.bytesFromHex)
    }
    
    public func testFromPublicKeys() {
        let key1 = "035fdb1d1f06759547020891ae97c729327853aeb1256b6fe0473bc2e9fa42ff50"
        let key2 = "03eda286d19f7ee0b472afd1163d803d620a961e1581a8f2704b52c0285f6e022d"
        let key3 = "03ac81ec17f2f15fd6d193182f927c5971559c2a32b9408a06fec9e711fb7ca02e"
        
        let publicKeys = [
            try! ECPublicKey(key1.bytesFromHex),
            try! ECPublicKey(key2.bytesFromHex),
            try! ECPublicKey(key3.bytesFromHex)
        ]
        
        let script = try! VerificationScript(publicKeys, 2)
        
        let expected = OpCode.push2.string + OpCode.pushData1.string + "21" + key1 +
        OpCode.pushData1.string + "21" + key3 + OpCode.pushData1.string + "21" + key2 +
        OpCode.push3.string + OpCode.sysCall.string + InteropService.systemCryptoCheckMultisig.hash
        
        XCTAssertEqual(expected.bytesFromHex, script.script)
    }
    
    public func testSerializeAndDeserialize() {
        let key = "035fdb1d1f06759547020891ae97c729327853aeb1256b6fe0473bc2e9fa42ff50"
        let ecPubKey = try! ECPublicKey(key.bytesFromHex)
        let script = try! VerificationScript(ecPubKey)
        let size = Bytes([Byte(NeoConstants.VERIFICATION_SCRIPT_SIZE)]).noPrefixHex
        let expected = "\(OpCode.pushData1.string)"
        + "21\(key)\(OpCode.sysCall.string)\(InteropService.systemCryptoCheckSig.hash)"
        let serialized = "\(size)\(expected)"
        XCTAssertEqual(serialized.bytesFromHex, script.toArray())
        let s = VerificationScript.from(serialized.bytesFromHex)
        XCTAssertEqual(s?.script, expected.bytesFromHex)
    }
    
    public func testGetSigningThreshold() {
        let key = "\(OpCode.pushData1.string)2102028a99826edc0c97d18e22b6932373d908d323aa7f92656a77ec26e8861699ef"
        
        var s = OpCode.push2.string
        for _ in 1...3 { s += key }
        s += "\(OpCode.push3.string)\(OpCode.sysCall.string)\(InteropService.systemCryptoCheckMultisig.hash)"
        XCTAssertEqual(2, try! VerificationScript(s.bytesFromHex).getSigningThreshold())
        
        var s1 = "\(OpCode.pushInt8.string)7f"
        for _ in 1...127 { s1 += key }
        s1 += "\(OpCode.pushInt8.string)7f\(OpCode.sysCall.string)\(InteropService.systemCryptoCheckMultisig.hash)"
        XCTAssertEqual(127, try! VerificationScript(s1.bytesFromHex).getSigningThreshold())
    }
    
    public func testThrowOnInvalidScript() {
        let script = VerificationScript("0123456789abcdef".bytesFromHex)
        
        assertErrorMessage(
            "The signing threshold cannot be determined because this script does not apply to the format of a signature verification script.",
            script.getSigningThreshold
        )
        
        assertErrorMessage(
            "The verification script is in an incorrect format. No public keys can be read from it.",
            script.getPublicKeys
        )
        
        assertErrorMessage(
            "The verification script is in an incorrect format. No public keys can be read from it.",
            script.getNrOfAccounts
        )
    }
    
    public func testSize() {
        let script = "147e5f3c929dd830d961626551dbea6b70e4b2837ed2fe9089eed2072ab3a655523ae0fa8711eee4769f1913b180b9b3410bbb2cf770f529c85f6886f22cbaaf"
        let s = VerificationScript(script.bytesFromHex)
        XCTAssertEqual(s.size, 65)
    }
    
    public func testIsSingleSigScript() {
        let script = OpCode.pushData1.string + "2102028a99826edc0c97d18e22b6932373d908d323aa7f92656a77ec26e8861699ef"
        + OpCode.sysCall.string + InteropService.systemCryptoCheckSig.hash
        let verificationScript = VerificationScript(script.bytesFromHex)
        XCTAssertTrue(verificationScript.isSingleSigScript())
    }
    
    public func testIsMultiSigScript() {
        let script = OpCode.push2.string + OpCode.pushData1.string +
        "2102028a99826edc0c97d18e22b6932373d908d323aa7f92656a77ec26e8861699ef" + OpCode.pushData1.string +
        "21031d8e1630ce640966967bc6d95223d21f44304133003140c3b52004dc981349c9" + OpCode.pushData1.string +
        "2103f0f9b358dfed564e74ffe242713f8bc866414226649f59859b140a130818898b" + OpCode.push3.string +
        OpCode.sysCall.string + InteropService.systemCryptoCheckMultisig.hash
        let verificationScript = VerificationScript(script.bytesFromHex)
        XCTAssertTrue(verificationScript.isMultiSigScript())
    }
    
    public func testFailIsMultiSigTooShort() {
        let script = VerificationScript("a89429c3be9f".bytesFromHex)
        XCTAssertFalse(script.isMultiSigScript())
    }
    
    public func testFailIsMultiSigNLessThanOne() {
        let script = OpCode.push0.string + OpCode.pushData1.string +
        "2102028a99826edc0c97d18e22b6932373d908d323aa7f92656a77ec26e8861699ef" +
        OpCode.push1.string + OpCode.pushNull.string + OpCode.sysCall.string + "3073b3bb"
        let verificationScript = VerificationScript(script.bytesFromHex)
        XCTAssertFalse(verificationScript.isMultiSigScript())
    }
    
    public func testFailIsMultiSigAbruptEnd() {
        let script = OpCode.push2.string + OpCode.pushData1.string +
        "2102028a99826edc0c97d18e22b6932373d908d323aa7f92656a77ec26e8861699ef"
        let verificationScript = VerificationScript(script.bytesFromHex)
        XCTAssertFalse(verificationScript.isMultiSigScript())
    }
    
    public func testFailIsMultiSigWrongPushData() {
        let script = OpCode.push2.string + OpCode.pushData1.string +
        "2102028a99826edc0c97d18e22b6932373d908d323aa7f92656a77ec26e8861699ef" +
        OpCode.pushData1.string + "43031d8e1630ce640966967bc6d95223d21f44304133003140c3b52004dc981349c9" +
        OpCode.push2.string + OpCode.pushNull.string + OpCode.sysCall.string + "3073b3bb"
        let verificationScript = VerificationScript(script.bytesFromHex)
        XCTAssertFalse(verificationScript.isMultiSigScript())
    }
    
    public func testFailIsMultiSigNGreaterThanM() {
        let script = OpCode.push3.string + OpCode.pushData1.string +
        "2102028a99826edc0c97d18e22b6932373d908d323aa7f92656a77ec26e8861699ef" +
        OpCode.pushData1.string + "21031d8e1630ce640966967bc6d95223d21f44304133003140c3b52004dc981349c9" +
        OpCode.push2.string + OpCode.pushNull.string + OpCode.sysCall.string + "3073b3bb"
        let verificationScript = VerificationScript(script.bytesFromHex)
        XCTAssertFalse(verificationScript.isMultiSigScript())
    }
    
    public func testFailIsMultiSigMIncorrect() {
        let script = OpCode.push2.string + OpCode.pushData1.string +
        "2102028a99826edc0c97d18e22b6932373d908d323aa7f92656a77ec26e8861699ef" +
        OpCode.pushData1.string + "21031d8e1630ce640966967bc6d95223d21f44304133003140c3b52004dc981349c9" +
        OpCode.push3.string + OpCode.pushNull.string + OpCode.sysCall.string + "3073b3bb"
        let verificationScript = VerificationScript(script.bytesFromHex)
        XCTAssertFalse(verificationScript.isMultiSigScript())
    }
    
    public func testFailIsMultiSigMissingPushNull() {
        let script = OpCode.push2.string + OpCode.pushData1.string +
        "2102028a99826edc0c97d18e22b6932373d908d323aa7f92656a77ec26e8861699ef" +
        OpCode.pushData1.string + "21031d8e1630ce640966967bc6d95223d21f44304133003140c3b52004dc981349c9" +
        OpCode.push2.string + OpCode.sysCall.string + "3073b3bb"
        let verificationScript = VerificationScript(script.bytesFromHex)
        XCTAssertFalse(verificationScript.isMultiSigScript())
    }
    
    public func testFailIsMultiSigMissingSysCall() {
        let script = OpCode.push2.string + OpCode.pushData1.string +
        "2102028a99826edc0c97d18e22b6932373d908d323aa7f92656a77ec26e8861699ef" +
        OpCode.pushData1.string + "21031d8e1630ce640966967bc6d95223d21f44304133003140c3b52004dc981349c9" +
        OpCode.push2.string + OpCode.pushNull.string + "3073b3bb"
        let verificationScript = VerificationScript(script.bytesFromHex)
        XCTAssertFalse(verificationScript.isMultiSigScript())
    }
    
    public func testFailIsMultiSigWrongInteropService() {
        let script = OpCode.push2.string + OpCode.pushData1.string +
        "2102028a99826edc0c97d18e22b6932373d908d323aa7f92656a77ec26e8861699ef" +
        OpCode.pushData1.string + "21031d8e1630ce640966967bc6d95223d21f44304133003140c3b52004dc981349c9" +
        OpCode.push3.string + OpCode.pushNull.string + OpCode.sysCall.string + "103ab300"
        let verificationScript = VerificationScript(script.bytesFromHex)
        XCTAssertFalse(verificationScript.isMultiSigScript())
    }
    
    public func testPublicKeysFromSingleSig() {
        let script = OpCode.pushData1.string + "2102028a99826edc0c97d18e22b6932373d908d323aa7f92656a77ec26e8861699ef" +
        OpCode.sysCall.string + InteropService.systemCryptoCheckSig.hash
        let verificationScript = VerificationScript(script.bytesFromHex)
        guard let keys = try? verificationScript.getPublicKeys() else {
            XCTFail()
            return
        }
        XCTAssertEqual(keys.count, 1)
        guard let encoded = try? keys.first?.getEncoded(compressed: true) else {
            XCTFail()
            return
        }
        XCTAssertEqual(encoded.noPrefixHex, "02028a99826edc0c97d18e22b6932373d908d323aa7f92656a77ec26e8861699ef")
    }
    
    public func testPublicKeysFromMultiSig() {
        let script = OpCode.push2.string + OpCode.pushData1.string +
        "2102028a99826edc0c97d18e22b6932373d908d323aa7f92656a77ec26e8861699ef" + OpCode.pushData1.string +
        "21031d8e1630ce640966967bc6d95223d21f44304133003140c3b52004dc981349c9" + OpCode.pushData1.string +
        "2103f0f9b358dfed564e74ffe242713f8bc866414226649f59859b140a130818898b" + OpCode.push3.string +
        OpCode.sysCall.string + InteropService.systemCryptoCheckMultisig.hash
        let verificationScript = VerificationScript(script.bytesFromHex)
        guard let keys = try? verificationScript.getPublicKeys() else {
            XCTFail()
            return
        }
        XCTAssertEqual(keys.count, 3)
        guard let key1 = try? keys.first?.getEncoded(compressed: true),
              let key2 = try? keys[1].getEncoded(compressed: true),
              let key3 = try? keys[2].getEncoded(compressed: true) else {
            XCTFail()
            return
        }
        XCTAssertEqual(key1.noPrefixHex, "02028a99826edc0c97d18e22b6932373d908d323aa7f92656a77ec26e8861699ef")
        XCTAssertEqual(key2.noPrefixHex, "031d8e1630ce640966967bc6d95223d21f44304133003140c3b52004dc981349c9")
        XCTAssertEqual(key3.noPrefixHex, "03f0f9b358dfed564e74ffe242713f8bc866414226649f59859b140a130818898b")
    }
    
    private func assertErrorMessage(_ message: String, _ expression: () throws -> Any) {
        XCTAssertThrowsError(try expression()) { error in
            XCTAssertEqual(error.localizedDescription, message)
        }
    }
    
}
