
import Foundation

public struct WitnessRule: Codable, Hashable {
    
    let action: WitnessAction
    let condition: WitnessCondition
    
}

extension WitnessRule: NeoSerializable {
    
    public var size: Int { return 1 + condition.size }
    
    public func serialize(_ writer: BinaryWriter) {
        writer.writeByte(action.byte)
        writer.writeSerializableFixed(condition)
    }
    
    public static func deserialize(_ reader: BinaryReader) -> WitnessRule? {
        guard let action = WitnessAction.valueOf(reader.readByte()),
              let condition = WitnessCondition.deserialize(reader) else {
            return nil
        }
        return WitnessRule(action: action, condition: condition)
    }
    
}
