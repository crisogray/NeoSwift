
import BigInt
import XCTest
@testable import NeoSwift

class ContractParameterTests: XCTestCase {
    
    let contractParameter = ContractParameter.string("value")
    
    public func testStringFromString() {
        assertContractParameter(contractParameter, "value", .string)
    }
    
    public func testBytesFromBytes() {
        let bytes: Bytes = [0x01, 0x01]
        let p = ContractParameter.byteArray(bytes)
        assertContractParameter(p, bytes, .byteArray)
    }
    
    public func testBytesFromBytesString() {
        let p = try! ContractParameter.byteArray("0xa602")
        assertContractParameter(p, [0xa6, 0x02], .byteArray)
    }
    
    public func testBytesEquals() {
        let p = try! ContractParameter.byteArray("0x796573")
        let p2 = ContractParameter.byteArray([0x79, 0x65, 0x73])
        XCTAssertEqual(p, p2)
    }
    
    public func testBytesFromString() {
        let p = ContractParameter.byteArrayFromString("Neo")
        assertContractParameter(p, [0x4e, 0x65, 0x6f], .byteArray)
    }
    
    public func testBytesFromInvalidBytesString() {
        assertErrorMessage("Argument is not a valid hex number.") {
            try ContractParameter.byteArray("value")
        }
    }
    
    public func testArrayfromArray() {
        let params = try! [ContractParameter.string("value"),
                           ContractParameter.byteArray("0x0101")]
        let p = try! ContractParameter.array(params)
        assertContractParameter(p, params, .array)
    }
    
    public func testArrayFromEmpty() {
        let p = try! ContractParameter.array([])
        XCTAssertTrue((p.value as? [Any])?.count == 0)
    }
    
    public func testNestedArray() {
        let p1 = "value", p2 = "0x0101", p3 = BInt(420)
        let p4_1 = 1024, p4_2 = "neow3j:)"
        let p4_3_1 = BInt.TEN, p4_3 = [p4_3_1]
        let p4: [AnyHashable] = [p4_1, p4_2, p4_3], p5 = 55
        let params: [AnyHashable] = [p1, p2, p3, p4, p5]
        
        let p = try! ContractParameter.array(params)
        XCTAssertEqual(p.type, .array)
        
        guard let array = p.value as? [ContractParameter] else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(ContractParameter.string(p1), array[0])
        XCTAssertEqual(ContractParameter.string(p2), array[1])
        XCTAssertEqual(ContractParameter.integer(p3), array[2])
        XCTAssertEqual(try? ContractParameter.array([p4_1, p4_2, ContractParameter.array([p4_3_1])]), array[3])
        XCTAssertEqual(ContractParameter.integer(p5), array[4])
    }
    
    public func testArrayWithInvalidType() {
        assertErrorMessage("The provided object could not be casted into a supported contract parameter type.") {
            try ContractParameter.array([6.4])
        }
    }
    
    public func testSignatureFromString() {
        let sig = "d8485d4771e9112cca6ac7e6b75fc52585a2e7ee9a702db4a39dfad0f888ea6c22b6185ceab38d8322b67737a5574d8b63f4e27b0d208f3f9efcdbf56093f213"
        let p = try! ContractParameter.signature(sig)
        assertContractParameter(p, sig.bytesFromHex, .signature)
    }
    
    public func testSignatureFromStringWith0x() {
        let sig = "d8485d4771e9112cca6ac7e6b75fc52585a2e7ee9a702db4a39dfad0f888ea6c22b6185ceab38d8322b67737a5574d8b63f4e27b0d208f3f9efcdbf56093f213"
        let p = try! ContractParameter.signature("0x" + sig)
        assertContractParameter(p, sig.bytesFromHex, .signature)
    }
    
    public func testSignatureFromBytes() {
        let sig = "d8485d4771e9112cca6ac7e6b75fc52585a2e7ee9a702db4a39dfad0f888ea6c22b6185ceab38d8322b67737a5574d8b63f4e27b0d208f3f9efcdbf56093f213"
        let p = try! ContractParameter.signature(sig.bytesFromHex)
        assertContractParameter(p, sig.bytesFromHex, .signature)
    }
    
    public func testSignatureFromSignatureData() {
        let sig = "598235b9c5495cced03e41c0e4e0f7c4e3b8df3a190d33a76d764c5a6eb7581e8875976f63c1848cccc0822d8b8a534537da56a9b41f5e03977f83aae33d3558"
        let signatureData = Sign.SignatureData.fromByteArray(signature: sig.bytesFromHex)
        let p = try! ContractParameter.signature(signatureData)
        assertContractParameter(p, signatureData.concatenated, .signature)
    }
    
