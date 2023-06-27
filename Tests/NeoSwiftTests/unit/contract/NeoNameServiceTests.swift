

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
    
    private var account1 = try! Account.fromWIF(defaultAccountWIF)
    private var account2 = try! Account.fromWIF(client1AccountWIF)
    
    private var nameService: NeoNameService!
    private var nameServiceHash: Hash160!
    
    private var mockUrlSession: MockURLSession!
    
    override func setUp() {
        mockUrlSession = MockURLSession()
        let neoSwift = NeoSwift.build(HttpService(urlSession: mockUrlSession))
        nameService = .init(neoSwift: neoSwift)
        nameServiceHash = nameService.scriptHash
    }
    
    // MARK: NEP-11 Methodd
    
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


    public func testTokens() async {
        _ = mockUrlSession.invokeFunctions([TOKENS: JSON.from("invokefunction_iterator_session")])
        let tokensIterator = try! await nameService.tokens()
        XCTAssertEqual(tokensIterator.iteratorId, "190d19ca-e935-4ad0-95c9-93b8cf6d115c")
        XCTAssertEqual(tokensIterator.sessionId, "a7b35b13-bdfc-4ab3-a398-88a9db9da4fe")
    }

    public func testGetProperties() async {
        _ = mockUrlSession.invokeFunctions([IS_AVAILABLE: JSON.from("invokefunction_returnFalse"),
                                              PROPERTIES: JSON.from("nns_invokefunction_properties")])
        let nameState = try! await nameService.getNameState(NNSName("client1.neo"))
        XCTAssertEqual(nameState.name, "client1.neo")
        XCTAssertEqual(nameState.expiration, 1646214292)
        XCTAssertEqual(nameState.admin, try! Hash160("69ecca587293047be4c59159bf8bc399985c160d"))
    }
    
    public func testProperties_noAdmin() async {
        _ = mockUrlSession.invokeFunctions([IS_AVAILABLE: JSON.from("invokefunction_returnFalse"),
                                              PROPERTIES: JSON.from("nns_invokefunction_properties_noAdmin")])

        let nameState = try! await nameService.getNameState(NNSName("client2.neo"))

        XCTAssertEqual(nameState.name, "client2.neo")
        XCTAssertEqual(nameState.expiration, 1677933305472)
        XCTAssertNil(nameState.admin)
    }

    public func testProperties_unexpectedReturnType() async {
        _ = mockUrlSession.invokeFunctions([IS_AVAILABLE: JSON.from("invokefunction_returnFalse"),
                                              PROPERTIES: JSON.from("invokefunction_returnInt")])

        do {
            _ = try await nameService.getNameState(NNSName("client1.neo"))
            XCTFail("Expected UnexpectedReturnTypeException to be thrown.")
        } catch {
            guard case ContractError.unexpectedReturnType = error else {
                return XCTFail("Unexpected exception thrown: \(error)")
            }
            XCTAssertEqual(error.localizedDescription, "Got stack item of type Integer but expected Map.")
        }
    }
    
    // MARK: Custom NNS Methods
    
    public func testAddRoot() {
        let expectedScript = try! ScriptBuilder()
            .contractCall(nameServiceHash, method: ADD_ROOT, params: [.string("neow")])
            .toArray()

        let b = try! nameService.addRoot(NNSName.NNSRoot("neow"))
            .signers(AccountSigner.calledByEntry(account1))

        XCTAssertEqual(b.signers[0].signerHash, account1.scriptHash)
        XCTAssert(b.signers[0].scopes.contains(.calledByEntry))
        XCTAssertEqual(b.script, expectedScript)
    }
    
    public func testGetRoots() async {
        _ = mockUrlSession.invokeFunctions([ROOTS: JSON.from("invokefunction_iterator_session")])

        let rootsIterator = try! await nameService.getRoots()
        XCTAssertEqual(rootsIterator.iteratorId, "190d19ca-e935-4ad0-95c9-93b8cf6d115c")
        XCTAssertEqual(rootsIterator.sessionId, "a7b35b13-bdfc-4ab3-a398-88a9db9da4fe")
    }

    public func testUnwrapRoots() async {
        _ = mockUrlSession.data(["invokescript": JSON.from("nns_unwrapRoots")])

        let roots = try! await nameService.getRootsUnwrapped()
        XCTAssertEqual(roots[0], "eth")
        XCTAssertEqual(roots[1], "neo")
    }
    
    public func testSetPrice() {
        let expectedScript = try! ScriptBuilder()
            .contractCall(nameServiceHash, method: SET_PRICE,
                          params: [.array([ContractParameter.integer(200_000_000),
                                           ContractParameter.integer(100_000_000),
                                           ContractParameter.integer(150_000_000)])])
            .toArray()

        let b = try! nameService.setPrice([200_000_000, 100_000_000, 150_000_000])
            .signers(AccountSigner.calledByEntry(account1))

        XCTAssertEqual(b.signers[0].signerHash, account1.scriptHash)
        XCTAssert(b.signers[0].scopes.contains(WitnessScope.calledByEntry))
        XCTAssertEqual(b.script, expectedScript)
    }
    
    
    
}

