
import Foundation


public enum NeoVMStateType: String, CaseIterable {

    case none = "NONE", halt = "HALT", fault = "FAULT", `break` = "BREAK"

    var int: Int {
        switch self {
        case .none: return 0
        case .halt: return 1
        case .fault: return 1 << 1
        case .break: return 1 << 2
        }
    }

    static func valueOf(_ int: Int) -> NeoVMStateType? {
        return allCases.first { $0.int == int }
    }

}
