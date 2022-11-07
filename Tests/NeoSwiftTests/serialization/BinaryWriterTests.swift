
import XCTest
@testable import NeoSwift

class BinaryWriterTests: XCTestCase {
    
    private let writer = BinaryWriter()
    
    public func testWriteUInt32() {
        let t = UInt32(2.toPowerOf(32) - 1)
        writer.writeUInt32(t)
        testAndReset([0xff, 0xff, 0xff, 0xff])
        
        writer.writeUInt32(0)
        testAndReset([0, 0, 0, 0])
        
        writer.writeUInt32(12345)
        testAndReset([0x39, 0x30, 0, 0])
    }
    
    public func testWriteInt64() {
        writer.writeInt64(Int64.max)
        testAndReset([0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x7f])
        
        writer.writeInt64(Int64.min)
        testAndReset([0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80])
        
        writer.writeInt64(0)
        testAndReset([0, 0, 0, 0, 0, 0, 0, 0])
        
        writer.writeInt64(1234567890)
        testAndReset([0xd2, 0x02, 0x96, 0x49, 0x00, 0x00, 0x00, 0x00])
    }
    
    public func testWriteUInt16() {
        let t = UInt16(2.toPowerOf(16) - 1)
        writer.writeUInt16(t)
        testAndReset([0xff, 0xff])
        
        writer.writeUInt16(0)
        testAndReset([0, 0])
        
        writer.writeUInt16(12345)
        testAndReset([0x39, 0x30])
    }
    
    public func testWriteVarInt() {
        
        // v == 0, encode with one byte
        writer.writeVarInt(0)
        testAndReset([0])
        
        // v == 0xfd - 1, encode with one byte
        writer.writeVarInt(252)
        testAndReset([0xfc])
        
        // v == 0xfd, encode with uint16
        writer.writeVarInt(253)
        testAndReset([0xfd, 0xfd, 0x00])
        
        // v == 0xfd + 1, encode with uint16
        writer.writeVarInt(254)
        testAndReset([0xfd, 0xfe, 0x00])
        
        // v == 0xffff - 1, encode with uint16
        writer.writeVarInt(65_534)
        testAndReset([0xfd, 0xfe, 0xff])
        
        // v == 0xffff, encode with uint16
        writer.writeVarInt(65_535)
        testAndReset([0xfd, 0xff, 0xff])
        
        // v == 0xffff + 1, encode with uint32
        writer.writeVarInt(65_536)
        testAndReset([0xfe, 0x00, 0x00, 0x01, 0x00])
        
        // v == 0xffffffff - 1, encode with uint32
        writer.writeVarInt(4_294_967_294)
        testAndReset([0xfe, 0xfe, 0xff, 0xff, 0xff])
        
        // v == 0xffffffff, encode with uint32
        writer.writeVarInt(4_294_967_295)
        testAndReset([0xfe, 0xff, 0xff, 0xff, 0xff])
        
        // v == 0xffffffff + 1, encode with uint64
        writer.writeVarInt(4_294_967_296)
        testAndReset([0xff, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00])
        
    }
    
    public func testWriteVarBytes() {
        writer.writeVarBytes("010203".bytesFromHex)
        testAndReset("03010203".bytesFromHex)
        
        let hex = "00102030102030102030102030102030102030102030102030102030102030102031020301020301020301020301020301020301020301020301020301020301020310203010203010203010203010203010203010203010203010203010203010203102030102030102030102030102030102030102030102030102030102030102030010203010203010203010203010203010203010203010203010203010203010203102030102030102030102030102030102030102030102030102030102030102031020301020301020301020301020301020301020301020301020301020301020310203010203010203010203010203010203010203010203010203010203010203"
        writer.writeVarBytes(hex.bytesFromHex)
        testAndReset(("fd" + "0601" + hex).bytesFromHex)
        
    }
    
    public func testWriteVarString() {
        writer.writeVarString("hello, world!")
        testAndReset("0d68656c6c6f2c20776f726c6421".bytesFromHex)
        
        let s = "hello, world!hello, world!hello, world!hello, world!hello, world!hello, world!hello, world!hello, world!hello, world!hello, world!hello, world!hello, world!hello, world!hello, world!hello, world!hello, world!hello, world!hello, world!hello, world!hello, world!hello, world!hello, world!hello, world!hello, world!hello, world!hello, world!hello, world!hello, world!hello, world!hello, world!hello, world!hello, world!hello, world!hello, world!hello, world!hello, world!hello, world!hello, world!hello, world!hello, world!hello, world!"
        writer.writeVarString(s)
        testAndReset("fd1502".bytesFromHex + s.bytes)
        
    }
    
    private func testAndReset(_ expected: Bytes) {
        XCTAssertEqual(writer.toArray(), expected)
        writer.reset()
    }
    
}
