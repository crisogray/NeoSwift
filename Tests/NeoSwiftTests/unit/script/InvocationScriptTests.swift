
import XCTest
@testable import NeoSwift

class InvocationScriptTests: XCTestCase {
    
    public func testFromMessageAndKeyPair() {
        let message = Bytes(repeating: 10, count: 10)
        let keyPair = try! ECKeyPair.createEcKeyPair()
        let script = try! InvocationScript.fromMessageAndKeyPair(message, keyPair)
        let expectedSignature = try! Sign.signMessage(message, keyPair).concatenated
        let expected = OpCode.pushData1.string + "40" + expectedSignature.noPrefixHex
        XCTAssertEqual(expected.bytesFromHex, script.script)
        XCTAssertEqual("42\(expected)".bytesFromHex, script.toArray())
    }
    
    public func testSerializeRandomInvocationScript() {
        let message = Bytes(repeating: 1, count: 10)
        let script = InvocationScript(message)
        XCTAssertEqual(10 + message, script.toArray())
    }
    
    public func testDeserializeCustomInvocationScript() {
        let message = Bytes(repeating: 1, count: 256)
        let script = "\(OpCode.pushData2.string)0001\(message.noPrefixHex)"
        let serializedScript = "FD0301\(script)"
        let deserialized = try? InvocationScript.from(serializedScript.bytesFromHex)
        XCTAssertEqual(deserialized?.script, script.bytesFromHex)
    }
    
    public func testDeserializeSignatureInvocationScript() {
        let message = Bytes(repeating: 0, count: 10)
        let keyPair = try! ECKeyPair.createEcKeyPair()
        let signature = try! Sign.signMessage(message, keyPair).concatenated
        let script = "\(OpCode.pushData1.string)40\(signature.noPrefixHex)"
        let deserialized = try? InvocationScript.from("42\(script)".bytesFromHex)
        XCTAssertEqual(deserialized?.script, script.bytesFromHex)
    }
    
    public func testSize() {
        let script = "147e5f3c929dd830d961626551dbea6b70e4b2837ed2fe9089eed2072ab3a655523ae0fa8711eee4769f1913b180b9b3410bbb2cf770f529c85f6886f22cbaaf"
            .bytesFromHex
        let s = InvocationScript(script)
        XCTAssertEqual(s.size, 65)
    }
    
    public func testGetSignatures() {
        let message = Bytes(repeating: 0, count: 10)
        let keyPair = try! ECKeyPair.createEcKeyPair()
        let signature = try! Sign.signMessage(message, keyPair)
        let inv = InvocationScript.fromSignatures([signature, signature, signature])
        inv.getSignatures().forEach { XCTAssertEqual($0.concatenated, signature.concatenated) }
    }
    
}
