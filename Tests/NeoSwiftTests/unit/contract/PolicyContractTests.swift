
import XCTest
@testable import NeoSwift

class PolicyContractTests: XCTestCase {
    
    private let POLICYCONTRACT_HASH = try! Hash160("cc5e4edd9f5f8dba8bb65734541df7a1c081c67b")
    
    private let account1 = try! Account.fromWIF("L1WMhxazScMhUrdv34JqQb1HFSQmWeN2Kpc1R9JGKwL7CDNP21uR")
    private let recipient = try! Hash160("969a77db482f74ce27105f760efa139223431394")
    
    private var mockUrlSession: MockURLSession!
    private var policyContract: PolicyContract!

    override func setUp() {
        mockUrlSession = MockURLSession()
        let neoSwift = NeoSwift.build(HttpService(urlSession: mockUrlSession), .init(networkMagic: 769))
        policyContract = PolicyContract(neoSwift)
    }
    
    public func testGetFeePerByte() async throws {
        _ = mockUrlSession.invokeFunctions(["getFeePerByte": JSON.from("policy_getFeePerByte")])
        let fee = try await policyContract.getFeePerByte()
        XCTAssertEqual(fee, 1000)
    }
    
    public func testGetExecFeeFactor() async throws {
        _ = mockUrlSession.invokeFunctions(["getExecFeeFactor": JSON.from("policy_getExecFeeFactor")])
        let execFeeFactor = try await policyContract.getExecFeeFactor()
        XCTAssertEqual(execFeeFactor, 30)
    }
    
    public func testGetStoragePrice() async throws {
        _ = mockUrlSession.invokeFunctions(["getStoragePrice": JSON.from("policy_getStoragePrice")])
        let storagePrice = try await policyContract.getStoragePrice()
        XCTAssertEqual(storagePrice, 100_000)
    }
    
    public func testIsBlocked() async throws {
        _ = mockUrlSession.invokeFunctions(["isBlocked": JSON.from("policy_isBlocked")])
        let isBlocked = try await policyContract.isBlocked(account1.getScriptHash())
        XCTAssertFalse(isBlocked)
    }
    
    public func testSetFeePerByte_ProducesCorrectTransaction() async throws {
        _ = mockUrlSession.data(["invokescript": JSON.from("policy_setFeePerByte"),
                                 "getblockcount": JSON.from("getblockcount_1000"),
                                 "calculatenetworkfee": JSON.from("calculatenetworkfee")])
        
        let expectedScript = try ScriptBuilder()
            .contractCall(PolicyContract.SCRIPT_HASH, method: "setFeePerByte", params: [.integer(20)])
            .toArray()
        
        let tx = try await policyContract
            .setFeePerByte(20)
            .signers(AccountSigner.calledByEntry(account1))
            .sign()
        
        XCTAssertEqual(tx.signers.count, 1)
        XCTAssertEqual(tx.signers.first, .init(account1.scriptHash!, .calledByEntry))
        XCTAssertEqual(tx.script, expectedScript)
        XCTAssertEqual(tx.witnesses.first?.verificationScript.script, account1.verificationScript!.script)
    }
    
    public func testSetExecFeeFactor() async throws {
        _ = mockUrlSession.data(["invokescript": JSON.from("policy_setExecFeeFactor"),
                                 "getblockcount": JSON.from("getblockcount_1000"),
                                 "calculatenetworkfee": JSON.from("calculatenetworkfee")])
        
        let expectedScript = try ScriptBuilder()
            .contractCall(PolicyContract.SCRIPT_HASH, method: "setExecFeeFactor", params: [.integer(10)])
            .toArray()
        
        let tx = try await policyContract
            .setExecFeeFactor(10)
            .signers(AccountSigner.calledByEntry(account1))
            .sign()
        
        XCTAssertEqual(tx.signers.count, 1)
        XCTAssertEqual(tx.signers.first, .init(account1.scriptHash!, .calledByEntry))
        XCTAssertEqual(tx.script, expectedScript)
        XCTAssertEqual(tx.witnesses.first?.verificationScript.script, account1.verificationScript!.script)
    }
    
