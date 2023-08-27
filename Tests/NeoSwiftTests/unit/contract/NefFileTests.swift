
import XCTest
@testable import NeoSwift

class NefFileTests: XCTestCase {
    
    public let MAGIC = "3346454e".bytesFromHex.reversed().toHexString()
    public let TESTCONTRACT_COMPILER = "neon-3.0.0.0"
    public let TESTCONTRACT_COMPILER_HEX = "6e656f77336a2d332e302e3000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"
    public let RESERVED_BYTES = "0000"
    
    public let TESTCONTRACT_FILE = Bundle.module.url(forResource: "TestContract", withExtension: "nef")!
    public let TESTCONTRACT_FILE_TOO_LARGE = Bundle.module.url(forResource: "too_large", withExtension: "nef")!
    public let TESTCONTRACT_WITH_TOKENS_FILE = Bundle.module.url(forResource: "TestContractWithMethodTokens", withExtension: "nef")!
    public let TESTCONTRACT_SCRIPT_SIZE = "05"
    public let TESTCONTRACT_SCRIPT = "5700017840"
    public let TESTCONTRACT_CHECKSUM = "760f39a0"
    public let TESTCONTRACT_WITH_TOKENS_SCRIPT = "213701004021370000405700017840"
    public let TESTCONTRACT_WITH_TOKENS_CHECKSUM = "b559a069"
    public let TESTCONTRACT_METHOD_TOKENS = try! [
        NefFile.MethodToken(
            hash: Hash160("f61eebf573ea36593fd43aa150c055ad7906ab83"),
            method: "getGasPerBlock", parametersCount: 0,
            hasReturnValue: true, callFlags: CallFlags.all),
        NefFile.MethodToken(
            hash: Hash160("70e2301955bf1e74cbb31d18c2f96972abadb328"),
            method: "totalSupply", parametersCount: 0,
            hasReturnValue: true, callFlags: CallFlags.all)
    ]
    
    public func testNewNefFile() throws {
        let script = TESTCONTRACT_SCRIPT.bytesFromHex
        let nef = try NefFile(compiler: TESTCONTRACT_COMPILER, methodTokens: [], script: script)
        
        XCTAssertEqual(nef.compiler, TESTCONTRACT_COMPILER)
        XCTAssertEqual(nef.script, script)
        XCTAssertEqual(nef.checksum.noPrefixHex, TESTCONTRACT_CHECKSUM)
        XCTAssert(nef.methodTokens.isEmpty)
    }
    
    public func testNewNefFileWithMethodTokens() throws {
        let script = TESTCONTRACT_WITH_TOKENS_SCRIPT.bytesFromHex
        let nef = try NefFile(compiler: TESTCONTRACT_COMPILER, methodTokens: TESTCONTRACT_METHOD_TOKENS, script: script)
        
        XCTAssertEqual(nef.compiler, TESTCONTRACT_COMPILER)
        XCTAssertEqual(nef.script, script)
        XCTAssertEqual(nef.methodTokens, TESTCONTRACT_METHOD_TOKENS)
        XCTAssertEqual(nef.checksum.noPrefixHex, TESTCONTRACT_WITH_TOKENS_CHECKSUM)
    }
    
    public func testFailConstructorWithTooLongCompilerName() throws {
        XCTAssertThrowsError(try NefFile(compiler: "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
                                         methodTokens: [], script: TESTCONTRACT_SCRIPT.bytesFromHex)) { error in
            XCTAssert(error.localizedDescription.contains("The compiler name and version string can be max"))
        }
    }
    
    public func testReadFromFileShouldProduceCorrectNefFileWhenReadingValidFile() throws {
        let nef = try NefFile.readFromFile(TESTCONTRACT_FILE)
        XCTAssertEqual(nef.checksum.noPrefixHex, TESTCONTRACT_CHECKSUM)
        XCTAssertEqual(nef.script, TESTCONTRACT_SCRIPT.bytesFromHex)
    }
    
    public func testReadFromFileThatIsTooLarge() throws {
        XCTAssertThrowsError(try NefFile.readFromFile(TESTCONTRACT_FILE_TOO_LARGE)) { error in
            XCTAssert(error.localizedDescription.contains("The given NEF file is too large."))
        }
    }
    
    public func testDeserializeAndSerialize_ContractWithMethodTokens() throws {
        let bytes = try Data(contentsOf: TESTCONTRACT_WITH_TOKENS_FILE).bytes
        let nef = try NefFile.from(bytes)
        
        XCTAssertEqual(nef.compiler, TESTCONTRACT_COMPILER)
        XCTAssertEqual(nef.script, TESTCONTRACT_WITH_TOKENS_SCRIPT.bytesFromHex)
        XCTAssertEqual(nef.methodTokens, TESTCONTRACT_METHOD_TOKENS)
        XCTAssertEqual(nef.checksum.noPrefixHex, TESTCONTRACT_WITH_TOKENS_CHECKSUM)
        XCTAssertEqual(nef.toArray(), bytes)
    }
    
    public func testDeserializeAndSerialize_ContractWithoutMethodTokens() throws {
        let bytes = try Data(contentsOf: TESTCONTRACT_FILE).bytes
        let nef = try NefFile.from(bytes)
        
        XCTAssertEqual(nef.compiler, TESTCONTRACT_COMPILER)
        XCTAssertEqual(nef.script, TESTCONTRACT_SCRIPT.bytesFromHex)
        XCTAssert(nef.methodTokens.isEmpty)
        XCTAssertEqual(nef.checksum.noPrefixHex, TESTCONTRACT_CHECKSUM)
        XCTAssertEqual(nef.toArray(), bytes)
    }
    