    public func testSignatureFromTooShortString() {
        let sig = "d8485d4771e9112cca6ac7e6b75fc52585a2e7ee9a702db4a39dfad0f888ea6c22b6185ceab38d8322b67737a5574d8b63f4e27b0d208f3f9efcdbf56093f2"
        assertErrorMessage("Signature is expected to have a length of 64 bytes, but had 63.") {
            try ContractParameter.signature(sig)
        }
    }
    
    public func testSignatureFromTooLongString() {
        let sig = "d8485d4771e9112cca6ac7e6b75fc52585a2e7ee9a702db4a39dfad0f888ea6c22b6185ceab38d8322b67737a5574d8b63f4e27b0d208f3f9efcdbf56093f213ff"
        assertErrorMessage("Signature is expected to have a length of 64 bytes, but had 65.") {
            try ContractParameter.signature(sig)
        }
    }
    
    public func testSignatureFromInvalidHexString() {
        let sig = "d8485d4771e9112cca6ac7e6b75fc52585t2e7ee9a702db4a39dfad0f888ea6c22b6185ceab38d8322b67737a5574d8b63f4e27b0d208f3f9efcdbf56093f213"
        assertErrorMessage("Argument is not a valid hex number.") {
            try ContractParameter.signature(sig)
        }
    }
    
    public func testBool() {
        let p = ContractParameter.bool(false)
        assertContractParameter(p, false, .boolean)
        let p1 = ContractParameter.bool(true)
        assertContractParameter(p1, true, .boolean)
    }
    
    public func testInt() {
        let p = ContractParameter.integer(10)
        assertContractParameter(p, 10, .integer)
        let p1 = ContractParameter.integer(-1)
        assertContractParameter(p1, -1, .integer)
        let p2 = ContractParameter.integer(BInt.TEN)
        assertContractParameter(p2, BInt.TEN, .integer)
    }
    
    public func testHash160() {
        let hash = try! Hash160("576f6f6c6f576f6f6c6f576f6f6c6f576f6f6c6f")
        let p = ContractParameter.hash160(hash)
        assertContractParameter(p, hash, .hash160)
    }
    
    // TODO: Test Hash160 from account
    
    public func testHash256() {
        let hash = try! Hash256("576f6f6c6f576f6f6c6f576f6f6c6f576f6f6c6ff6c6f576f6f6c6f576f6f6cf")
        let p = ContractParameter.hash256(hash)
        assertContractParameter(p, hash, .hash256)
    }
    
    public func testHash256FromString() {
        let hash = try! Hash256("576f6f6c6f576f6f6c6f576f6f6c6f576f6f6c6ff6c6f576f6f6c6f576f6f6cf")
        let p = try! ContractParameter.hash256("576f6f6c6f576f6f6c6f576f6f6c6f576f6f6c6ff6c6f576f6f6c6f576f6f6cf")
        assertContractParameter(p, hash, .hash256)
    }
    
    public func testHash256FromTooShortString() {
        assertErrorMessage("Hash must be 32 bytes long but was 31 bytes.") {
            try ContractParameter.hash256("576f6f6c6f576f6f6c6f576f6f6c6f576f6f6c6ff6c6f576f6f6c6f576f6f6")
        }
    }
    
    public func testHash256FromTooLongString() {
        assertErrorMessage("Hash must be 32 bytes long but was 33 bytes.") {
            try ContractParameter.hash256("576f6f6c6f576f6f6c6f576f6f6c6f576f6f6c6ff6c6f576f6f6c6f576f6f6cfaa")
        }
    }
    
    public func testHash256FromInvalidHexString() {
        assertErrorMessage("String argument is not hexadecimal.") {
            try ContractParameter.hash256("576f6f6c6f576f6f6c6f576f6f6c6f576f6f6c6ff6c6f576f6f6c6f576f6f6cg")
        }
    }
    
    public func testPublicKeyFromPublicKey() {
        let key = try! ECPublicKey(publicKey: "03b4af8efe55d98b44eedfcfaa39642fd5d53ad543d18d3cc2db5880970a4654f6")
        let p = try! ContractParameter.publicKey(key)
        try! assertContractParameter(p, key.getEncoded(compressed: true), .publicKey)
    }
    
    public func testPublicKeyFromBytes() {
        let bytes = "03b4af8efe55d98b44eedfcfaa39642fd5d53ad543d18d3cc2db5880970a4654f6".bytesFromHex
        let p = try! ContractParameter.publicKey(bytes)
        assertContractParameter(p, bytes, .publicKey)
    }
    
