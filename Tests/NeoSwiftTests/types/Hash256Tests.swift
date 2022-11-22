
import XCTest
@testable import NeoSwift

class Hash256Tests: XCTestCase {
 
    public func testFromValidHash() {
        XCTAssertEqual(
            try? Hash256("0xb804a98220c69ab4674e97142beeeb00909113d417b9d6a67c12b71a3974a21a").string,
            "b804a98220c69ab4674e97142beeeb00909113d417b9d6a67c12b71a3974a21a"
        )
        XCTAssertEqual(
            try? Hash256("b804a98220c69ab4674e97142beeeb00909113d417b9d6a67c12b71a3974a21a").string,
            "b804a98220c69ab4674e97142beeeb00909113d417b9d6a67c12b71a3974a21a"
        )
    }
    
    public func testCreationThrows() {
        assertErrorMessage("String argument is not hexadecimal.") {
            try Hash256("b804a98220c69ab4674e97142beeeb00909113d417b9d6a67c12b71a3974a21ae")
        }
        assertErrorMessage("String argument is not hexadecimal.") {
            try Hash256("g804a98220c69ab4674e97142beeeb00909113d417b9d6a67c12b71a3974a21a")
        }
        assertErrorMessage("Hash must be 32 bytes long but was 31 bytes.") {
            try Hash256("0xb804a98220c69ab4674e97142beeeb00909113d417b9d6a67c12b71a3974a2")
        }
        assertErrorMessage("Hash must be 32 bytes long but was 33 bytes.") {
            try Hash256("0xb804a98220c69ab4674e97142beeeb00909113d417b9d6a67c12b71a3974a21a12")
        }
    }
    
    public func testFromBytes() {
        XCTAssertEqual(
            try? Hash256("b804a98220c69ab4674e97142beeeb00909113d417b9d6a67c12b71a3974a21a".bytesFromHex).string,
            "b804a98220c69ab4674e97142beeeb00909113d417b9d6a67c12b71a3974a21a"
        )
    }
    
    public func testToArray() {
        XCTAssertEqual(
            try? Hash256("b804a98220c69ab4674e97142beeeb00909113d417b9d6a67c12b71a3974a21a").toLittleEndianArray(),
            "b804a98220c69ab4674e97142beeeb00909113d417b9d6a67c12b71a3974a21a".bytesFromHex.reversed()
        )
    }
    
    public func testSerializeAndDeserialize() {
        let writer = BinaryWriter()
        let string = "b804a98220c69ab4674e97142beeeb00909113d417b9d6a67c12b71a3974a21a"
        let data: Bytes = string.bytesFromHex.reversed()
        
        try? Hash256(string).serialize(writer)
        
        XCTAssertEqual(writer.toArray(), data)
        XCTAssertEqual(Hash256.from(data)?.string, string)
    }
    
    public func testEquals() {
        let bytes1: Bytes = "1aa274391ab7127ca6d6b917d413919000ebee2b14974e67b49ac62082a904b8".bytesFromHex.reversed()
        let bytes2: Bytes = "b43034ab680d646f8b6ca71647aa6ba167b2eb0b3757e545f6c2715787b13272".bytesFromHex.reversed()
        let hash1 = try! Hash256(bytes1)
        let hash2 = try! Hash256(bytes2)
        let hash3 = try! Hash256("0xb804a98220c69ab4674e97142beeeb00909113d417b9d6a67c12b71a3974a21a")
        XCTAssertNotEqual(hash1, hash2)
        XCTAssertEqual(hash1, hash1)
        XCTAssertEqual(hash1, hash3)
        XCTAssertEqual(hash1.hashValue, hash3.hashValue)
    }
    
    public func testCompareTo() {
        let bytes1: Bytes = "1aa274391ab7127ca6d6b917d413919000ebee2b14974e67b49ac62082a904b8".bytesFromHex.reversed()
        let bytes2: Bytes = "b43034ab680d646f8b6ca71647aa6ba167b2eb0b3757e545f6c2715787b13272".bytesFromHex.reversed()
        let hash1 = try! Hash256(bytes1)
        let hash2 = try! Hash256(bytes2)
        let hash3 = try! Hash256("0xf4609b99e171190c22adcf70c88a7a14b5b530914d2398287bd8bb7ad95a661c")
        XCTAssertGreaterThan(hash1, hash2)
        XCTAssertGreaterThan(hash3, hash1)
        XCTAssertGreaterThan(hash3, hash2)
    }
    
    public func testSize() {
        let hash = try! Hash256("b804a98220c69ab4674e97142beeeb00909113d417b9d6a67c12b71a3974a21a")
        XCTAssertEqual(hash.size, 32)
    }
    
    private func assertErrorMessage(_ message: String, _ expression: () throws -> Any) {
        XCTAssertThrowsError(try expression()) { error in
            XCTAssertEqual(error.localizedDescription, message)
        }
    }
    
}
