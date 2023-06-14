
import BigInt
import Foundation

public extension Bytes {
    
    var bInt: BInt {
        return BInt(magnitude: self)
    }
    
    var base64Encoded: String {
        return toBase64()
    }
    
    var base58Encoded: String {
        return Base58.encode(self)
    }
    
    var base58CheckEncoded: String {
        return Base58.base58CheckEncode(self)
    }
    
    var noPrefixHex: String {
        return toHexString().cleanedHexPrefix
    }
    
    var varSize: Int {
        return count.varSize + count
    }
    
    var scripthashToAddress: String {
        let script: Bytes = NeoSwiftConfig.DEFAULT_ADDRESS_VERSION + reversed()
        let checksum = script.hash256().prefix(upTo: 4)
        return (script + checksum).base58Encoded
    }
    
    func toPadded(length: Int, trailing: Bool = false) throws -> Bytes {
        let firstZero = self.first == 0
        let srcOffset = firstZero ? 1 : 0
        let bytesLength = self.count - srcOffset
        guard bytesLength <= length else {
            throw NeoSwiftError.illegalArgument("Input is too large to put in byte array of size \(length)")
        }
        if trailing {
            return self[srcOffset..<bytesLength] + Bytes(repeating: 0, count: length - bytesLength)
        }
        return Bytes(repeating: 0, count: length - bytesLength) + self[srcOffset..<bytesLength]
    }
    
    func toNumeric<T: Numeric>(littleEndian: Bool = false) -> T {
        let b = littleEndian ? reversed() : self
        return Data(bytes: b, count: count)
            .withUnsafeBytes { return $0.load(as: T.self) }
    }
    
    static func ^ (lhs: Bytes, rhs: Bytes) throws -> Bytes {
        guard lhs.count == rhs.count else {
            throw NeoSwiftError.illegalArgument("Arrays do not have the same length to perform the XOR operation.")
        }
        return lhs.enumerated().map { $1 ^ rhs[$0] }
    }
    
}

extension Byte {
    func isBetween(_ opCode1: OpCode, _ opCode2: OpCode) -> Bool {
        return self >= opCode1.opcode && self <= opCode2.opcode
    }
}
