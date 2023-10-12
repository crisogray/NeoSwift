
import Foundation

/// Reads NeoVM scripts and converts them to a more human-readable representation.
public class ScriptReader {
    
    /// Gets the InteropService that creates the provided hash.
    /// - Parameter hash: The hash of the InteropService
    /// - Returns: The InteropService matching the hash
    public static func getInteropServiceCode(_ hash: String) -> InteropService? {
        return InteropService.allCases.first(where: { $0.hash == hash })
    }
    
    /// Converts a NeoVM script into a string representation using OpCode names.
    /// - Parameter script: The script to convert in hexadecimal format
    /// - Returns: The OpCode representation of the script
    public static func convertToOpCodeString(_ script: String) -> String {
        return convertToOpCodeString(script.bytesFromHex)
    }
    
    /// Converts a NeoVM script into a string representation using OpCode names.
    /// - Parameter script: The script to convert
    /// - Returns: The OpCode representation of the script
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

