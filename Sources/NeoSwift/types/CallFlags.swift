
import Foundation

public enum CallFlags: CaseIterable {
    
    case none, readStates, writeStates, allowCall, allowNotify, states, readOnly, all
    
    public var value: Byte {
        switch self {
        case .none: return 0
        case .readStates: return 0b00000001
        case .writeStates: return 0b00000010
        case .allowCall: return 0b00000100
        case .allowNotify: return  0b00001000
        case .states: return Self.readStates.value | Self.writeStates.value
        case .readOnly: return Self.readStates.value | Self.allowCall.value
        case .all: return Self.states.value | Self.allowCall.value | Self.allowNotify.value
        }
    }
    
    public static func fromValue(_ value: Byte) throws -> CallFlags {
        guard let c = CallFlags.allCases.first(where: { $0.value == value }) else {
            throw "There exists no call flag with the provided byte value (%d)"
        }
        return c
    }
    
}
