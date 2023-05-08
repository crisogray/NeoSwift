
public struct RecordState: Codable, Hashable {
    
    public let name: String
    public let recordType: RecordType
    public let data: String
    
    public static func fromStackItem(_ stackItem: StackItem) throws -> RecordState {
        guard case .array(let list) = stackItem,
              let name = list[0].string,
              let byte = list[1].integer,
              let recordType = RecordType.valueOf(Byte(byte)),
              let data = list[2].string else {
            throw "Could not deserialise RecordState from the stack item."
        }
        return RecordState(name: name, recordType: recordType, data: data)
    }
    
}
