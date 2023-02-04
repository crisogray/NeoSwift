
import Foundation

public struct BooleanStackItem: StackItem, Hashable {
    
    public var type: StackItemType = .boolean
    let value: Bool?
    
    public init(_ value: Bool?) {
        self.value = value
    }
    
    public init(from decoder: Decoder) throws {
        self.value = try Self.stringToType(decoder)
    }
    
    public func getValue() throws -> AnyHashable {
        return value
    }
    
    public func getBoolean() throws -> Bool {
        guard let value = value else {
            throw "Cannot get stack item value because it is null"
        }
        return value
    }
    
    public func getInteger() throws -> Int {
        guard let value = value else {
            throw "Cannot get stack item value because it is null"
        }
        return value ? 1 : 0
    }
    
    public func getString() throws -> String {
        guard let value = value else {
            throw "Cannot get stack item value because it is null"
        }
        return value ? "true" : "false"
    }
    
}
