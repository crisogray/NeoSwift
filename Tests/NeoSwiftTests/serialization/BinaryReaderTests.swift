
import BigInt
import XCTest
@testable import NeoSwift

class BinaryReaderTests: XCTestCase {
    
    public func testReadPushDataBytes() {
        let prefixCountMap = [
            "0c01": 1,
            "0cff": 255,
            "0d0001": 256,
            "0d0010": 4096,
            "0e00000100": 65536
        ]
        for (p, c) in prefixCountMap {
            let bytes = Bytes(repeating: 0x01, count: c)
            readPushDataBytesAndAssert(p.bytesFromHex + bytes, bytes)
        }
    }
    
    public func testFailReadPushData() {
        let data = "4b".bytesFromHex + 0x01 + "0000".bytesFromHex
        XCTAssertThrowsError(try BinaryReader(data).readPushData()) { error in
            XCTAssertEqual(error.localizedDescription, "Stream did not contain a PUSHDATA OpCode at the current position.")
        }
    }
    
    public func testReadPushDataString() {
        readPushDataStringAndAssert("0c00".bytesFromHex, "")
        readPushDataStringAndAssert("0c0161".bytesFromHex, "a")
        
        let bytes = Bytes(repeating: 0, count: 10000)
        readPushDataStringAndAssert("0e10270000".bytesFromHex + bytes, String(data: Data(bytes), encoding: .utf8)!)
    }
    
    public func testReadPushDataBigInteger() {
        readPushDataIntegerAndAssert("10".bytesFromHex, .ZERO)
        readPushDataIntegerAndAssert("11".bytesFromHex, .ONE)
        readPushDataIntegerAndAssert("0f".bytesFromHex, BInt(-1))
        readPushDataIntegerAndAssert("20".bytesFromHex, BInt(16))
    }
    
    public func testReadUInt32() {
        readUInt32AndAssert([0xff, 0xff, 0xff, 0xff], 4_294_967_295)
        readUInt32AndAssert([0x01, 0x00, 0x00, 0x00], 1)
        readUInt32AndAssert([0x00, 0x00, 0x00, 0x00], 0)
        readUInt32AndAssert([0x8c, 0xae, 0x00, 0x00, 0xff], 44_684)
    }
    
    public func testReadInt64() {
        readInt64AndAssert([0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80], Int64.min)
        readInt64AndAssert([0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x7f], Int64.max)
        readInt64AndAssert([0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00], 0)
        readInt64AndAssert([0x11, 0x33, 0x22, 0x8c, 0xae, 0x00, 0x00, 0x00, 0xff], 749_675_361_041)
    }
    
    private func readUInt32AndAssert(_ input: Bytes, _ expected: UInt32) {
        XCTAssertEqual(reader(input).readUInt32(), expected)
    }
    
    private func readInt64AndAssert(_ input: Bytes, _ expected: Int64) {
        XCTAssertEqual(reader(input).readInt64(), expected)
    }
    
    private func readPushDataBytesAndAssert(_ input: Bytes, _ expected: Bytes) {
        XCTAssertEqual(try? reader(input).readPushData(), expected)
    }
    
    private func readPushDataStringAndAssert(_ input: Bytes, _ expected: String) {
        XCTAssertEqual(try? reader(input).readPushString(), expected)
    }
    
    private func readPushDataIntegerAndAssert(_ input: Bytes, _ expected: BInt) {
        XCTAssertEqual(try? reader(input).readPushBigInt(), expected)
    }
    
    private func reader(_ input: Bytes) -> BinaryReader {
        return BinaryReader(input)
    }
    
}
