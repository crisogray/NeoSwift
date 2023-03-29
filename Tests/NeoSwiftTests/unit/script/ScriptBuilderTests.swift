
import BigInt
import XCTest
@testable import NeoSwift

class ScriptBuilderTests: XCTestCase {
    
    private let builder = ScriptBuilder()
    
    public func testPushArrayEmpty() {
        _ = builder.pushArray([])
        assertBuilder([OpCode.newArray0.opcode])
    }
    
    public func testPushParamEmptyArray() {
        _ = builder.pushParam(ContractParameter(type: .array, value: [AnyHashable]()))
        assertBuilder([OpCode.newArray0.opcode])
    }
    
    public func testPushByteArray() {
        _ = builder.pushData(byteArray(1))
        assertBuilder("0c01".bytesFromHex, firstN: 2)
        
        _ = builder.pushData(byteArray(75))
        assertBuilder("0c4b".bytesFromHex, firstN: 2)
        
        _ = builder.pushData(byteArray(256))
        assertBuilder("0d001".bytesFromHex, firstN: 3)
        
        _ = builder.pushData(byteArray(65536))
        assertBuilder("0e00000100".bytesFromHex, firstN: 5)
    }
    
    public func testPushString() {
        _ = builder.pushData("")
        assertBuilder("0c00".bytesFromHex, firstN: 2)
        
        _ = builder.pushData("a")
        assertBuilder("0c0161".bytesFromHex, firstN: 3)
        
        _ = builder.pushData(String(repeating: "a", count: 10000))
        assertBuilder("0d1027".bytesFromHex, firstN: 3)
    }
    
    public func testPushInteger() {
        _ = builder.pushInteger(0)
        assertBuilder([OpCode.push0.opcode], firstN: 1)
        
        _ = builder.pushInteger(1)
        assertBuilder([OpCode.push1.opcode], firstN: 1)
        
        _ = builder.pushInteger(16)
        assertBuilder([OpCode.push16.opcode], firstN: 1)
        
        _ = builder.pushInteger(17)
        assertBuilder("0011".bytesFromHex, firstN: 2)
        
        _ = builder.pushInteger(-800000)
        assertBuilder([0xff, 0xf3, 0xcb, 0x00].reversed(), lastN: 4, length: 5)
        
        _ = builder.pushInteger(-100000000000)
        assertBuilder([0xff, 0xff, 0xff, 0xe8, 0xb7, 0x89, 0x18, 0x00].reversed(), lastN: 8, length: 9)
        
        _ = builder.pushInteger(100000000000)
        assertBuilder([0x00, 0x00, 0x00, 0x17, 0x48, 0x76, 0xe8, 0x00].reversed(), lastN: 8, length: 9)
        
        _ = builder.pushInteger(-(BInt.TEN ** 23))
        assertBuilder("ffffffffffffead2fd381eb509800000".bytesFromHex.reversed(), lastN: 16, length: 17)
        
        _ = builder.pushInteger(BInt.TEN ** 23)
        assertBuilder("000000000000152d02c7e14af6800000".bytesFromHex.reversed(), lastN: 16, length: 17)
        
        _ = builder.pushInteger(BInt.TEN ** 23)
        assertBuilder("000000000000152d02c7e14af6800000".bytesFromHex.reversed(), lastN: 16, length: 17)
        
        _ = builder.pushInteger(-(BInt.TEN ** 40))
        assertBuilder("0xffffffffffffffffffffffffffffffe29cd60e3ca35b4054460a9f0000000000".bytesFromHex.reversed(), lastN: 32, length: 33)
        
        _ = builder.pushInteger(BInt.TEN ** 40)
        assertBuilder("0x0000000000000000000000000000001d6329f1c35ca4bfabb9f5610000000000".bytesFromHex.reversed(), lastN: 32, length: 33)
    }
    
