
import XCTest
@testable import NeoSwift

class FungibleTokenTests: XCTestCase {
    
    var mockUrlSession: MockURLSession!
    
    private let RECIPIENT_SCRIPT_HASH = try! Hash160("969a77db482f74ce27105f760efa139223431394")
    private let NEP17_TRANSFER = "transfer"
    
    private let neoHash = try! Hash160(neoTokenHash)
    private let gasHash = try! Hash160(gasTokenHash)

    private var neoToken: FungibleToken!
    private var gasToken: FungibleToken!
    
    private var account1 = try! Account(keyPair: .create(privateKey: "1dd37fba80fec4e6a6f13fd708d8dcb3b29def768017052f6c930fa1c5d90bbb".bytesFromHex))
    private var account2 = try! Account(keyPair: .create(privateKey: "b4b2b579cac270125259f08a5f414e9235817e7637b9a66cfeb3b77d90c8e7f9".bytesFromHex))
    
    override func setUp() {
        super.setUp()
        mockUrlSession = MockURLSession()
        let neoSwift = NeoSwift.build(HttpService(urlSession: mockUrlSession))
        neoToken = .init(scriptHash: neoHash, neoSwift: neoSwift)
        gasToken = .init(scriptHash: gasHash, neoSwift: neoSwift)
    }
    
    public func testTransferFromAccount() async {
        let invokeJson = JSON.from("invokescript_transfer")
        let networkFeeJson = JSON.from("calculatenetworkfee")
        let blockCountJson = JSON.from("getblockcount_1000")
        let decimalsJson = JSON.from("invokefunction_decimals_gas")
        let balanceOfJson = JSON.from("invokefunction_balanceOf_300000000")
        _ = mockUrlSession
            .data(["invokescript": invokeJson, "calculatenetworkfee": networkFeeJson, "getblockcount": blockCountJson])
            .invokeFunctions(["decimals": decimalsJson, "balanceOf": balanceOfJson])
        
        let expectedScript = try! await ScriptBuilder()
            .contractCall(.init(gasTokenHash),
                          method: NEP17_TRANSFER,
                          params: [
                            .hash160(account1.scriptHash!),
                            .hash160(RECIPIENT_SCRIPT_HASH),
                            .integer(gasToken.toFractions(1)),
                            .any(nil)
                          ])
            .toArray()
        
        let tx = try! await gasToken.transfer(account1, RECIPIENT_SCRIPT_HASH, 100_000_000).getUnsignedTransaction()
        XCTAssertEqual(tx.script, expectedScript)
        XCTAssert(tx.signers[0] is AccountSigner)
        XCTAssert((tx.signers[0] as! AccountSigner).account === account1)
        
        let builder = try! gasToken.transfer(account1.getScriptHash(), RECIPIENT_SCRIPT_HASH, 100_000_000)
        XCTAssertEqual(builder.script, expectedScript)
        XCTAssert(builder.signers.isEmpty)
    }
    
    public func testGetBalanceOfAccount_address() async {
        let balanceOfJson = JSON.from("invokefunction_balanceOf_300000000")
        _ = mockUrlSession.data(["invokefunction": balanceOfJson])
        let balance = try! await gasToken.getBalanceOf(account1.getScriptHash())
        XCTAssertEqual(balance, 300_000_000)
    }
    
    public func testGetBalanceOfAccount_account() async {
        let balanceOfJson = JSON.from("invokefunction_balanceOf_300000000")
        _ = mockUrlSession.data(["invokefunction": balanceOfJson])
        let balance = try! await gasToken.getBalanceOf(account1)
        XCTAssertEqual(balance, 300_000_000)
    }
    
    public func testGetBalanceOfWallet() async {
        let balanceOfJson = JSON.from("invokefunction_balanceOf_300000000")
        _ = mockUrlSession.data(["invokefunction": balanceOfJson])
        let balance = try! await gasToken.getBalanceOf(.withAccounts([account1, account2]))
        XCTAssertEqual(balance, 600_000_000)
    }
    
    public func testTransfer_illegalAmountProvided() async {
        XCTAssertThrowsError(try neoToken.transfer(account1, RECIPIENT_SCRIPT_HASH, -2)) { error in
            XCTAssertEqual(error.localizedDescription, "The amount must be greater than or equal to 0.")
        }
    }
    
    // MARK: Transfer with NNS Recipient
    
    public func testTransferToNNSName() async {
        let invokeJson = JSON.from("invokescript_transfer")
        let networkFeeJson = JSON.from("calculatenetworkfee")
        let blockCountJson = JSON.from("getblockcount_1000")
        let decimalsJson = JSON.from("invokefunction_decimals_gas")
        let balanceOfJson = JSON.from("invokefunction_balanceOf_300000000")
        let resolveJson = JSON.from("nns_resolve_typeTXT")
        _ = mockUrlSession
            .data(["invokescript": invokeJson, "calculatenetworkfee": networkFeeJson, "getblockcount": blockCountJson])
            .invokeFunctions(["decimals": decimalsJson, "balanceOf": balanceOfJson, "resolve": resolveJson])

        let amount = 300_000_000
        let nnsName = try! NNSName("neow3j.neo")
        let recipient = try! Hash160.fromAddress("NTXJgQrqxnSFFqKe3oBejnnzjms61Yzb8r")
        
        let expectedScript = try! ScriptBuilder()
            .contractCall(.init(gasTokenHash),
                          method: NEP17_TRANSFER,
                          params: [
                            .hash160(account1.scriptHash!),
                            .hash160(recipient),
                            .integer(amount),
                            .any(nil)
                          ])
            .toArray()
        
        let tx = try! await gasToken.transfer(account1, nnsName, amount).getUnsignedTransaction()
        XCTAssertEqual(tx.script, expectedScript)
        XCTAssert((tx.signers[0] as! AccountSigner).account === account1)
        
        let builder = try! await gasToken.transfer(account1.getScriptHash(), nnsName, 300_000_000)
        XCTAssertEqual(builder.script, expectedScript)
        XCTAssert(builder.signers.isEmpty)
    }

}
