
import Foundation
import SwiftECC

protocol NeoSerializable {
    func deserialize(_ reader: BinaryReader) throws
    func serialize(_ writer: BinaryWriter)
    var size: Int { get }
}

extension NeoSerializable {
    
    func toArray() -> Bytes {
        let writer = BinaryWriter()
        serialize(writer)
        return writer.toArray()
    }
    
}