    public func testDeserializeWithWrongMagicNumber() throws {
        let nef = "00000000"
        + TESTCONTRACT_COMPILER_HEX
        + RESERVED_BYTES + "00" // no tokens
        + RESERVED_BYTES
        + TESTCONTRACT_SCRIPT_SIZE
        + TESTCONTRACT_SCRIPT
        + TESTCONTRACT_CHECKSUM
        
        XCTAssertThrowsError(try NefFile.from(nef.bytesFromHex)) { error in
            XCTAssertEqual(error.localizedDescription, "Wrong magic number in NEF file.")
        }
    }
    
    public func testDeserializeWithWrongChecksum() throws {
        let nef = MAGIC
        + TESTCONTRACT_COMPILER_HEX
        + RESERVED_BYTES
        + "00" // no tokens
        + RESERVED_BYTES
        + TESTCONTRACT_SCRIPT_SIZE + TESTCONTRACT_SCRIPT
        + "00000000";
        
        XCTAssertThrowsError(try NefFile.from(nef.bytesFromHex)) { error in
            XCTAssertEqual(error.localizedDescription, "The checksums did not match.")
        }
    }
    
    public func testDeserializeWithEmptyScript() throws {
        let nef = MAGIC
        + TESTCONTRACT_COMPILER_HEX
        + RESERVED_BYTES
        + "00" //no tokens
        + RESERVED_BYTES
        + "00" // empty script
        + TESTCONTRACT_CHECKSUM;
        
        XCTAssertThrowsError(try NefFile.from(nef.bytesFromHex)) { error in
            XCTAssertEqual(error.localizedDescription, "Script cannot be empty in NEF file.")
        }
    }
    
    public func testGetSize() throws {
        let bytes = try Data(contentsOf: TESTCONTRACT_FILE).bytes
        let nef = try NefFile.from(bytes)
        
        XCTAssertEqual(nef.size, bytes.count)
    }
    
    public func testDeserializeNeoTokenNefFile() throws {
        let nefBytes = "4e4546336e656f2d636f72652d76332e3000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000700fd411af77b6771cbbae9".bytesFromHex
        let nef = try NefFile.from(nefBytes)
        
        XCTAssertEqual(nef.compiler, "neo-core-v3.0")
        XCTAssertEqual(nef.script, "00fd411af77b67".bytesFromHex)
        XCTAssertEqual(nef.methodTokens, [])
        XCTAssertEqual(nef.checksumInteger, 3921333105)
    }
    
    public func testDeserializeNefFileFromStackItem() throws {
        let nefBytes = "4e4546336e656f2d636f72652d76332e3000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000700fd411af77b6771cbbae9".bytesFromHex
        let stackItem = StackItem.byteString(nefBytes)
        let nef = try NefFile.readFromStackItem(stackItem)
        
        XCTAssertEqual(nef.compiler, "neo-core-v3.0")
        XCTAssertEqual(nef.script, "00fd411af77b67".bytesFromHex)
        XCTAssertEqual(nef.methodTokens, [])
        XCTAssertEqual(nef.checksumInteger, 3921333105)
    }
    
    public func testSerializeDeserializeNefFileWithSourceUrl() throws {
        let url = "github.com/crisogray/NeoSwift"
        let nef = try NefFile(compiler: "neo-core-v3.0", sourceUrl: url, methodTokens: [], script: "00fd411af77b67".bytesFromHex)
        
        let bytes = nef.toArray()
        let hexString = bytes.toHexString()

        XCTAssert(hexString.contains("1d6769746875622e636f6d2f637269736f677261792f4e656f5377696674"))
        
        let deserializedNef = try NefFile.from(bytes)
        XCTAssertEqual(deserializedNef.sourceUrl, url)
    }
    
    public func testFailDeserializationWithTooLongSourceUrl() throws {
        let nefHex =
        // beginning of nef
        "4e4546336e656f2d636f72652d76332e30000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000" +
        // size of the source url (256 bytes)
        "fd0001" +
        // the source url
        "1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111" +
        "186769746875622e636f6d2f6e656f77336a2f6e656f77336a000000000700fd411af77b679cc8d824"
        
        XCTAssertThrowsError(try NefFile.from(nefHex.bytesFromHex)) { error in
            XCTAssert(error.localizedDescription.contains("Source URL must not be longer than"))
        }
    }
    
    public func testFailConstructingWithTooLongSourceUrl() throws {
        let url = "github.com/neow3j/neow3j/neow3j/neow3j/neow3j/neow3j/neow3j/neow3j/neow3j/neow3j" +
        "/neow3j/neow3j/neow3j/neow3j/neow3j/neow3j/neow3j/neow3j/neow3j/neow3j" +
        "/neow3j/neow3j/neow3j/neow3j/neow3j/neow3j/neow3j/neow3j/neow3j/neow3j" +
        "/neow3j/neow3j/neow3j/neow3j/neow3j/"
        
        XCTAssertThrowsError(try NefFile(compiler: "neo-core-v3.0", sourceUrl: url, methodTokens: [], script: "00fd411af77b67".bytesFromHex)) { error in
            XCTAssert(error.localizedDescription.contains("The source URL must not be longer than"))
        }
    }
    
}
