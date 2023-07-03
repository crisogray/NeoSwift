
import Foundation

public struct WitnessRule: Codable, Hashable {
    
    public let action: WitnessAction
    public let condition: WitnessCondition
    
    public init(action: WitnessAction, condition: WitnessCondition) {
        self.action = action
        self.condition = condition
    }
    
}

extension WitnessRule: NeoSerializable {
    
    public var size: Int { return 1 + condition.size }
    
    public func serialize(_ writer: BinaryWriter) {
        writer.writeByte(action.byte)
        writer.writeSerializableFixed(condition)
    }
    
    public static func deserialize(_ reader: BinaryReader) throws -> WitnessRule {
        let action = try WitnessAction.throwingValueOf(reader.readByte())
        let condition = try WitnessCondition.deserialize(reader)
        return WitnessRule(action: action, condition: condition)
    }
    
}