    public func testVerificationScriptFromPublicKeys() {
        let key1 = "035fdb1d1f06759547020891ae97c729327853aeb1256b6fe0473bc2e9fa42ff50"
        let key2 = "03eda286d19f7ee0b472afd1163d803d620a961e1581a8f2704b52c0285f6e022d"
        let key3 = "03ac81ec17f2f15fd6d193182f927c5971559c2a32b9408a06fec9e711fb7ca02e"
        
        let keys = try! [ECPublicKey(key1), ECPublicKey(key2), ECPublicKey(key3)]
        let script = try! ScriptBuilder.buildVerificationScript(keys, 2)
        
        let expected = OpCode.push2.string + OpCode.pushData1.string + "21" + key1 +
        OpCode.pushData1.string + "21" + key3 + OpCode.pushData1.string + "21" + key2 +
        OpCode.push3.string + OpCode.sysCall.string + InteropService.systemCryptoCheckMultisig.hash
        XCTAssertEqual(script, expected.bytesFromHex)
    }
    
    public func testVerificationScriptFromPublicKey() {
        let key = "035fdb1d1f06759547020891ae97c729327853aeb1256b6fe0473bc2e9fa42ff50"
        let script = ScriptBuilder.buildVerificationScript(key.bytesFromHex)
        let expected = OpCode.pushData1.string + "21" + key + OpCode.sysCall.string + InteropService.systemCryptoCheckSig.hash
        XCTAssertEqual(script, expected.bytesFromHex)
    }
    
    public func testMap() {
        let map: [ContractParameter: ContractParameter] = [
            ContractParameter.integer(1): ContractParameter.string("first"),
            try! ContractParameter.byteArray("7365636f6e64"): ContractParameter.bool(true)
        ]
        let expectedOne = ScriptBuilder()
            .pushData("first")
            .pushInteger(1)
            .pushBoolean(true)
            .pushData("7365636f6e64".bytesFromHex)
            .pushInteger(2)
            .opCode(OpCode.packMap)
            .toArray().toHexString()
        
        let expectedTwo = ScriptBuilder()
            .pushBoolean(true)
            .pushData("7365636f6e64".bytesFromHex)
            .pushData("first")
            .pushInteger(1)
            .pushInteger(2)
            .opCode(OpCode.packMap)
            .toArray().toHexString()
        
        let actual = ScriptBuilder().pushMap(map).toArray().toHexString()
        XCTAssert(actual == expectedOne || actual == expectedTwo)
    }
    
    public func testMapNested() {
        let nestedMap = try! ContractParameter.map([ContractParameter.integer(10): ContractParameter.string("nestedFirst")])
        let map: [ContractParameter: ContractParameter] = [
            ContractParameter.integer(1): ContractParameter.string("first"),
            try! ContractParameter.byteArray("6e6573746564"): nestedMap
        ]
        let expectedOne = ScriptBuilder()
            .pushData("first")
            .pushInteger(1)
            .pushData("nestedFirst")
            .pushInteger(10)
            .pushInteger(1)
            .opCode(OpCode.packMap)
            .pushData("nested")
            .pushInteger(2)
            .opCode(OpCode.packMap)
            .toArray().toHexString()
        
        let expectedTwo = ScriptBuilder()
            .pushData("nestedFirst")
            .pushInteger(10)
            .pushInteger(1)
            .opCode(OpCode.packMap)
            .pushData("nested")
            .pushData("first")
            .pushInteger(1)
            .pushInteger(2)
            .opCode(OpCode.packMap)
            .toArray().toHexString()
        
        let actual = ScriptBuilder().pushMap(map).toArray().toHexString()
        XCTAssert(actual == expectedOne || actual == expectedTwo)
        
    }
    
    private func assertBuilder(_ value: Bytes, firstN: Int? = nil, lastN: Int? = nil, length: Int? = nil) {
        var bytes = builder.toArray()
        let count = bytes.count
        if let length = length { XCTAssertEqual(count, length) }
        if let n = firstN { bytes = Bytes(bytes[0..<n]) }
        else if let n = lastN { bytes = Bytes(bytes[(count - n)..<count]) }
        XCTAssertEqual(bytes, value)
    }
    
    private func byteArray(_ size: Int) -> Bytes {
        return Bytes(repeating: 0xAA, count: size)
    }
    
}
