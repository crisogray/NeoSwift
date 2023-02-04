
import BigInt
import XCTest
import DynamicCodableKit
@testable import NeoSwift

class StackItemTest: XCTestCase {
    
    func testCastsThrow() {
        assertCastThrows("{\"type\":\"Integer\",\"value\":\"1124\"}", StackItem.getMap, .integer, "1124")
        assertCastThrows("{\"type\":\"Integer\",\"value\":\"1124\"}", StackItem.getList, .integer, "1124")
        assertCastThrows("{\"type\":\"Integer\",\"value\":\"1124\"}", StackItem.getPointer, .integer, "1124")
        assertCastThrows("{\"type\":\"Integer\",\"value\":\"1124\"}", StackItem.getIteratorId, .integer, "1124")
        assertCastThrows("{\"type\":\"Integer\",\"value\":\"1124\"}", StackItem.getAddress, .integer, "1124")
        assertCastThrows("{\"type\":\"Integer\",\"value\":\"1124\"}", StackItem.getBoolean, .integer, "1124")
        assertCastThrows("{\"type\":\"Boolean\",\"value\":\"true\"}", StackItem.getHexString, .boolean, "true")
        assertCastThrows("{\"type\":\"Pointer\",\"value\":\"1124\"}", StackItem.getString, .pointer, "1124")
        assertCastThrows("{\"type\":\"Boolean\",\"value\":\"true\"}", StackItem.getByteArray, .boolean, "true")
        assertCastThrows("{\"type\":\"Boolean\",\"value\":\"true\"}", StackItem.getByteArray, .boolean, "true")
        assertCastThrows("{\"type\": \"Array\",\"value\": [{\"type\": \"Boolean\",\"value\": \"false\"}]}",
                         StackItem.getInteger, .array, "false")
        assertCastThrows("{\"type\":\"Integer\",\"value\":\"\"}", StackItem.getMap)
    }
    
    func testAnyDecode() {
        let any = assertDecode("{\"type\":\"Any\", \"value\":null}", StackItem.getValue, .any, nil)
        let newAny = AnyStackItem(nil)
        assertEqual(any, newAny)
    }
    
    func testPointerDecode() {
        let pointer = assertDecode("{\"type\":\"Pointer\", \"value\":\"123456\"}", StackItem.getPointer, .pointer, 123456)
        assertEqual(pointer, PointerStackItem(123456))
    }
    
    func testByteStringDecode() {
        let byteString = assertDecode("{\"type\":\"ByteString\",\"value\":\"V29vbG9uZw==\"}", StackItem.getString, .byteString, "Woolong")
        XCTAssertEqual(try? byteString.getByteArray(), "576f6f6c6f6e67".bytesFromHex)
        XCTAssertEqual(try? byteString.getHexString(), "576f6f6c6f6e67")
        
        let byteString2 = assertDecode("{\"type\":\"ByteString\", \"value\":\"aWQ=\"}", StackItem.getByteArray, .byteString, "6964".bytesFromHex)
        XCTAssertEqual(try? byteString2.getInteger(), 25705)
        
        let byteString3 = assertDecode("{\"type\":\"ByteString\", \"value\":\"1Cz3qTHOPEZVD9kN5IJYP8XqcBo=\"}", StackItem.getAddress, .byteString, "NfFrJpFaLPCVuRRPhmBYRmZqSQLJ5fPuhz")
        XCTAssertEqual(try? byteString3.getHexString(), "d42cf7a931ce3c46550fd90de482583fc5ea701a")
        XCTAssertEqual(try? byteString3.getByteArray(), "d42cf7a931ce3c46550fd90de482583fc5ea701a".bytesFromHex)
        
        assertEqual(byteString3, ByteStringStackItem("d42cf7a931ce3c46550fd90de482583fc5ea701a"))
    }
    
