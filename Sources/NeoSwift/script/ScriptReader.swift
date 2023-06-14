
import Foundation

public class ScriptReader {
    
    public static func getInteropServiceCode(_ hash: String) -> InteropService? {
        return InteropService.allCases.first(where: { $0.hash == hash })
    }
    
    public static func convertToOpCodeString(_ script: String) -> String {
        return convertToOpCodeString(script.bytesFromHex)
    }
    
    public static func convertToOpCodeString(_ script: Bytes) -> String {
        let reader = BinaryReader(script)
        var s = ""
        while reader.position < script.count {
            guard let opCode = OpCode(rawValue: reader.readByte()) else {
                continue
            }
            s += "\(opCode)".uppercased()
            guard let size = opCode.operandSize else {
                s += "\n"
                continue
            }
            do {
                if size.size > 0 {
                    try s += " \(reader.readBytes(size.size).toHexString())"
                } else if size.prefixSize > 0 {
                    let prefixSize = try getPrefixSize(reader, size)
                    try s += " \(prefixSize) " + reader.readBytes(prefixSize).toHexString()
                }
            } catch { continue }
            s += "\n"
        }
        return s
    }
    
    private static func getPrefixSize(_ reader: BinaryReader, _ size: OpCode.OperandSize) throws -> Int {
        switch size.prefixSize {
        case 1: return reader.readUnsignedByte()
        case 2: return Int(reader.readInt16())
        case 4: return Int(reader.readInt32())
        default: throw NeoSwiftError.unsupportedOperation("Only operand prefix sizes 1, 2, and 4 are supported, but got \(size.prefixSize).")
        }
    }
    
}

