
import Foundation


public enum NeoVMStateType: String, CaseIterable {

    case none = "NONE", halt = "HALT", fault = "FAULT", `break` = "BREAK"

    var jsonvalue: String {
        return rawValue
    }
    
    var int: Int {
        switch self {
        case .none: return 0
        case .halt: return 1
        case .fault: return 1 << 1
        case .break: return 1 << 2
        }
    }
    
    static func fromJsonValue(_ value: String?) -> NeoVMStateType? {
        guard let value = value, !value.isEmpty else { return NeoVMStateType.none }
        return .init(rawValue: value)
    }
    
    static func fromIntValue(_ int: Int?) -> NeoVMStateType? {
        guard let int = int else { return NeoVMStateType.none }
        return allCases.first { $0.int == int }
    }

}