    func testBufferDecode() {
        let _ = assertDecode("{\"type\":\"Buffer\", \"value\":\"ew==\"}", StackItem.getInteger, .buffer, 123)
        let _ = assertDecode("{\"type\":\"Buffer\", \"value\":\"V29vbG9uZw==\"}", StackItem.getString, .buffer, "Woolong")
        let _ = assertDecode("{\"type\":\"Buffer\", \"value\":\"1Cz3qTHOPEZVD9kN5IJYP8XqcBo=\"}", StackItem.getAddress, .buffer, "NfFrJpFaLPCVuRRPhmBYRmZqSQLJ5fPuhz")
        let buffer4 = assertDecode("{\"type\":\"Buffer\", \"value\":\"V29vbG9uZw==\"}", StackItem.getByteArray, .buffer, "576f6f6c6f6e67".bytesFromHex)
        assertEqual(buffer4, BufferStackItem("576f6f6c6f6e67".bytesFromHex))
    }
    
    func testIntegerDecode() {
        let _ = assertDecode("{\"type\":\"Integer\",\"value\":\"1124\"}", StackItem.getInteger, .integer, 1124)
        let int = assertDecode("{\"type\":\"Integer\",\"value\":1124}", StackItem.getInteger, .integer, 1124)
        assertEqual(int, IntegerStackItem(1124))
    }
    
    func testBooleanDecode() {
        let _ = assertDecode("{\"type\":\"Boolean\", \"value\":\"true\"}", StackItem.getBoolean, .boolean, true)
        let boolean = assertDecode("{\"type\":\"Boolean\", \"value\":false}", StackItem.getBoolean, .boolean, false)
        assertEqual(boolean, BooleanStackItem(false))
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
        let values: [StackItem] = [BooleanStackItem(true), IntegerStackItem(100)]
        let item = decodeStackItem(json)
        try! item.getList().enumerated().forEach { i, value in
            assertEqual(value, values[i])
        }
        
        let other = ArrayStackItem([BooleanStackItem(true), IntegerStackItem(100)])
        assertEqual(other, item)
        
        let empty = decodeStackItem("{\"type\":\"Array\", \"value\":[]}")
        XCTAssertEqual(empty.type, .array)
        assertEqual(empty, ArrayStackItem([]))
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
        
        let stackItem = decodeStackItem(json)
        let map = try! stackItem.getMap()

        XCTAssertEqual(stackItem.type, .map)
        XCTAssertEqual(map.count, 2)
        
        let key1 = ByteStringStackItem(base64Data1.base64Decoded)
        let key2 = ByteStringStackItem(base64Data2.base64Decoded)
        
        XCTAssert(map.keys.contains(where: { $0 == key1 }))
        XCTAssert(map.keys.contains(where: { $0 == key2 }))

        let value1 = BooleanStackItem(false)
        let value2 = IntegerStackItem(12345)
        
        XCTAssert(map.values.contains(where: { $0 == value1 }))
        XCTAssert(map.values.contains(where: { $0 == value2 }))
        
        let newMap: [(StackItem, StackItem)] = [
            (key1, value1),
            (key2, value2)
        ]
        let newItem = MapStackItem(newMap)
        assertEqual(stackItem, newItem)
        
        let empty = decodeStackItem("{\"type\":\"Map\", \"value\":[]}")
        let emptyMap = try! empty.getMap()
        let newEmpty = MapStackItem([])
        XCTAssertEqual(stackItem.type, .map)
        XCTAssert(emptyMap.isEmpty)
        assertEqual(empty, newEmpty)
        
    }
    
