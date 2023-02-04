
import Foundation
import DynamicCodableKit

public struct ArrayStackItem: StackItem, Hashable {
    
    public var type: StackItemType = .array
    @StrictDynamicDecodingArrayWrapper<StackItemTypeCodingKey> var value: [StackItem]
    
    init(_ value: [StackItem]) {
        self.value = value
    }
    
    public var valueString: String {
        return value.map(\.string).joined(separator: ", ")
    }
    
    public func getValue() throws -> AnyHashable {
        return value.map { $0.anyHashable() }
    }
    
    public func getList() throws -> [StackItem] {
        return value
    }
    
    public static func == (lhs: ArrayStackItem, rhs: ArrayStackItem) -> Bool {
        return (try? lhs.getValue()) == (try? rhs.getValue())
    }
    
}

