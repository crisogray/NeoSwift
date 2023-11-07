
import BigInt
import XCTest
@testable import NeoSwift

class StackItemTest: XCTestCase {
    
    func testCastsNil() {
        XCTAssertNil(decode("{\"type\":\"Integer\",\"value\":\"1124\"}").list)
        XCTAssertNil(decode("{\"type\":\"Integer\",\"value\":\"1124\"}").pointer)
        XCTAssertNil(decode("{\"type\":\"Integer\",\"value\":\"1124\"}").iteratorId)
        XCTAssertNil(decode("{\"type\":\"Integer\",\"value\":\"1124\"}").address)
        XCTAssertNil(decode("{\"type\":\"Integer\",\"value\":\"1124\"}").boolean)
        XCTAssertNil(decode("{\"type\":\"Boolean\",\"value\":\"true\"}").hexString)
        XCTAssertNil(decode("{\"type\":\"Pointer\",\"value\":\"1124\"}").string)
        XCTAssertNil(decode("{\"type\":\"Boolean\",\"value\":\"true\"}").byteArray)
        XCTAssertNil(decode("{\"type\": \"Array\",\"value\": [{\"type\": \"Boolean\",\"value\": \"false\"}]}").integer)
        XCTAssertNil(decode("{\"type\":\"Integer\",\"value\":\"1124\"}").map)
    }
    
    func testAnyDecode() {
        let item = decode("{\"type\":\"Any\", \"value\":null}")
        XCTAssertEqual(item, .any(nil))
        XCTAssertNil(item.value)
    }
    
    func testPointerDecode() {
        let item = decode("{\"type\":\"Pointer\", \"value\":\"123456\"}")
        XCTAssertEqual(item, .pointer(BInt(123456)))
        XCTAssertEqual(item.integer, 123456)
    }
    
    func testByteStringDecode() {
        let item = decode("{\"type\":\"ByteString\",\"value\":\"V29vbG9uZw==\"}")
        XCTAssertEqual(item, .byteString("576f6f6c6f6e67".bytesFromHex))
        XCTAssertEqual(item.string, "Woolong")
        XCTAssertEqual(item.byteArray, "576f6f6c6f6e67".bytesFromHex)
        XCTAssertEqual(item.hexString, "576f6f6c6f6e67")
        
        let item2 = decode("{\"type\":\"ByteString\", \"value\":\"aWQ=\"}")
        XCTAssertEqual(item2, .byteString("6964".bytesFromHex))
        XCTAssertEqual(item2.integer, 25705)
        XCTAssertEqual(item2.byteArray, "6964".bytesFromHex)
        
        let item3 = decode("{\"type\":\"ByteString\", \"value\":\"1Cz3qTHOPEZVD9kN5IJYP8XqcBo=\"}")
        XCTAssertEqual(item3, .byteString("d42cf7a931ce3c46550fd90de482583fc5ea701a".bytesFromHex))
        XCTAssertEqual(item3.address, "NfFrJpFaLPCVuRRPhmBYRmZqSQLJ5fPuhz")
        XCTAssertEqual(item3.hexString, "d42cf7a931ce3c46550fd90de482583fc5ea701a")
        XCTAssertEqual(item3.byteArray, "d42cf7a931ce3c46550fd90de482583fc5ea701a".bytesFromHex)
    }
    
    func testBufferDecode() {
        let item = decode("{\"type\":\"Buffer\", \"value\":\"ew==\"}")
        XCTAssertEqual(item.integer, 123)
        
        let item2 = decode("{\"type\":\"Buffer\", \"value\":\"V29vbG9uZw==\"}")
        XCTAssertEqual(item2.string, "Woolong")
        
        let item3 = decode("{\"type\":\"Buffer\", \"value\":\"1Cz3qTHOPEZVD9kN5IJYP8XqcBo=\"}")
        XCTAssertEqual(item3.address, "NfFrJpFaLPCVuRRPhmBYRmZqSQLJ5fPuhz")
        
        let item4 = decode("{\"type\":\"Buffer\", \"value\":\"V29vbG9uZw==\"}")
        XCTAssertEqual(item4.byteArray, "576f6f6c6f6e67".bytesFromHex)
        XCTAssertEqual(item4, .buffer("576f6f6c6f6e67".bytesFromHex))
    }
    