    func testInteropInterfaceDecode() {
        let json = "{\"type\": \"InteropInterface\",\"interface\": \"IIterator\",\"id\": \"fcf7b800-192a-488f-95d3-c40ac7b30ef1\"}"
        let item = assertDecode(json, StackItem.getIteratorId, .interopInterface, "fcf7b800-192a-488f-95d3-c40ac7b30ef1")
        XCTAssertEqual(try? item.getValue(), "fcf7b800-192a-488f-95d3-c40ac7b30ef1")
        XCTAssertEqual(item.valueString, "fcf7b800-192a-488f-95d3-c40ac7b30ef1")
        
        let interopStackItem = try! JSONDecoder().decode(InteropInterfaceStackItem.self, from: json.data(using: .utf8)!)
        XCTAssertEqual(interopStackItem.type, .interopInterface)
        XCTAssertEqual(try? interopStackItem.getInterfaceName(), "IIterator")
        XCTAssertEqual(try? interopStackItem.getIteratorId(), "fcf7b800-192a-488f-95d3-c40ac7b30ef1")
        
        assertEqual(interopStackItem, InteropInterfaceStackItem(interface: "IIterator", id: "fcf7b800-192a-488f-95d3-c40ac7b30ef1"))
    }
    
    func testStructDecode() {
        let json = "{\"type\": \"Struct\",\"value\": [{\"type\": \"Boolean\",\"value\": \"true\"},{\"type\": \"Integer\",\"value\": \"100\"}]}"
        let stackItem = decodeStackItem(json)
        XCTAssertEqual(stackItem.type, .struct)
        
        let items = try! stackItem.getList()
        XCTAssertEqual(items.count, 2)
        XCTAssertEqual(items[0].type, .boolean)
        XCTAssertEqual(items[1].type, .integer)
        
        let newItems: [StackItem] = [BooleanStackItem(true), IntegerStackItem(100)]
        let newStackItem = StructStackItem(newItems)
        assertEqual(newStackItem, stackItem)
        
        let empty = decodeStackItem("{\"type\":\"Struct\", \"value\":[]}")
        assertEqual(empty, StructStackItem([]))
    }
    
    func testStackItemTypes() {
        XCTAssertEqual(StackItemType.buffer.rawValue, "Buffer")
        XCTAssertEqual(StackItemType.buffer.byte, 48)
        XCTAssertEqual(StackItemType.valueOf(33), .integer)
        XCTAssertEqual(StackItemType(rawValue: "Boolean"), .boolean)
        XCTAssertNil(StackItemType.valueOf(31))
        XCTAssertNil(StackItemType(rawValue: "Enum"))
        // anyStackItemValueToString
    }
    
    func testStackItemValues() {
        let trueBool = BooleanStackItem(true)
        XCTAssertEqual(try? trueBool.getInteger(), 1)
        XCTAssertEqual(try? trueBool.getString(), "true")
        
        let falseBool = BooleanStackItem(false)
        XCTAssertEqual(try? falseBool.getInteger(), 0)
        XCTAssertEqual(try? falseBool.getString(), "false")
        
        let buffer = BufferStackItem("0x010203".bytesFromHex)
        XCTAssertTrue(try! buffer.getBoolean())
        
        let buffer2 = BufferStackItem("0x000000".bytesFromHex)
        XCTAssertFalse(try! buffer2.getBoolean())
        
        let byteString1 = ByteStringStackItem("010203".bytesFromHex)
        XCTAssertThrowsError(try byteString1.getAddress())
        
        let byteString2 = ByteStringStackItem([])
        XCTAssertThrowsError(try byteString2.getByteArray())
        
        let intOne = IntegerStackItem(1)
        XCTAssertTrue(try! intOne.getBoolean())
        
        let intZero = IntegerStackItem(0)
        XCTAssertFalse(try! intZero.getBoolean())
        
        let intThousand = IntegerStackItem(1000)
        XCTAssertEqual(try? intThousand.getString(), "1000")
        print(try! intThousand.getByteArray())
        XCTAssertEqual(try? intThousand.getHexString(), "e803")
        XCTAssertEqual(try? intThousand.getByteArray(), "e803".bytesFromHex)
        
        let intNil = IntegerStackItem(nil)
        XCTAssertThrowsError(try intNil.getString())
        XCTAssertThrowsError(try intNil.getHexString())
        XCTAssertThrowsError(try intNil.getByteArray())
        
        let anyNil = AnyStackItem(nil)
        XCTAssertEqual(anyNil.string, "Any{value='null'}")
    }
    
