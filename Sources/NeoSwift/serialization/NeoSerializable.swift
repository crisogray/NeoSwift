
import Foundation
import SwiftECC

protocol NeoSerializable {
    func deserialize(_ reader: BinaryReader) throws
    func serialize(_ writer: BinaryWriter) throws
    var size: Int { get }
}

extension NeoSerializable {
    

    
}

