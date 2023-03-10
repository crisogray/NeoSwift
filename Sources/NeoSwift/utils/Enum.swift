

public protocol ByteEnum: Codable, Hashable, CaseIterable {
    var byte: Byte { get }
    var jsonValue: String { get }
}

public extension ByteEnum {
    
    static func valueOf(_ byte: Byte) -> Self? {
        return allCases.first { $0.byte == byte }
    }
    
    static func fromJsonValue(_ value: String) -> Self? {
        return allCases.first { $0.jsonValue == value }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let string = try? container.decode(String.self),
            let value = Self.fromJsonValue(string) {
           self = value
        } else if let byte = try? container.decode(Byte.self),
           let value = Self.valueOf(byte) {
            self = value
        } else if let int = try? container.decode(Int.self),
                  let value = Self.valueOf(Byte(int)) {
            self = value
        } else {
            throw "\(String(describing: Self.self)) value type not found"
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(jsonValue)
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(jsonValue)
        hasher.combine(byte)
    }
    
}