    func testCompareStackItems() {
        let buffer1 = BufferStackItem("010203".bytesFromHex)
        let buffer2 = BufferStackItem("010203".bytesFromHex)
        let byteString1 = ByteStringStackItem("010203".bytesFromHex)
        let byteString2 = ByteStringStackItem("010203".bytesFromHex)
        
        assertEqual(buffer1, buffer1)
        assertEqual(buffer1, buffer2)
        assertNotEqual(buffer1, byteString1)
        assertEqual(byteString1, byteString1)
        assertEqual(byteString1, byteString2)
        assertNotEqual(byteString1, buffer2)
    }
    
    func testListToString() {
        let items: [StackItem] = [ByteStringStackItem("word".bytes), IntegerStackItem(1)]
        let stackItem = ArrayStackItem(items)
        XCTAssertEqual(stackItem.valueString, "ByteString{value='776f7264'}, Integer{value='1'}")
    }
    
    func testMapToString() {
        let items: [(StackItem, StackItem)] = [
            (ByteStringStackItem("key1".bytes), IntegerStackItem(1)),
            (ByteStringStackItem("key2".bytes), IntegerStackItem(0))
        ]
        let stackItem = MapStackItem(items)
        XCTAssert(stackItem.valueString.contains("ByteString{value='6b657932'} -> Integer{value='0'}"))
        XCTAssert(stackItem.valueString.contains("ByteString{value='6b657931'} -> Integer{value='1'}"))
    }
    
    private func assertDecode<T: Equatable>(_ json: String, _ function: (StackItem) -> () throws -> T,
                                            _ type: StackItemType, _ value: T?) -> StackItem {
        let jsonDecoder = JSONDecoder()
        let data = "{\"value\": \(json)}".data(using: .utf8)!
        let stackItem = try! jsonDecoder.decode(StackItemTestWrapper.self, from: data).value
        XCTAssertEqual(stackItem.type, type)
        XCTAssertEqual(try? function(stackItem)(), value)
        return stackItem
    }
    
    private func assertCastThrows(_ json: String, _ function: (StackItem) -> () throws -> Any,
                                  _ actualType: StackItemType? = nil, _ actualValue: String? = nil) {
        let jsonDecoder = JSONDecoder()
        let data = "{\"value\": \(json)}".data(using: .utf8)!
        let stackItem = try! jsonDecoder.decode(StackItemTestWrapper.self, from: data).value
        XCTAssertThrowsError(try function(stackItem)()) { error in
            if let type = actualType?.rawValue {
                XCTAssert(error.localizedDescription.contains(type))
            }
            if let actualValue = actualValue {
                XCTAssert(error.localizedDescription.contains(actualValue))
            }
        }
    }
    
    private func assertEqual(_ s1: StackItem, _ s2: StackItem) {
        XCTAssert(s1 == s2)
    }
    
    private func assertNotEqual(_ s1: StackItem, _ s2: StackItem) {
        XCTAssert(s1 != s2)
    }
    
    private func assertType(_ stackItem: StackItem, _ type: StackItemType) {
        XCTAssertEqual(stackItem.type, type)
    }
    
    private func decodeStackItem(_ json: String) -> StackItem {
        let jsonDecoder = JSONDecoder()
        let data = "{\"value\": \(json)}".data(using: .utf8)!
        let stack = try! jsonDecoder.decode(StackItemTestWrapper.self, from: data)
        return stack.value
    }
    
}

public class StackItemTestWrapper: Codable {
    @DynamicDecodingWrapper<StackItemTypeCodingKey> public var value: StackItem
}