    public func testPublicKeyFromString() {
        let string = "03b4af8efe55d98b44eedfcfaa39642fd5d53ad543d18d3cc2db5880970a4654f6"
        let p = try! ContractParameter.publicKey(string)
        assertContractParameter(p, string.bytesFromHex, .publicKey)
    }
    
    public func testPublicKeyFromInvalidBytes() {
        let bytes = "03b4af8d061b6b320cce6c63bc4ec7894dce107bfc5f5ef5c68a93b4ad1e1368".bytesFromHex
        assertErrorMessage("Public key argument must be 33 bytes but was 32 bytes.") {
            try ContractParameter.publicKey(bytes)
        }
    }
    
    public func testPublicKeyFromInvalidString() {
        let string = "03b4af8d061b6b320cce6c63bc4ec7894dce107bfc5f5ef5c68a93b4ad1e1368"
        assertErrorMessage("Public key argument must be 33 bytes but was 32 bytes.") {
            try ContractParameter.publicKey(string)
        }
    }
    
    public func testMap() {
        let map = [
            ContractParameter.integer(1): ContractParameter.string("first"),
            ContractParameter.integer(2): ContractParameter.string("scond")
        ]
        let p = try! ContractParameter.map(map)
        assertContractParameter(p, map, .map)
    }
    
    public func testMapWithObjects() {
        let map: [AnyHashable: AnyHashable] = ["one": "first", "two": 2]
        let p = try! ContractParameter.map(map)
        guard let m = p.value as? [AnyHashable: AnyHashable] else {
            XCTFail()
            return
        }
        XCTAssert(m.keys.count == 2)
        XCTAssert(m.keys.contains(ContractParameter.string("one")))
        XCTAssert(m.keys.contains(ContractParameter.string("two")))
        XCTAssert(m.values.contains(ContractParameter.string("first")))
        XCTAssert(m.values.contains(ContractParameter.integer(2)))
    }
    
    public func testMapNested() {
        let map1key = 5, map1: [AnyHashable: AnyHashable] = ["hello": 1234]
        let map: [AnyHashable: AnyHashable] = ["one": "first", "two": 2, map1key: map1]
        //map[map1key] = map1
        let p = try! ContractParameter.map(map)
        guard let m = p.value as? [AnyHashable: AnyHashable] else {
            XCTFail()
            return
        }
        XCTAssert(m.keys.count == 3)
        XCTAssert(m.keys.contains(ContractParameter.string("one")))
        XCTAssert(m.keys.contains(ContractParameter.string("two")))
        XCTAssert(m.values.contains(ContractParameter.string("first")))
        XCTAssert(m.values.contains(ContractParameter.integer(2)))
        XCTAssertEqual(m[ContractParameter.integer(map1key)], try! ContractParameter.map(map1))
    }
    
    public func testMapInvalidKey() {
        let map = try! [ContractParameter.array([1, "test"]): ContractParameter.string("first")]
        assertErrorMessage("The provided map contains an invalid key. The keys cannot be of type array or map.") {
            try ContractParameter.map(map)
        }
    }
    
    public func testMapEmpty() {
        assertErrorMessage("At least one map entry is required to create a map contract parameter.") {
            try ContractParameter.map([:])
        }
    }
    
    public func testMapToContractParameter() {
        var p = try! ContractParameter.mapToContractParameter(ContractParameter.integer(12))
        assertContractParameter(p, 12, .integer)
        
        p = try! ContractParameter.mapToContractParameter(true)
        assertContractParameter(p, true, .boolean)
        
        p = try! ContractParameter.mapToContractParameter(33)
        assertContractParameter(p, 33, .integer)
        
        p = try! ContractParameter.mapToContractParameter(2000)
        assertContractParameter(p, 2000, .integer)
        
        p = try! ContractParameter.mapToContractParameter(BInt("12345"))
        assertContractParameter(p, BInt("12345"), .integer)
        
        let bytes: Bytes = [0x12, 0x0a, 0x0f]
        p = try! ContractParameter.mapToContractParameter(bytes)
        assertContractParameter(p, bytes, .byteArray)
        
        let s = "hello world!"
        p = try! ContractParameter.mapToContractParameter(s)
        assertContractParameter(p, s, .string)
        
        let hash160 = try! Hash160("0f2dc86970b191fd8a55aeab983a04889682e433")
        p = try! ContractParameter.mapToContractParameter(hash160)
        assertContractParameter(p, hash160, .hash160)
        
        let hash256 = try! Hash256("03b4af8d061b6b320cce6c63bc4ec7894dce107b03b4af8d061b6b320cce6c63")
        p = try! ContractParameter.mapToContractParameter(hash256)
        assertContractParameter(p, hash256, .hash256)
        
        // TODO: From Account
        
        let keyPair = try! ECKeyPair.createEcKeyPair()
        p = try! ContractParameter.mapToContractParameter(keyPair.publicKey)
        assertContractParameter(p, try! keyPair.publicKey.getEncoded(compressed: true), .publicKey)
        
        let signatureData = try! Sign.signMessage(message: "Test message.", keyPair: keyPair)
        p = try! ContractParameter.mapToContractParameter(signatureData)
        assertContractParameter(p, signatureData.concatenated, .signature)
        
        p = try! ContractParameter.mapToContractParameter(nil)
        assertContractParameter(p, nil, .any)
        
    }
    
