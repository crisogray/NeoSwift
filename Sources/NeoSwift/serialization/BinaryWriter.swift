
import Foundation

public class BinaryWriter {
    
    private var array: Bytes = []
    
    public init() {}
    
    public var size: Int {
        return array.count
    }
    
    public func write(_ buffer: Bytes) {
        array += buffer
    }
    
    public func writeBoolean(_ v: Bool) {
        writeByte(v ? 1 : 0)
    }
    
    public func writeByte(_ v: Byte) {
        array += [v]
    }
    
    public func writeDouble(_ v: Double) {
        array += v.bigEndianBytes
    }
    
    public func writeECPoint(_ v: ECPoint) throws {
        array += try v.getEncoded(true)
    }
    
    public func writeFixedString(_ v: String?, length: Int) throws {
        guard let bytes = v?.bytes, bytes.count <= length else {
            throw NeoSwiftError.illegalArgument("String to write is longer than specified length")
        }
        array += try bytes.toPadded(length: length, trailing: true)
    }
    
    public func writeFloat(_ v: Float) {
        array += v.bigEndianBytes
    }
    
    public func writeInt32(_ v: Int32) {
        array += v.bigEndianBytes
    }
    
    public func writeInt64(_ v: Int64) {
        array += v.bigEndianBytes
    }
    
    public func writeUInt32(_ v: UInt32) {
        array += v.bigEndianBytes
    }
    
    public func writeSerializableVariableBytes(_ v: NeoSerializable) {
        writeVarInt(v.toArray().count)
        v.serialize(self)
    }
    
    public func writeSerializableVariable(_ v: [NeoSerializable]) {
        writeVarInt(v.count)
        writeSerializableFixed(v)
    }
    
    public func writeSerializableVariableBytes(_ v: [NeoSerializable]) {
        writeVarInt(v.reduce(0) { $0 + $1.toArray().count })
        writeSerializableFixed(v)
    }
    
    public func writeSerializableFixed(_ v: NeoSerializable) {
        v.serialize(self)
    }
    
    public func writeSerializableFixed(_ v: [NeoSerializable]) {
        v.forEach { $0.serialize(self) }
    }
    
    public func writeUInt16(_ v: UInt16) {
        array += v.bigEndianBytes
    }
    
    public func writeVarBytes(_ v: Bytes) {
        writeVarInt(v.count)
        array += v
    }
    
    public func writeVarInt(_ v: Int) {
        guard v >= 0 else {
            return
        }
        if (v < 0xFD) {
            writeByte(Byte(v))
        } else if (v <= 0xFFFF) {
            writeByte(0xFD)
            writeUInt16(UInt16(v))
        } else if (v <= 0xFFFFFFFF) {
            writeByte(0xFE)
            writeUInt32(UInt32(v))
        } else {
            writeByte(0xFF)
            writeInt64(Int64(v))
        }
    }
    
    public func writeVarString(_ v: String) {
        writeVarBytes(v.bytes)
    }
    
    public func reset() {
        array = []
    }
    
    public func toArray() -> Bytes {
        let out = array
        reset()
        return out
    }
    
}
