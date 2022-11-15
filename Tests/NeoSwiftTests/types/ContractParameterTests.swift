
import BigInt
import XCTest
@testable import NeoSwift

class ContractParameterTests: XCTestCase {
    
    public func testStringFromString() {
        let p = ContractParameter.string("value")
        assertContractParameter(p, "value", .string)
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
    
    private func assertErrorMessage(_ message: String, _ expression: () throws -> ContractParameter) {
        XCTAssertThrowsError(try expression()) { error in
            XCTAssertEqual(error.localizedDescription, message)
        }
    }
    
    private func assertContractParameter(_ p: ContractParameter, _ value: AnyHashable?, _ type: ContractParamterType) {
        XCTAssertEqual(p.value, value)
        XCTAssertEqual(p.type, type)
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
