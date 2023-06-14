
public enum NeoVMStateType: String, Codable, CaseIterable {

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
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let string = try? container.decode(String.self),
           let value = NeoVMStateType.fromJsonValue(string) {
            self = value
        } else if let int = try? container.decode(Int.self),
                  let value = NeoVMStateType.fromIntValue(int) {
            self = value
        } else {
            throw NeoSwiftError.illegalArgument()
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