    func testIntegerDecode() {
        let item = decode("{\"type\":\"Integer\",\"value\":\"1124\"}")
        XCTAssertEqual(item, .integer(BInt(1124)))
        XCTAssertEqual(item.integer, 1124)
    }
    
    func testBooleanDecode() {
        let item = decode("{\"type\":\"Boolean\", \"value\":\"true\"}")
        XCTAssertEqual(item, .boolean(true))
        XCTAssertEqual(item.value, true)
        XCTAssertEqual(item.boolean, true)
    }
    
    func testDeserializeArrayStackItem() {
        let json = """
    {
        "type": "Array",
        "value": [
            {
                "type": "Boolean",
                "value": "true"
            },
            {
                "type": "Integer",
                "value": "100"
            }
        ]
    }
    """
        let values: [StackItem] = [.boolean(true), .integer(BInt(100))]
        let item = decode(json)
        XCTAssertEqual(item, .array(values))
        XCTAssertEqual(item, .array([.boolean(true), .integer(BInt(100))]))
        XCTAssertEqual(item.list, values)
        
        let empty = decode("{\"type\":\"Array\", \"value\":[]}")
        XCTAssertEqual(empty, .array([]))
    }
    
    func testMapStackItem() {
        
        let base64Data1 = "dGVzdF9rZXlfYQ=="
        let base64Data2 = "dGVzdF9rZXlfYg=="
        let json = """
        {
            \"type\": \"Map\",
            \"value\": [
                {
                \"key\": {
                    \"type\": \"ByteString\",
                    \"value\": \"\(base64Data1)\"
                },
                \"value\": {
                    \"type\": \"Boolean\",
                    \"value\": \"false\"
                }
                },
                {
                \"key\": {
                    \"type\": \"ByteString\",
                    \"value\": \"\(base64Data2)\"
                },
                \"value\": {
                    \"type\": \"Integer\",
                    \"value\": \"12345\"
                }
                }
            ]
        }
"""

        let item = decode(json)
        guard case .map(let mapValue) = decode(json) else {
            return XCTFail()
        }
            
        XCTAssertEqual(mapValue.count, 2)
        
        let key1: StackItem = .byteString(base64Data1.base64Decoded)
        let key2: StackItem = .byteString(base64Data2.base64Decoded)
        
        XCTAssert(mapValue.keys.contains(key1))
        XCTAssert(mapValue.keys.contains(key2))

        let value1: StackItem = .boolean(false)
        let value2: StackItem = .integer(BInt(12345))
        
        XCTAssert(mapValue.values.contains(value1))
        XCTAssert(mapValue.values.contains(value2))
        
        let newMap: [StackItem: StackItem] = [
            key1: value1,
            key2: value2
        ]
        let newItem = StackItem.map(newMap)
        XCTAssertEqual(item, newItem)
        
        let empty = decode("{\"type\":\"Map\", \"value\":[]}")
        XCTAssertEqual(empty, .map([:]))
        XCTAssert(empty.map?.isEmpty == true)
    }
    
    func testInteropInterfaceDecode() {
        let item = decode("{\"type\": \"InteropInterface\",\"interface\": \"IIterator\",\"id\": \"fcf7b800-192a-488f-95d3-c40ac7b30ef1\"}")
        XCTAssertEqual(item, .interopInterface("fcf7b800-192a-488f-95d3-c40ac7b30ef1", "IIterator"))
        XCTAssertEqual(item.value, "fcf7b800-192a-488f-95d3-c40ac7b30ef1")
        XCTAssertEqual(item.valueString, "fcf7b800-192a-488f-95d3-c40ac7b30ef1")
    }
    
