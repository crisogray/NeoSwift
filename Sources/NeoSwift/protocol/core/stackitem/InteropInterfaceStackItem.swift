
import Foundation

public struct InteropInterfaceStackItem: StackItem, Hashable {

    public var type: StackItemType = .interopInterface
    public var interface: String
    public var id: String
    
    public var valueString: String {
        return id
    }
    
    public func getValue() throws -> AnyHashable {
        return id
    }
    
    public func getIteratorId() throws -> String {
        return id
    }
    
    public func getInterfaceName() throws -> String {
        return interface
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(type)
        hasher.combine(interface)
        hasher.combine(id)
    }
    
}