    func testMapListToContractParameter() {
        
        let keyPair = try! ECKeyPair.createEcKeyPair()
        let signatureData = try! Sign.signMessage(message: "Test message.", keyPair: keyPair)
        let subList: [AnyHashable] = [2048, false]
        let list: [AnyHashable] = ["neo", 1024, subList, signatureData]
        let p = try! ContractParameter.array(list)
        
        XCTAssert(p.type == .array)
        
        guard let pList = p.value as? [ContractParameter] else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(pList.count, 4)
        assertContractParameter(pList[0], "neo", .string)
        assertContractParameter(pList[1], 1024, .integer)
        XCTAssertEqual(pList[2].type, .array)
        assertContractParameter(pList[3], signatureData.concatenated, .signature)
        
        guard let pSubList = pList[2].value as? [ContractParameter] else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(pSubList.count, 2)
        assertContractParameter(pSubList[0], 2048, .integer)
        assertContractParameter(pSubList[1], false, .boolean)
        
    }
    
    public func testMapMapToContractParameter() {
        let map1key = 16, map1: [AnyHashable: AnyHashable] = ["halo": 1234]
        let map: [AnyHashable: AnyHashable] = [map1key: map1, "twelve": 12, true: 10]
        let p = try! ContractParameter.mapToContractParameter(map)
        guard let m = p.value as? [ContractParameter : ContractParameter] else {
            XCTFail()
            return
        }
        XCTAssert(m.keys.count == 3)
        XCTAssert(m.keys.contains(ContractParameter.string("twelve")))
        XCTAssert(m.keys.contains(ContractParameter.bool(true)))
        XCTAssert(m.keys.contains(ContractParameter.integer(map1key)))
        XCTAssertEqual(m[ContractParameter.integer(map1key)], try! ContractParameter.map(map1))
        XCTAssertEqual(m[ContractParameter.bool(true)], ContractParameter.integer(10))
        XCTAssertEqual(m[ContractParameter.string("twelve")], ContractParameter.integer(12))
    }
    
    public func testEquals() {
        XCTAssertEqual(contractParameter, ContractParameter.string("value"))
        XCTAssertNotEqual(contractParameter, ContractParameter.string("test"))
        XCTAssertNotEqual(contractParameter, ContractParameter.integer(1))
        
        var p1 = ContractParameter.hash160(.ZERO)
        var p2 = ContractParameter.hash160(.ZERO)
        XCTAssertEqual(p1, p2)
        
        p2 = ContractParameter(type: .any)
        XCTAssertNotEqual(p1, p2)
        
        p2 = ContractParameter(type: .hash160, value: nil)
        XCTAssertNotEqual(p1, p2)
        
        p1 = ContractParameter(type: .hash160, value: nil)
        p2 = ContractParameter(type: .hash160, value: nil)
        XCTAssertEqual(p1, p2)
        
        p1 = ContractParameter.hash256(.ZERO)
        p2 = ContractParameter.hash256(.ZERO)
        XCTAssertEqual(p1, p2)
        
        p1 = ContractParameter.hash256(.ZERO)
        p2 = ContractParameter.hash160(.ZERO)
        XCTAssertNotEqual(p1, p2)
        
        p1 = try! ContractParameter
            .signature("01020304010203040102030401020304010203040102030401020304010203040102030401020304010203040102030401020304010203040102030401020304")
        p2 = try! ContractParameter
            .signature("01020304010203040102030401020304010203040102030401020304010203040102030401020304010203040102030401020304010203040102030401020304")
        XCTAssertEqual(p1, p2)
        
        p1 = try! ContractParameter.publicKey("010203040102030401020304010203040102030401020304010203040102030401")
        p2 = try! ContractParameter.publicKey("010203040102030401020304010203040102030401020304010203040102030401")
        XCTAssertEqual(p1, p2)
    }
    
