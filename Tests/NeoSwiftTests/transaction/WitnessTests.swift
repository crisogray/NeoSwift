
import BigInt
import XCTest
@testable import NeoSwift

class WitnessTests: XCTestCase {
    
    func testCreateWitness() {
        let message = Bytes(repeating: 10, count: 10)
        let keyPair = try! ECKeyPair.createEcKeyPair()
        let witness: Witness = try! .create(message, keyPair)
        let expectedSignature = try! Sign.signMessage(message, keyPair)
        
        let invocationExpectedString = "\(OpCode.pushData1.string)40\(expectedSignature.concatenated.noPrefixHex)"
        XCTAssertEqual(invocationExpectedString.bytesFromHex, witness.invocationScript.script)
        
        let verificationExpected = try! "\(OpCode.pushData1.string)21"
        + keyPair.publicKey.getEncodedCompressedHex()
        + OpCode.sysCall.string
        + InteropService.systemCryptoCheckSig.hash
        XCTAssertEqual(verificationExpected.bytesFromHex, witness.verificationScript.script)
    }
    
    func testSerializeWitness() {
        let message = Bytes(repeating: 10, count: 10)
        let keyPair = try! ECKeyPair.createEcKeyPair()
        let witness: Witness = try! .create(message, keyPair)
        
        let invocationScript = try! InvocationScript.fromMessageAndKeyPair(message, keyPair).script
        let invocationScriptLength = BInt(invocationScript.count).asMagnitudeBytes()
        let verificationScript = try! VerificationScript(keyPair.publicKey).script
        let verificationScriptLength = BInt(verificationScript.count).asMagnitudeBytes()
        
        XCTAssertEqual(invocationScriptLength + invocationScript + verificationScriptLength + verificationScript, witness.toArray())
    }
    
    func testSerializeMultiSigWitness() {
        let message = Bytes(repeating: 10, count: 10)
        let signingThreshold = 2
        
        var signatures: [Sign.SignatureData] = []
        var publicKeys: [ECPublicKey] = []
        for _ in 0...2 {
            let keyPair = try! ECKeyPair.createEcKeyPair()
            signatures.append(try! Sign.signMessage(message, keyPair))
            publicKeys.append(keyPair.publicKey)
        }
        
        let script = try! Witness.creatMultiSigWitness(signingThreshold, signatures, publicKeys)
        publicKeys.sort()
        let expected = try! "84\(OpCode.pushData1.string)40"
        + signatures[0].concatenated.noPrefixHex
        + "\(OpCode.pushData1.string)40"
        + signatures[1].concatenated.noPrefixHex
        + "70\(OpCode.push2.string)"
        + "\(OpCode.pushData1.string)21"
        + publicKeys[0].getEncodedCompressedHex()
        + "\(OpCode.pushData1.string)21"
        + publicKeys[1].getEncodedCompressedHex()
        + "\(OpCode.pushData1.string)21"
        + publicKeys[2].getEncodedCompressedHex()
        + OpCode.push3.string
        + OpCode.sysCall.string
        + InteropService.systemCryptoCheckMultisig.hash
        
        XCTAssertEqual(expected.bytesFromHex, script.toArray())
    }
    
    func testSerializeWitnessWithCustomScripts() {
        let message = Bytes(repeating: 10, count: 10)
        let witness = Witness(message, message)
        let half = Byte(message.count) + message
        XCTAssertEqual(half + half, witness.toArray())
    }
    
    func testDeserializeWitness() {
        let message = Bytes(repeating: 1, count: 10)
        let keyPair = try! ECKeyPair.createEcKeyPair()
        let signature = try! Sign.signMessage(message, keyPair).concatenated
        
        let invocationScript = "\(OpCode.pushData1.string)40\(signature.noPrefixHex)"
        let verificationScript = try! "\(OpCode.pushData1.string)21\(keyPair.publicKey.getEncodedCompressedHex())\(OpCode.sysCall.string)\(InteropService.systemCryptoCheckSig.hash)"
        let serialized = "42\(invocationScript)28\(verificationScript)"
        
        let witness = Witness.from(serialized.bytesFromHex)!
        XCTAssertEqual(invocationScript.bytesFromHex, witness.invocationScript.script)
        XCTAssertEqual(verificationScript.bytesFromHex, witness.verificationScript.script)
    }
    
    func testScriptHashFromWitness() {
        let secretKey = "9117f4bf9be717c9a90994326897f4243503accd06712162267e77f18b49c3a3"
        let publicKey = "0265bf906bf385fbf3f777832e55a87991bcfbe19b097fb7c5ca2e4025a4d5e5d6"
        let keyPair = try! ECKeyPair.create(privateKey: secretKey.bytesFromHex)
        let message = Bytes(repeating: 1, count: 10)
        
        let witness = try! Witness.create(message, keyPair)
        let expectedVerificationScript = "\(OpCode.pushData1.string)21\(publicKey)\(OpCode.sysCall.string)\(InteropService.systemCryptoCheckSig.hash)"
        
        XCTAssertEqual(expectedVerificationScript.bytesFromHex.sha256ThenRipemd160(), witness.verificationScript.scriptHash?.toLittleEndianArray())
    }
    
    func testScriptHashFromWitness2() {
        let invocationScript = "4051c2e6e2993c6feb43383131ed2091f4953747d3e16ecad752cdd90203a992dea0273e98c8cd09e9bfcf2dab22ce843429cdf0fcb9ba4ac93ef1aeef40b20783".bytesFromHex
        let verificationScript = "21031d8e1630ce640966967bc6d95223d21f44304133003140c3b52004dc981349c9ac".bytesFromHex
        let witness = Witness(invocationScript, verificationScript)
        XCTAssertEqual("35b20010db73bf86371075ddfba4e6596f1ff35d".bytesFromHex, witness.verificationScript.scriptHash?.toLittleEndianArray())
    }
    
    func testContractWitnessNoParams() {
        XCTAssertEqual(Witness.createContractWitness([]), Witness())
    }
    
    func testCreateContractWitness() {
        let witness = Witness.createContractWitness([.integer(20), .string("test")])
        let invocationScript = ScriptBuilder().pushInteger(20).pushData("test").toArray()
        XCTAssertEqual(witness.invocationScript.script, invocationScript)
        XCTAssertEqual(witness.verificationScript.script, [])
    }
    
}
