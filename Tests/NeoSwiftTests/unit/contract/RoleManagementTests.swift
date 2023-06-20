
import XCTest
@testable import NeoSwift

class RoleManagementTests: XCTestCase {
    
    private let ROLEMANAGEMENT_HASH = try! Hash160("49cf4e5378ffcd4dec034fd98a174c5491e395e2")
    
    private var roleManagement: RoleManagement!
    private var account1: Account!
    
    var mockUrlSession: MockURLSession!
    
    override func setUp() {
        super.setUp()
        mockUrlSession = MockURLSession()
        roleManagement = .init(.build(HttpService(urlSession: mockUrlSession)))
        account1 = try! .init(keyPair: .create(privateKey: "0f7d2f77f3229178650b958eb286258f0e6533d0b86ec389b862c440c6511a4b".bytesFromHex))
    }
    
    public func testValidateIntegerValueOfRoleByteValue() {
        XCTAssertEqual(Role.stateValidator.byte, 4)
        XCTAssertEqual(Role.oracle.byte, 8)
        XCTAssertEqual(Role.neoFSAlphabetNode.byte, 16)
    }
    
    public func testGetDesignatedByRole() async {
        let blockCountJson = JSON.from("getblockcount_1000")
        let designationJson = JSON.from("designation_getByRole")
        _ = mockUrlSession.data(["invokefunction": designationJson, "getblockcount": blockCountJson])
        let list = try! await roleManagement.getDesignatedByRole(.stateValidator, blockIndex: 10)
        XCTAssert(list.contains(account1.keyPair!.publicKey))
    }
    
    public func testGetDesignatedByRole_emptyResponse() async {
        let blockCountJson = JSON.from("getblockcount_1000")
        let designationJson = JSON.from("designation_getByRole_empty")
        _ = mockUrlSession.data(["invokefunction": designationJson, "getblockcount": blockCountJson])
        let list = try! await roleManagement.getDesignatedByRole(.oracle, blockIndex: 12)
        XCTAssert(list.isEmpty)
    }
    
    public func testGetDesignatedByRole_negativeIndex() async {
        do {
            _ = try await roleManagement.getDesignatedByRole(.oracle, blockIndex: -1)
            XCTFail("No exception")
        } catch {
            XCTAssertEqual(error.localizedDescription, "The block index has to be positive.")
        }
    }
    
    public func testGetDesignatedByRole_indexTooHigh() async {
        let blockCountJson = JSON.from("getblockcount_1000")
        _ = mockUrlSession.data(["getblockcount": blockCountJson])
        do {
            _ = try await roleManagement.getDesignatedByRole(.oracle, blockIndex: 1001)
            XCTFail("No exception")
        } catch {
            XCTAssert(error.localizedDescription.contains("The provided block index (1001) is too high."))
        }
    }
    
    public func testDesignateAsRole() {
        let designationJson = JSON.from("designation_designateAsRole")
        _ = mockUrlSession.data(["invokefunction": designationJson])
        let keyParam = try! ContractParameter.publicKey(account1.keyPair!.publicKey.getEncoded(compressed: true))
        let expectedScript = try! ScriptBuilder()
            .contractCall(RoleManagement.SCRIPT_HASH,
                          method: "designateAsRole",
                          params: [.integer(Role.oracle.byte), .array([keyParam])])
            .toArray()
        let builder = try! roleManagement.designateAsRole(.oracle, [account1.keyPair!.publicKey])
        XCTAssertEqual(builder.script, expectedScript)
    }
    
    public func testDesignate_pubKeysEmpty() {
        XCTAssertThrowsError(try roleManagement.designateAsRole(.oracle, [])) { error in
            XCTAssertEqual(error.localizedDescription, "At least one public key is required for designation.")
        }
    }
    
    public func testScriptHash() {
        XCTAssertEqual(roleManagement.scriptHash, ROLEMANAGEMENT_HASH)
    }
    
}