    private func assertErrorMessage(_ message: String, _ expression: () throws -> ContractParameter) {
        XCTAssertThrowsError(try expression()) { error in
            XCTAssertEqual(error.localizedDescription, message)
        }
    }
    
    private func assertContractParameter(_ p: ContractParameter, _ value: AnyHashable?, _ type: ContractParamterType) {
        XCTAssertEqual(p.type, type)
        XCTAssertEqual(p.value, value)
    }
    
    public func testDeserializeAndSerialize() {
        let data = json.data(using: .utf8)!
        let contractParameter = try! JSONDecoder().decode(ContractParameter.self, from: data)
        guard let array = contractParameter.value as? [ContractParameter] else {
            XCTFail()
            return
        }
        
        assertValue(array[0], 1000)
        assertValue(array[1], 1000)
        
        guard let array2 = array[2].value as? [ContractParameter] else {
            XCTFail()
            return
        }
        
        assertValue(array2[0], "hello, world!")
        assertValue(array2[1], [0x01, 0x02, 0x03])
        assertValue(array2[2], [0x01, 0x02, 0x03])
        assertValue(array2[3], [0x01, 0x02, 0x03])
        assertValue(array2[4], true)
        assertValue(array2[5], true)
        try! assertValue(array2[6], Hash160("69ecca587293047be4c59159bf8bc399985c160d"))
        try! assertValue(array2[7], Hash256("fe26f525c17b58f63a4d106fba973ec34cc99bfe2501c9f672cc145b483e398b"))
        XCTAssertEqual(array2[8].value, nil)
        
        guard let map = array2[9].value as? [ContractParameter: ContractParameter] else {
            XCTFail()
            return
        }
        
        let keys = map.keys.map(\.value)
        XCTAssertTrue(keys.contains(5))
        XCTAssertTrue(keys.contains([0x01, 0x02, 0x03]))
        
        let values = map.values.map(\.value)
        XCTAssertTrue(values.contains("value"))
        XCTAssertTrue(values.contains(5))
        
        let reencodedJson = try! JSONEncoder().encode(contractParameter)
        let reencodedContractParameter = try! JSONDecoder().decode(ContractParameter.self, from: reencodedJson)
        XCTAssertEqual(reencodedContractParameter, contractParameter)
    }
    
    private func assertValue<T: Equatable>(_ value: ContractParameter, _ expected: T) {
        guard let obj = value.value as? T else {
            XCTFail()
            return
        }
        XCTAssertEqual(obj, expected)
    }
 
    let json = """
    {
        \"type\":\"Array\",
        \"value\": [
            {
                \"type\":\"Integer\",
                \"value\":1000
            },
            {
                \"type\":\"Integer\",
                \"value\":\"1000\"
            },
            {
                \"type\":\"Array\",
                \"value\":[
                    {
                        \"type\":\"String\",
                        \"value\":\"hello, world!\"
                    },
                    {
                        \"type\":\"ByteArray\",
                        \"value\":\"AQID\"
                    },
                    {
                        \"type\":\"Signature\",
                        \"value\":\"AQID\"
                    },
                    {
                        \"type\":\"PublicKey\",
                        \"value\":\"010203\"
                    },
                    {
                        \"type\":\"Boolean\",
                        \"value\":true
                    },
                    {
                        \"type\":\"Boolean\",
                        \"value\":\"true\"
                    },
                    {
                        \"type\":\"Hash160\",
                        \"value\":\"69ecca587293047be4c59159bf8bc399985c160d\"
                    },
                    {
                        \"type\":\"Hash256\",
                        \"value\":\"fe26f525c17b58f63a4d106fba973ec34cc99bfe2501c9f672cc145b483e398b\"
                    },
                    {
                        \"type\":\"Any\",
                        \"value\":\"\"
                    },
                   {
                       \"type\": \"Map\",
                       \"value\": [
                       {
                           \"key\":
                           {
                               \"type\": \"Integer\",
                               \"value\": \"5\"
                           },
                           \"value\":
                           {
                               \"type\": \"String\",
                               \"value\": \"value\"
                           }
                       },
                       {
                           \"key\":
                           {
                               \"type\": \"ByteArray\",
                               \"value\":\"AQID\"
                           },
                           \"value\":
                           {
                               \"type\": \"Integer\",
                               \"value\": \"5\"
                           }
                       }
                   ]
                   }
                ]
            }
        ]
    }
    """
    
}
