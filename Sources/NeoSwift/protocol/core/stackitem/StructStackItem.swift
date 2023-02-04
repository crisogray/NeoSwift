
import Foundation
import DynamicCodableKit

public struct StructStackItem: StackItem, Hashable {
    
    public var type: StackItemType = .struct
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
    
    public static func == (lhs: StructStackItem, rhs: StructStackItem) -> Bool {
        return (try? lhs.getValue()) == (try? rhs.getValue())
    }
    
}


