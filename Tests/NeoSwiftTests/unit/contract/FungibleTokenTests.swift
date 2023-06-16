
import XCTest
@testable import NeoSwift

class FungibleTokenTests: XCTestCase {
    
    var mockUrlSession: MockURLSession!
    
    private let RECIPIENT_SCRIPT_HASH = try! Hash160("969a77db482f74ce27105f760efa139223431394")
    private let NEP17_TRANSFER = "transfer"
    
    private var neoToken: FungibleToken!
    private var gasToken: FungibleToken!
    
    private var account1: Account!
    private var account2: Account!
    
    override func setUp() {
        super.setUp()
        mockUrlSession = MockURLSession()
        
        let neoSwift = NeoSwift.build(HttpService(urlSession: mockUrlSession))
        neoToken = try! .init(scriptHash: .init(string: neoTokenHash), neoSwift: neoSwift)
        gasToken = try! .init(scriptHash: .init(string: gasTokenHash), neoSwift: neoSwift)
        account1 = try! .init(keyPair: .create(privateKey: "1dd37fba80fec4e6a6f13fd708d8dcb3b29def768017052f6c930fa1c5d90bbb".bytesFromHex))
        account2 = try! .init(keyPair: .create(privateKey: "b4b2b579cac270125259f08a5f414e9235817e7637b9a66cfeb3b77d90c8e7f9".bytesFromHex))
    }
    
    public func testTransferFromAccount() async {
        let invokeJson = invokeScriptTransferJson
        let networkFeeJson = calculateNetworkFeeJson
        let blockCountJson = getBlockCount_1000Json
        let decimalsJson = invokeFunctionDecimalsGasJson
        let balanceOfJson = invokeFunctionBalanceOf300000000Json
        _ = mockUrlSession.data(["invokescript": [invokeJson], "calculatenetworkfee": [networkFeeJson],
                                 "getblockcount": [blockCountJson], "invokefunction": [decimalsJson, balanceOfJson]])
        
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
        
        let tx = try! await gasToken.transfer(account1, RECIPIENT_SCRIPT_HASH, 100000000).getUnsignedTransaction()
        XCTAssertEqual(tx.script, expectedScript)
        XCTAssert(tx.signers[0] is AccountSigner)
        XCTAssert((tx.signers[0] as! AccountSigner).account === account1)
        
        let builder = try! gasToken.transfer(account1.getScriptHash(), RECIPIENT_SCRIPT_HASH, 100000000)
        XCTAssertEqual(builder.script, expectedScript)
        XCTAssert(builder.signers.isEmpty)
    }
    
    public func testGetBalanceOfAccount_address() async {
        let balanceOfJson = invokeFunctionBalanceOf300000000Json
        _ = mockUrlSession.data(["invokefunction": balanceOfJson])
        let balance = try! await gasToken.getBalanceOf(account1.getScriptHash())
        XCTAssertEqual(balance, 300000000)
    }
    
    public func testGetBalanceOfAccount_account() async {
        let balanceOfJson = invokeFunctionBalanceOf300000000Json
        _ = mockUrlSession.data(["invokefunction": balanceOfJson])
        let balance = try! await gasToken.getBalanceOf(account1)
        XCTAssertEqual(balance, 300000000)
    }

}
