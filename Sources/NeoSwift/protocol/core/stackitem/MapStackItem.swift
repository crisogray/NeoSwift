
import Foundation
import DynamicCodableKit

public struct MapStackItem: StackItem, Hashable {
    
    public var type: StackItemType = .map
    private let value: [StackItemMapEntry]
    
    init(_ map: [(StackItem, StackItem)]) {
        value = map.map{ StackItemMapEntry(key: $0, value: $1) }
    }
    
    public var valueString: String {
        return value.map { $0.key.string + " -> " + $0.value.string }.joined(separator: ", ")
    }
    
    public func getValue() -> AnyHashable {
        return value
    }
    
    public func getMap() throws -> [(StackItem, StackItem)] {
        return value.map { ($0.key, $0.value) }
    }

}

public struct StackItemMapEntry: Codable, Hashable {
    
    @DynamicDecodingWrapper<StackItemTypeCodingKey> var key: StackItem
    @DynamicDecodingWrapper<StackItemTypeCodingKey> var value: StackItem
    
    public static func == (lhs: StackItemMapEntry, rhs: StackItemMapEntry) -> Bool {
        return lhs.key.anyHashable() == rhs.key.anyHashable() && lhs.value.anyHashable() == rhs.value.anyHashable()
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(key.anyHashable())
        hasher.combine(value.anyHashable())
    }
    
}

extension Array where Element == (StackItem, StackItem) {
    
    var keys: [StackItem] {
        return map(\.0)
    }
    
    var values: [StackItem] {
        return map(\.1)
    }
    
}
