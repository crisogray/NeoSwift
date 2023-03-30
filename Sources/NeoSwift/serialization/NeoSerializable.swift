
import Foundation
import SwiftECC

public protocol NeoSerializable {
    var size: Int { get }
    func serialize(_ writer: BinaryWriter)
    static func deserialize(_ reader: BinaryReader) throws -> Self
    func toArray() -> Bytes
}

extension NeoSerializable {
    
    public func toArray() -> Bytes {
        let writer = BinaryWriter()
        serialize(writer)
        return writer.toArray()
    }
    
    public static func from(_ bytes: Bytes) -> Self? {
        return try? Self.deserialize(BinaryReader(bytes))
    }
    
}

extension Array where Element: NeoSerializable {
    
    public var varSize: Int {
        count.varSize + map { $0.size }.reduce(0, +)
    }
    
}
