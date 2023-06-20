

import XCTest
@testable import NeoSwift

class NeoNameServiceTests: XCTestCase {
    
    private let TOTAL_SUPPLY = "totalSupply"
    private let SYMBOL = "symbol"
    private let DECIMALS = "decimals"

    private let OWNER_OF = "ownerOf"
    private let BALANCE_OF = "balanceOf"
    private let TRANSFER = "transfer"
    private let TOKENS = "tokens"
    private let PROPERTIES = "properties"

    private let ADD_ROOT = "addRoot"
    private let ROOTS = "roots"
    private let SET_PRICE = "setPrice"
    private let GET_PRICE = "getPrice"
    private let IS_AVAILABLE = "isAvailable"
    private let REGISTER = "register"
    private let RENEW = "renew"
    private let SET_ADMIN = "setAdmin"
    private let SET_RECORD = "setRecord"
    private let GET_RECORD = "getRecord"
    private let GET_ALL_RECORDS = "getAllRecords"
    private let DELETE_RECORD = "deleteRecord"
    private let RESOLVE = "resolve"
    
    private var account1: Account!
    private var account2: Account!
    
    private var nameService: NeoNameService!
    private var nameServiceHash: Hash160!
    
    private var mockUrlSession: MockURLSession!
    
    override func setUp() {
        account1 = try! .fromWIF(defaultAccountWIF)
        account2 = try! .fromWIF(client1AccountWIF)
        
        mockUrlSession = MockURLSession()
        let neoSwift = NeoSwift.build(HttpService(urlSession: mockUrlSession))
        nameService = .init(neoSwift: neoSwift)
        nameServiceHash = nameService.scriptHash
    }
    
    public func testGetName() async {
        let name = try! await nameService.getName()
        XCTAssertEqual(name, "NameService")
    }
    
    public func testGetSymbol() async {
        let symbol = try! await nameService.getSymbol()
        XCTAssertEqual(symbol, "NNS")
    }
    
    public func testGetDecimals() async {
        let decimals = try! await nameService.getDecimals()
        XCTAssertEqual(decimals, 0)
    }
    
    public func testGetTotalSupply() async {
        _ = mockUrlSession.invokeFunctions([TOTAL_SUPPLY: JSON.from("nns_invokefunction_totalSupply")])
        let totalSupply = try! await nameService.getTotalSupply()
        XCTAssertEqual(totalSupply, 25001)
    }
    
    public func testBalanceOf() async {
        _ = mockUrlSession.invokeFunctions([BALANCE_OF: JSON.from("nft_balanceof")])
        let balanceOf = try! await nameService.balanceOf(account1.scriptHash!)
        XCTAssertEqual(balanceOf, 244)
    }
    
    public func testOwnerOf() async {
        _ = mockUrlSession.invokeFunctions([OWNER_OF: JSON.from("nns_ownerof"),
                                            DECIMALS: JSON.from("nns_invokefunction_decimals"),
                                            IS_AVAILABLE: JSON.from("invokefunction_returnFalse")])
        let ownerOf = try! await nameService.ownerOf(.init("client1.neo"))
        XCTAssertEqual(ownerOf, try! .init(defaultAccountScriptHash))
    }
    
    public func testProperties() async {
        _ = mockUrlSession.invokeFunctions([PROPERTIES: JSON.from("nns_properties")])
        let properties = try! await nameService.properties(.init("neow3j.neo"))
        XCTAssertEqual(properties["image"], "https://neo3.azureedge.net/images/neons.png")
        XCTAssertEqual(properties["expiration"], "1698166908502")
        XCTAssertEqual(properties["name"], "neow3j.neo")
        XCTAssertNil(properties["admin"])
    }
    
    public func testTransfer() async {
        _ = mockUrlSession.data(["invokescript": JSON.from("nns_returnAny"),
                                 "getblockcount": JSON.from("getblockcount_1000")])
        .invokeFunctions([OWNER_OF: JSON.from("nns_invokefunction_ownerof"),
                          DECIMALS: JSON.from("nns_invokefunction_decimals"),
                      IS_AVAILABLE: JSON.from("invokefunction_returnFalse")])
        
        let expectedScript = try! ScriptBuilder()
            .contractCall(nameServiceHash, method: TRANSFER,
                          params: [.hash160(account2.getScriptHash()),
                                   .byteArray("636c69656e74312e6e656f"),
                                   nil])
            .toArray()
        
        let b = try! await nameService.transfer(account1, account2.getScriptHash(), NNSName("client1.neo"))
        XCTAssertEqual(b.script, expectedScript)
    }
    

}