    func testStructDecode() {
        let json = "{\"type\": \"Struct\",\"value\": [{\"type\": \"Boolean\",\"value\": \"true\"},{\"type\": \"Integer\",\"value\": \"100\"}]}"
        let item = decode(json)
        
        XCTAssertEqual(item, .struct([.boolean(true), .integer(BInt(100))]))
        XCTAssertEqual(item.list, [.boolean(true), .integer(BInt(100))])
        
        let empty = decode("{\"type\":\"Struct\", \"value\":[]}")
        XCTAssertEqual(empty, .struct([]))
    }
    
    func testStackItemValues() {
        let trueBool: StackItem = .boolean(true)
        XCTAssertEqual(trueBool.integer, 1)
        XCTAssertEqual(trueBool.string, "true")
        
        let falseBool: StackItem = .boolean(false)
        XCTAssertEqual(falseBool.integer, 0)
        XCTAssertEqual(falseBool.string, "false")
        
        let buffer: StackItem = .buffer("0x010203".bytesFromHex)
        XCTAssert(buffer.boolean == true)
        
        let buffer2: StackItem = .buffer("0x000000".bytesFromHex)
        XCTAssert(buffer2.boolean == false)
        
        let byteString1: StackItem = .byteString("010203".bytesFromHex)
        XCTAssertNil(byteString1.address)
        
        let byteString2: StackItem = .byteString([])
        XCTAssertNil(byteString2.byteArray)
        
        let intOne: StackItem = .integer(BInt(1))
        XCTAssert(intOne.boolean == true)
        
        let intZero: StackItem = .integer(BInt(0))
        XCTAssert(intZero.boolean == false)

        let intThousand: StackItem = .integer(BInt(1000))
        XCTAssertEqual(intThousand.string, "1000")
        XCTAssertEqual(intThousand.hexString, "e803")
        XCTAssertEqual(intThousand.byteArray, "e803".bytesFromHex)
        
        let anyNil: StackItem = .any(nil)
        XCTAssertEqual(anyNil.toString, "Any{value='null'}")
    }
    
    func testCompareStackItems() {
        let buffer1: StackItem = .buffer("010203".bytesFromHex)
        let buffer2: StackItem = .buffer("010203".bytesFromHex)
        let byteString1: StackItem = .byteString("010203".bytesFromHex)
        let byteString2: StackItem = .byteString("010203".bytesFromHex)
        
        XCTAssertEqual(buffer1, buffer1)
        XCTAssertEqual(buffer1, buffer2)
        XCTAssertNotEqual(buffer1, byteString1)
        XCTAssertEqual(byteString1, byteString1)
        XCTAssertEqual(byteString1, byteString2)
        XCTAssertNotEqual(byteString1, buffer2)
    }
    
    func testListToString() {
        let items: [StackItem] = [.byteString("word".bytes), .integer(BInt(1))]
        let stackItem: StackItem = .array(items)
        XCTAssertEqual(stackItem.valueString, "ByteString{value='776f7264'}, Integer{value='1'}")
    }
    
    func testMapToString() {
        let items: [StackItem: StackItem] = [
            .byteString("key1".bytes): .integer(BInt(1)),
            .byteString("key2".bytes): .integer(BInt(0))
        ]
        let stackItem: StackItem = .map(items)
        XCTAssert(stackItem.valueString.contains("ByteString{value='6b657932'} -> Integer{value='0'}"))
        XCTAssert(stackItem.valueString.contains("ByteString{value='6b657931'} -> Integer{value='1'}"))
    }
    
    private func decode(_ json: String) -> StackItem {
        return try! JSONDecoder().decode(StackItem.self, from: json.data(using: .utf8)!)
    }
    
}