    public func testSetStoragePrice() async throws {
        _ = mockUrlSession.data(["invokescript": JSON.from("policy_setStoragePrice"),
                                 "getblockcount": JSON.from("getblockcount_1000"),
                                 "calculatenetworkfee": JSON.from("calculatenetworkfee")])
        
        let expectedScript = try ScriptBuilder()
            .contractCall(PolicyContract.SCRIPT_HASH, method: "setStoragePrice", params: [.integer(8)])
            .toArray()
        
        let tx = try await policyContract
            .setStoragePrice(8)
            .signers(AccountSigner.calledByEntry(account1))
            .sign()
        
        XCTAssertEqual(tx.signers.count, 1)
        XCTAssertEqual(tx.signers.first, .init(account1.scriptHash!, .calledByEntry))
        XCTAssertEqual(tx.script, expectedScript)
        XCTAssertEqual(tx.witnesses.first?.verificationScript.script, account1.verificationScript!.script)
    }
    
    public func testBlockAccount() async throws {
        _ = mockUrlSession.data(["invokescript": JSON.from("policy_blockAccount"),
                                 "getblockcount": JSON.from("getblockcount_1000"),
                                 "calculatenetworkfee": JSON.from("calculatenetworkfee")])
        
        let expectedScript = try ScriptBuilder()
            .contractCall(PolicyContract.SCRIPT_HASH, method: "blockAccount", params: [.hash160(recipient)])
            .toArray()
        
        let tx = try await policyContract
            .blockAccount(recipient)
            .signers(AccountSigner.calledByEntry(account1))
            .sign()
        
        XCTAssertEqual(tx.signers.count, 1)
        XCTAssertEqual(tx.signers.first, .init(account1.scriptHash!, .calledByEntry))
        XCTAssertEqual(tx.script, expectedScript)
        XCTAssertEqual(tx.witnesses.first?.verificationScript.script, account1.verificationScript!.script)
    }
    
    public func testBlockAccount_address() async throws {
        _ = mockUrlSession.data(["invokescript": JSON.from("policy_blockAccount"),
                                 "getblockcount": JSON.from("getblockcount_1000"),
                                 "calculatenetworkfee": JSON.from("calculatenetworkfee")])
        
        let expectedScript = try ScriptBuilder()
            .contractCall(PolicyContract.SCRIPT_HASH, method: "blockAccount", params: [.hash160(recipient)])
            .toArray()
        
        let tx = try await policyContract
            .blockAccount(recipient.toAddress())
            .signers(AccountSigner.calledByEntry(account1))
            .sign()
        
        XCTAssertEqual(tx.signers.count, 1)
        XCTAssertEqual(tx.signers.first, .init(account1.scriptHash!, .calledByEntry))
        XCTAssertEqual(tx.script, expectedScript)
        XCTAssertEqual(tx.witnesses.first?.verificationScript.script, account1.verificationScript!.script)
    }
    
    public func testUnblockAccount() async throws {
        _ = mockUrlSession.data(["invokescript": JSON.from("policy_unblockAccount"),
                                 "getblockcount": JSON.from("getblockcount_1000"),
                                 "calculatenetworkfee": JSON.from("calculatenetworkfee")])
        
        let expectedScript = try ScriptBuilder()
            .contractCall(PolicyContract.SCRIPT_HASH, method: "unblockAccount", params: [.hash160(recipient)])
            .toArray()
        
        let tx = try await policyContract
            .unblockAccount(recipient)
            .signers(AccountSigner.calledByEntry(account1))
            .sign()
        
        XCTAssertEqual(tx.signers.count, 1)
        XCTAssertEqual(tx.signers.first, .init(account1.scriptHash!, .calledByEntry))
        XCTAssertEqual(tx.script, expectedScript)
        XCTAssertEqual(tx.witnesses.first?.verificationScript.script, account1.verificationScript!.script)
    }
    
    public func testUnblockAccount_address() async throws {
        _ = mockUrlSession.data(["invokescript": JSON.from("policy_unblockAccount"),
                                 "getblockcount": JSON.from("getblockcount_1000"),
                                 "calculatenetworkfee": JSON.from("calculatenetworkfee")])
        
        let expectedScript = try ScriptBuilder()
            .contractCall(PolicyContract.SCRIPT_HASH, method: "unblockAccount", params: [.hash160(recipient)])
            .toArray()
        
        let tx = try await policyContract
            .unblockAccount(recipient.toAddress())
            .signers(AccountSigner.calledByEntry(account1))
            .sign()
        
        XCTAssertEqual(tx.signers.count, 1)
        XCTAssertEqual(tx.signers.first, .init(account1.scriptHash!, .calledByEntry))
        XCTAssertEqual(tx.script, expectedScript)
        XCTAssertEqual(tx.witnesses.first?.verificationScript.script, account1.verificationScript!.script)
    }
    
    public func testScriptHash() {
        XCTAssertEqual(policyContract.scriptHash, POLICYCONTRACT_HASH)
    }
    
}
