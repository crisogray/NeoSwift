
import XCTest
@testable import NeoSwift

class ContractManagementTests: XCTestCase {
    
    private let CONTRACTMANAGEMENT_SCRIPTHASH = try! Hash160("fffdc93764dbaddd97c48f252a53ea4643faa3fd")
    private let TESTCONTRACT_NEF_FILE = Bundle.module.url(forResource: "TestContract", withExtension: "nef")!
    private let TESTCONTRACT_MANIFEST_FILE = Bundle.module.url(forResource: "TestContract.manifest", withExtension: "json")!
    
    private var mockUrlSession: MockURLSession!
    private var neoSwift: NeoSwift!
    
    private let account1 = try! Account.fromWIF("L1WMhxazScMhUrdv34JqQb1HFSQmWeN2Kpc1R9JGKwL7CDNP21uR")
    
    override func setUp() {
        mockUrlSession = .init()
        neoSwift = .build(HttpService(urlSession: mockUrlSession), .init(networkMagic: 769))
    }
    
    public func testGetContractById() async throws {
        _ = mockUrlSession.data(["getcontractstate": JSON.from("contractstate")])
        _ = mockUrlSession.invokeFunctions(["getContractById": JSON.from("management_getContract")])
        
        let contractHash = try Hash160("0xf61eebf573ea36593fd43aa150c055ad7906ab83")
        
        let state = try await ContractManagement(neoSwift).getContractById(12)
        XCTAssertEqual(state.hash, contractHash)
        XCTAssertEqual(state.id, 12)
        XCTAssertEqual(state.manifest.name, "neow3j")
    }
    
    public func testGetContractById_nonExistent() async throws {
        _ = mockUrlSession.data(["invokefunction": JSON.from("management_contractstate_notexistent")])
        do {
            _ = try await ContractManagement(neoSwift).getContractById(20)
            XCTFail("No exception")
        } catch {
            XCTAssert(error is NeoSwiftError)
            XCTAssertEqual(error.localizedDescription, "Could not get the contract hash for the provided id.")
        }
    }
    
    public func testDeployWithoutData() async throws {
        _ = mockUrlSession.data(["invokescript": JSON.from("management_deploy"),
                                 "getblockcount": JSON.from("getblockcount_1000"),
                                 "calculatenetworkfee": JSON.from("calculatenetworkfee")])
        
        let nef = try NefFile.readFromFile(TESTCONTRACT_NEF_FILE)
        
        let manifest = try JSONDecoder().decode(ContractManifest.self, from: Data(contentsOf: TESTCONTRACT_MANIFEST_FILE))
        let manifestData = try JSONEncoder().encode(manifest)
        
        let expectedScript = try ScriptBuilder().contractCall(
            ContractManagement.SCRIPT_HASH, method: "deploy",
            params: [.byteArray(nef.toArray()), .byteArray(manifestData.bytes)]
        ).toArray()
        
        let tx = try await ContractManagement(neoSwift)
            .deploy(nef, manifest)
            .signers(AccountSigner.calledByEntry(account1))
            .sign()
        
        XCTAssertEqual(tx.script, expectedScript)
    }
    
    public func testDeployWithData() async throws {
        _ = mockUrlSession.data(["invokescript": JSON.from("management_deploy"),
                                 "getblockcount": JSON.from("getblockcount_1000"),
                                 "calculatenetworkfee": JSON.from("calculatenetworkfee")])
        
        let nef = try NefFile.readFromFile(TESTCONTRACT_NEF_FILE)
        
        let manifest = try JSONDecoder().decode(ContractManifest.self, from: Data(contentsOf: TESTCONTRACT_MANIFEST_FILE))
        let manifestData = try JSONEncoder().encode(manifest)
        
        let data = ContractParameter.string("some data")
        
        let expectedScript = try ScriptBuilder().contractCall(
            ContractManagement.SCRIPT_HASH, method: "deploy",
            params: [.byteArray(nef.toArray()), .byteArray(manifestData.bytes), data]
        ).toArray()
        
        let tx = try await ContractManagement(neoSwift)
            .deploy(nef, manifest, data)
            .signers(AccountSigner.calledByEntry(account1))
            .sign()
        
        XCTAssertEqual(tx.script, expectedScript)
    }
    
}
