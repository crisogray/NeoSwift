
import BigInt
import Foundation

public class BinaryReader {
    
    public var position: Int = 0
    public var available: Int {
        return array.count - position
    }
    
    private let array: Bytes
    private var marker: Int = -1
    
    init(_ input: Bytes) {
        array = input
    }
    
    public func mark() {
        marker = position
    }
    
    public func reset() {
        position = marker
    }
    
    public func readBoolean() -> Bool {
        let b: Bool = array[position] == 1
        position += 1
        return b
    }
    
    public func readByte() -> Byte {
        let b: Byte = array[position]
        position += 1
        return b
    }
    
    public func readUnsignedByte() -> Int {
        return Int(readByte())
    }
    
    public func readBytes(_ length: Int) throws -> Bytes {
        let p = position
        position += length
        return Bytes(array[p..<(p + length)])
    }
    
    public func readUInt16() -> UInt16 {
        let bytes: Bytes = Bytes(array[position..<position + 2])
        position += 2
        return bytes.toNumeric()
    }
    
    public func readInt16() -> Int16 {
        let bytes: Bytes = Bytes(array[position..<position + 2])
        position += 2
        return bytes.toNumeric()
    }
    
    public func readUInt32() -> UInt32 {
        let bytes: Bytes = Bytes(array[position..<position + 4])
        position += 4
        return bytes.toNumeric()
    }
    
    public func readInt32() -> Int32 {
        let bytes: Bytes = Bytes(array[position..<position + 4])
        position += 4
        return bytes.toNumeric()
    }
    
    public func readInt64() -> Int64 {
        let bytes: Bytes = Bytes(array[position..<position + 8])
        position += 8
        return bytes.toNumeric()
    }
    
    public func readEncodedECPoint() throws -> Bytes {
        let byte = readByte()
        if byte == 0x02 || byte == 0x03 {
            return try byte + readBytes(32)
        }
        throw "Failed parsing encoded EC point."
    }
    
    public func readECPoint() throws -> ECPoint {
        let encoded: Bytes
        let byte = readByte()
        switch byte {
        case 0x00: encoded = [0x00]
        case 0x02, 0x03: encoded = try byte + readBytes(32)
        case 0x04: encoded = try byte + readBytes(64)
        default: throw "Failed parsing EC point."
        }
        return try NeoConstants.SECP256R1_DOMAIN.decodePoint(encoded)
    }
    
    public func readSerializable<T: NeoSerializable>() throws -> T {
        return try T.deserialize(self)
    }
    
    public func readSerializableListVarBytes<T: NeoSerializable>() -> [T] {
        let length = readVarInt(0x10000000)
        var bytesRead = 0, offset = position
        var list: [T] = []
        while bytesRead < length {
            if let t = try? T.deserialize(self) { list.append(t) }
            bytesRead = position - offset
        }
        return list
    }
    
    public func readSerializableList<T: NeoSerializable>() -> [T] {
        let length = readVarInt(0x10000000)
        var list: [T] = []
        for _ in 0..<length {
            if let t = try? T.deserialize(self) { list.append(t) }
        }
        return list
    }
    
    public func readVarBytes() throws -> Bytes {
        return try readVarBytes(0x1000000)
    }
    
    public func readVarString() throws -> String {
        guard let string = try String(bytes: readVarBytes(), encoding: .utf8) else {
            throw "Failed reading var String."
        }
        return string
    }
    
    public func readPushData() throws -> Bytes {
        let byte = readByte()
        let size: Int
        switch byte {
        case OpCode.pushData1.opcode: size = readUnsignedByte()
        case OpCode.pushData2.opcode: size = Int(readInt16())
        case OpCode.pushData4.opcode: size = Int(readInt32())
        default: throw "Stream did not contain a PUSHDATA OpCode at the current position."
        }
        return try readBytes(size)
    }
    
    public func readVarBytes(_ max: Int) throws -> Bytes {
        return try readBytes(readVarInt(max))
    }
    
    public func readVarInt() -> Int {
        return readVarInt(Int.max)
    }
    
    public func readVarInt(_ max: Int) -> Int {
        let first = readUnsignedByte()
        switch first {
        case 0xFD: return Int(readInt16())
        case 0xFE: return Int(readInt32())
        case 0xFF: return Int(readInt64())
        default: return Int(first)
        }
    }
    
    public func readPushString() throws -> String {
        guard let string = try String(bytes: readPushData(), encoding: .utf8) else {
            throw "Couldn't parse PUSHINT OpCode"
        }
        return string
    }
    
    public func readPushInt() throws -> Int {
        guard let int = try readPushBigInt().asInt() else {
            throw "Couldn't parse PUSHINT OpCode"
        }
        return int
    }
    
    public func readPushBigInt() throws -> BInt {
        let byte = readByte()
        if byte.isBetween(.pushM1, .push16) {
            return BInt(Int(byte) - Int(OpCode.push0.opcode))
        }
        var count = -1
        switch OpCode(rawValue: byte) {
        case .pushInt8: count = 1
        case .pushInt16: count = 2
        case .pushInt32: count = 4
        case .pushInt64: count = 8
        case .pushInt128: count = 16
        case .pushInt256: count = 32
        default: throw "Couldn't parse PUSHINT OpCode"
        }
        return try BInt(signed: readBytes(count))
    }
    
}
