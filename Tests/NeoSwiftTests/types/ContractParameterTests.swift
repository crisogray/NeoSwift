
import BigInt
import XCTest
@testable import NeoSwift

class ContractParameterTests: XCTestCase {
    
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
    
    private func assertValue<T: Equatable>(_ value: ContractParameter, _ expected: T?) {
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
