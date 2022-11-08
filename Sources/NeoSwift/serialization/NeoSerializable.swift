
import Foundation
import SwiftECC

protocol NeoSerializable {
    static func deserialize(_ reader: BinaryReader) -> Self?
    func serialize(_ writer: BinaryWriter)
    var size: Int { get }
}

extension NeoSerializable {
    
    func toArray() -> Bytes {
        let writer = BinaryWriter()
        serialize(writer)
        return writer.toArray()
    }
    
    static func from(_ bytes: Bytes) -> Self? {
        return Self.deserialize(BinaryReader(bytes))
    }
    
}

extension Array where Element: NeoSerializable {
    
    var varSize: Int {
        count.varSize + map { $0.size }.reduce(0, +)
    }
    
}
