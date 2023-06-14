

public protocol ByteEnum: Codable, Hashable, CaseIterable {
    var byte: Byte { get }
    var jsonValue: String { get }
}

public extension ByteEnum {
    
    static func throwingValueOf(_ byte: Byte) throws -> Self {
        guard let value = allCases.first(where: { $0.byte == byte }) else {
            throw NeoSwiftError.illegalArgument("\(String(describing: OracleResponseCode.self)) value type not found")
        }
        return value
    }
    
    static func valueOf(_ byte: Byte) -> Self? {
        return try? throwingValueOf(byte)
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
            throw NeoSwiftError.illegalArgument("\(String(describing: Self.self)) value type not found")
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
