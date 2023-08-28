
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
    
    public func testGetName() async throws {
        let name = try await nameService.getName()
        XCTAssertEqual(name, "NameService")
    }
    
    public func testGetSymbol() async throws {
        let symbol = try await nameService.getSymbol()
        XCTAssertEqual(symbol, "NNS")
    }
    
    public func testGetDecimals() async throws {
        let decimals = try await nameService.getDecimals()
        XCTAssertEqual(decimals, 0)
    }
    
    public func testGetTotalSupply() async throws {
        _ = mockUrlSession.invokeFunctions([TOTAL_SUPPLY: JSON.from("nns_invokefunction_totalSupply")])
        let totalSupply = try await nameService.getTotalSupply()
        XCTAssertEqual(totalSupply, 25001)
    }
    
    public func testBalanceOf() async throws {
        _ = mockUrlSession.invokeFunctions([BALANCE_OF: JSON.from("nft_balanceof")])
        let balanceOf = try await nameService.balanceOf(account1.scriptHash!)
        XCTAssertEqual(balanceOf, 244)
    }
    
    public func testOwnerOf() async throws {
        _ = mockUrlSession.invokeFunctions([OWNER_OF: JSON.from("nns_ownerof"),
                                            DECIMALS: JSON.from("nns_invokefunction_decimals"),
                                            IS_AVAILABLE: JSON.from("invokefunction_returnFalse")])
        let ownerOf = try await nameService.ownerOf(.init("client1.neo"))
        XCTAssertEqual(ownerOf, try .init(defaultAccountScriptHash))
    }
    
    public func testProperties() async throws {
        _ = mockUrlSession.invokeFunctions([PROPERTIES: JSON.from("nns_properties")])
        let properties = try await nameService.properties(.init("neow3j.neo"))
        XCTAssertEqual(properties["image"], "https://neo3.azureedge.net/images/neons.png")
        XCTAssertEqual(properties["expiration"], "1698166908502")
        XCTAssertEqual(properties["name"], "neow3j.neo")
        XCTAssertNil(properties["admin"])
    }
    
    public func testTransfer() async throws {
        _ = mockUrlSession.data(["invokescript": JSON.from("nns_returnAny"),
                                 "getblockcount": JSON.from("getblockcount_1000")])
        .invokeFunctions([OWNER_OF: JSON.from("nns_invokefunction_ownerof"),
                          DECIMALS: JSON.from("nns_invokefunction_decimals"),
                      IS_AVAILABLE: JSON.from("invokefunction_returnFalse")])
        
        let expectedScript = try ScriptBuilder()
            .contractCall(nameServiceHash, method: TRANSFER,
                          params: [.hash160(account2.getScriptHash()),
                                   .byteArray("636c69656e74312e6e656f"),
                                   nil])
            .toArray()
        
        let b = try await nameService.transfer(account1, account2.getScriptHash(), NNSName("client1.neo"))
        XCTAssertEqual(b.script, expectedScript)
    }


    public func testTokens() async throws {
        _ = mockUrlSession.invokeFunctions([TOKENS: JSON.from("invokefunction_iterator_session")])
        let tokensIterator = try await nameService.tokens()
        XCTAssertEqual(tokensIterator.iteratorId, "190d19ca-e935-4ad0-95c9-93b8cf6d115c")
        XCTAssertEqual(tokensIterator.sessionId, "a7b35b13-bdfc-4ab3-a398-88a9db9da4fe")
    }

    public func testGetProperties() async throws {
        _ = mockUrlSession.invokeFunctions([IS_AVAILABLE: JSON.from("invokefunction_returnFalse"),
                                              PROPERTIES: JSON.from("nns_invokefunction_properties")])
        let nameState = try await nameService.getNameState(NNSName("client1.neo"))
        XCTAssertEqual(nameState.name, "client1.neo")
        XCTAssertEqual(nameState.expiration, 1646214292)
        XCTAssertEqual(nameState.admin, try Hash160("69ecca587293047be4c59159bf8bc399985c160d"))
    }
    
    public func testProperties_noAdmin() async throws {
        _ = mockUrlSession.invokeFunctions([IS_AVAILABLE: JSON.from("invokefunction_returnFalse"),
                                              PROPERTIES: JSON.from("nns_invokefunction_properties_noAdmin")])

        let nameState = try await nameService.getNameState(NNSName("client2.neo"))

        XCTAssertEqual(nameState.name, "client2.neo")
        XCTAssertEqual(nameState.expiration, 1677933305472)
        XCTAssertNil(nameState.admin)
    }

    public func testProperties_unexpectedReturnType() async throws {
        _ = mockUrlSession.invokeFunctions([IS_AVAILABLE: JSON.from("invokefunction_returnFalse"),
                                              PROPERTIES: JSON.from("invokefunction_returnInt")])

        do {
            _ = try await nameService.getNameState(NNSName("client1.neo"))
            XCTFail("No exception")
        } catch {
            guard case ContractError.unexpectedReturnType = error else {
                return XCTFail("Unexpected exception thrown: \(error)")
            }
            XCTAssertEqual(error.localizedDescription, "Got stack item of type Integer but expected Map.")
        }
    }
    
    // MARK: Custom NNS Methods
    
    public func testAddRoot() throws {
        let expectedScript = try ScriptBuilder()
            .contractCall(nameServiceHash, method: ADD_ROOT, params: [.string("neow")])
            .toArray()

        let b = try nameService.addRoot(NNSName.NNSRoot("neow"))
            .signers(AccountSigner.calledByEntry(account1))

        XCTAssertEqual(b.signers[0].signerHash, account1.scriptHash)
        XCTAssert(b.signers[0].scopes.contains(.calledByEntry))
        XCTAssertEqual(b.script, expectedScript)
    }
    
    public func testGetRoots() async throws {
        _ = mockUrlSession.invokeFunctions([ROOTS: JSON.from("invokefunction_iterator_session")])

        let rootsIterator = try await nameService.getRoots()
        XCTAssertEqual(rootsIterator.iteratorId, "190d19ca-e935-4ad0-95c9-93b8cf6d115c")
        XCTAssertEqual(rootsIterator.sessionId, "a7b35b13-bdfc-4ab3-a398-88a9db9da4fe")
    }

    public func testUnwrapRoots() async throws {
        _ = mockUrlSession.data(["invokescript": JSON.from("nns_unwrapRoots")])

        let roots = try await nameService.getRootsUnwrapped()
        XCTAssertEqual(roots[0], "eth")
        XCTAssertEqual(roots[1], "neo")
    }
    
    public func testSetPrice() throws {
        let expectedScript = try ScriptBuilder()
            .contractCall(nameServiceHash, method: SET_PRICE,
                          params: [.array([ContractParameter.integer(200_000_000),
                                           ContractParameter.integer(100_000_000),
                                           ContractParameter.integer(150_000_000)])])
            .toArray()

        let b = try nameService.setPrice([200_000_000, 100_000_000, 150_000_000])
            .signers(AccountSigner.calledByEntry(account1))

        XCTAssertEqual(b.signers[0].signerHash, account1.scriptHash)
        XCTAssert(b.signers[0].scopes.contains(WitnessScope.calledByEntry))
        XCTAssertEqual(b.script, expectedScript)
    }
    
    public func testGetPrice() async throws {
        _ = mockUrlSession.invokeFunctions([GET_PRICE: JSON.from("nns_invokefunction_getPrice")])
        let price = try await nameService.getPrice(1)
        XCTAssertEqual(price, 1000000000)
    }
    
    public func testIsAvailable() async throws {
        _ = mockUrlSession.invokeFunctions([IS_AVAILABLE: JSON.from("invokefunction_returnFalse")])
        let isAvailable = try await nameService.isAvailable(NNSName("second.neo"))
        XCTAssertFalse(isAvailable)
    }
    
    public func testIsAvailable_rootNotExisting() async throws {
        _ = mockUrlSession.invokeFunctions([IS_AVAILABLE: JSON.from("nns_noExistingRoot")])
        do {
            _ = try await nameService.isAvailable(NNSName("client1.neo"))
            XCTFail("No exception")
        } catch {
            guard case ProtocolError.invocationFaultState = error else {
                return XCTFail("Unexpected exception thrown: \(error)")
            }
            XCTAssert(error.localizedDescription.contains("An unhandled exception was thrown. The root does not exist."))
        }
    }
    
    public func testRegister() async throws {
        _ = mockUrlSession.data(["invokescript": JSON.from("nns_returnAny"),
                                 "getblockcount": JSON.from("getblockcount_1000")])
        _ = mockUrlSession.invokeFunctions([IS_AVAILABLE: JSON.from("invokefunction_returnTrue")])

        let expectedScript = try ScriptBuilder()
            .contractCall(nameServiceHash, method: REGISTER,
                          params: [.string("client1.neo"), .hash160(account1.getScriptHash())])
            .toArray()
        let b = try await nameService.register(NNSName("client1.neo"), account1.getScriptHash())
        XCTAssertEqual(b.script, expectedScript)
    }
    
    public func testRegister_domainNotAvailable() async throws {
        _ = mockUrlSession.invokeFunctions([IS_AVAILABLE: JSON.from("invokefunction_returnFalse")])
        do {
            _ = try await nameService.register(NNSName("client1.neo"), account2.getScriptHash())
            XCTFail("No exception")
        } catch {
            guard case NeoSwiftError.illegalArgument = error else {
                return XCTFail("Unexpected exception thrown: \(error)")
            }
            XCTAssertEqual(error.localizedDescription, "The domain name 'client1.neo' is already taken.")
        }
    }
    
    public func testRenew() async throws {
        _ = mockUrlSession.data(["invokescript": JSON.from("nns_returnAny"),
                                 "getblockcount": JSON.from("getblockcount_1000")])
        _ = mockUrlSession.invokeFunctions([IS_AVAILABLE: JSON.from("invokefunction_returnFalse")])
        
        let expectedScript = try ScriptBuilder()
            .contractCall(nameServiceHash, method: RENEW, params: [.string("client1.neo")])
            .toArray()
        
        let b = try await nameService.renew(NNSName("client1.neo"))
        
        XCTAssertEqual(b.script, expectedScript)
    }
    
    public func testRenewYears() async throws {
        _ = mockUrlSession.data(["invokescript": JSON.from("nns_returnAny"),
                                 "getblockcount": JSON.from("getblockcount_1000")])
        _ = mockUrlSession.invokeFunctions([IS_AVAILABLE: JSON.from("invokefunction_returnFalse")])
        
        let expectedScript = try ScriptBuilder()
            .contractCall(nameServiceHash, method: RENEW, params: [.string("client1.neo"), .integer(3)])
            .toArray()
        
        let b = try await nameService.renew(NNSName("client1.neo"), 3)
        
        XCTAssertEqual(b.script, expectedScript)
    }
    
    public func testRenewYears_invalidRange() async throws {
        for years in [0, 11] {
            do {
                _ = try await nameService.renew(NNSName("client1.neo"), years)
            } catch {
                guard case NeoSwiftError.illegalArgument = error else {
                    return XCTFail("Unexpected exception thrown: \(error)")
                }
                XCTAssertEqual(error.localizedDescription, "Domain names can only be renewed by at least 1, and at most 10 years.")
            }
        }
    }
    
    public func testSetAdmin() async throws {
        _ = mockUrlSession.data(["invokescript": JSON.from("nns_returnAny"),
                                 "getblockcount": JSON.from("getblockcount_1000")])
        _ = mockUrlSession.invokeFunctions([IS_AVAILABLE: JSON.from("invokefunction_returnFalse")])
        
        let expectedScript = try ScriptBuilder()
            .contractCall(nameServiceHash, method: SET_ADMIN,
                          params: [.string("client1.neo"), .hash160(account2.getScriptHash())])
            .toArray()
        
        let b = try await nameService.setAdmin(NNSName("client1.neo"), account2.getScriptHash())
        
        XCTAssertEqual(b.script, expectedScript)
    }
    
    public func testSetRecord_typeA() throws {
        _ = mockUrlSession.data(["invokescript": JSON.from("nns_returnAny"),
                                 "getblockcount": JSON.from("getblockcount_1000")])
        _ = mockUrlSession.invokeFunctions([IS_AVAILABLE: JSON.from("invokefunction_returnFalse")])
        
        let expectedScript = try ScriptBuilder()
            .contractCall(nameServiceHash, method: SET_RECORD,
                          params: [.string("client1.neo"), .integer(1), .string("127.0.0.1")])
            .toArray()
        
        let b = try nameService.setRecord(NNSName("client1.neo"), RecordType.a, "127.0.0.1")
        
        XCTAssertEqual(b.script, expectedScript)
    }
    
    public func testSetRecord_typeCNAME() throws {
        _ = mockUrlSession.data(["invokescript": JSON.from("nns_returnAny"),
                                 "getblockcount": JSON.from("getblockcount_1000")])
        _ = mockUrlSession.invokeFunctions([IS_AVAILABLE: JSON.from("invokefunction_returnFalse")])
        
        let expectedScript = try ScriptBuilder()
            .contractCall(nameServiceHash, method: SET_RECORD,
                          params: [.string("client1.neo"), .integer(5), .string("firstlevel.client1.neo")])
            .toArray()
        
        let b = try nameService.setRecord(NNSName("client1.neo"), RecordType.cname, "firstlevel.client1.neo")
        
        XCTAssertEqual(b.script, expectedScript)
    }
    
    public func testSetRecord_typeTXT() throws {
        _ = mockUrlSession.data(["invokescript": JSON.from("nns_returnAny"),
                                 "getblockcount": JSON.from("getblockcount_1000")])
        _ = mockUrlSession.invokeFunctions([IS_AVAILABLE: JSON.from("invokefunction_returnFalse")])
        
        let expectedScript = try ScriptBuilder()
            .contractCall(nameServiceHash, method: SET_RECORD,
                          params: [.string("client1.neo"), .integer(16), .string("textRecord")])
            .toArray()
        
        let b = try nameService.setRecord(NNSName("client1.neo"), .txt, "textRecord")
        
        XCTAssertEqual(b.script, expectedScript)
    }
    
    public func testSetRecord_typeAAAA() throws {
        _ = mockUrlSession.data(["invokescript": JSON.from("nns_returnAny"),
                                 "getblockcount": JSON.from("getblockcount_1000")])
        _ = mockUrlSession.invokeFunctions([IS_AVAILABLE: JSON.from("invokefunction_returnFalse")])
        
        let expectedScript = try ScriptBuilder()
            .contractCall(nameServiceHash, method: SET_RECORD,
                          params: [.string("client1.neo"), .integer(28), .string("1234::1234")])
            .toArray()
        
        let b = try nameService.setRecord(NNSName("client1.neo"), .aaaa, "1234::1234")
        
        XCTAssertEqual(b.script, expectedScript)
    }
    
    public func testGetRecord_typeA() async throws {
        _ = mockUrlSession.invokeFunctions([IS_AVAILABLE: JSON.from("invokefunction_returnFalse"),
                                              GET_RECORD: JSON.from("nns_getRecord_typeA")])
        
        let record = try await nameService.getRecord(NNSName("client1.neo"), .a)
        XCTAssertEqual(record, "127.0.0.1")
    }
    
    public func testGetRecord_typeCNAME() async throws {
        _ = mockUrlSession.invokeFunctions([IS_AVAILABLE: JSON.from("invokefunction_returnFalse"),
                                              GET_RECORD: JSON.from("nns_getRecord_typeCNAME")])
        
        let record = try await nameService.getRecord(NNSName("client1.neo"), .cname)
        XCTAssertEqual(record, "second.client1.neo")
    }
    
    public func testGetRecord_typeTXT() async throws {
        _ = mockUrlSession.invokeFunctions([IS_AVAILABLE: JSON.from("invokefunction_returnFalse"),
                                              GET_RECORD: JSON.from("nns_getRecord_typeTXT")])
        
        let record = try await nameService.getRecord(NNSName("client1.neo"), .txt)
        XCTAssertEqual(record, "textRecord")
    }
    
    public func testGetRecord_typeAAAA() async throws {
        _ = mockUrlSession.invokeFunctions([IS_AVAILABLE: JSON.from("invokefunction_returnFalse"),
                                              GET_RECORD: JSON.from("nns_getRecord_typeAAAA")])
        
        let record = try await nameService.getRecord(NNSName("client1.neo"), .aaaa)
        XCTAssertEqual(record, "2001:0db8:0000:0000:0000:ff00:0042:8329")
    }
    
    public func testGetRecord_noRecord() async throws {
        _ = mockUrlSession.invokeFunctions([IS_AVAILABLE: JSON.from("invokefunction_returnFalse"),
                                              GET_RECORD: JSON.from("nns_noRecordOfDomain")])
        do {
            _ = try await nameService.getRecord(NNSName("client1.neo"), .aaaa)
        } catch {
            guard case NeoSwiftError.illegalArgument = error else {
                return XCTFail("Unexpected exception thrown: \(error)")
            }
            XCTAssert(error.localizedDescription.contains("Could not get a record of type 'aaaa' for the domain name 'client1.neo'."))
        }
    }
    
    public func testGetRecord_notRegistered() async throws {
        _ = mockUrlSession.invokeFunctions([IS_AVAILABLE: JSON.from("invokefunction_returnFalse"),
                                              GET_RECORD: JSON.from("nns_getRecord_notRegistered")])
        do {
            _ = try await nameService.getRecord(NNSName("client1.neo"), .aaaa)
        } catch {
            guard case NeoSwiftError.illegalArgument = error else {
                return XCTFail("Unexpected exception thrown: \(error)")
            }
            XCTAssert(error.localizedDescription.contains("might not be registered or is in an invalid format."))
        }
    }
    
    public func testGetAllRecords() async throws {
        _ = mockUrlSession.invokeFunctions([GET_ALL_RECORDS: JSON.from("invokefunction_iterator_session")])
        
        let iterator = try await nameService.getAllRecords(NNSName("test.neo"))
        XCTAssertEqual(iterator.iteratorId, "190d19ca-e935-4ad0-95c9-93b8cf6d115c")
        XCTAssertEqual(iterator.sessionId, "a7b35b13-bdfc-4ab3-a398-88a9db9da4fe")
    }
    
    public func testUnwrapAllRecords() async throws {
        _ = mockUrlSession.data(["invokescript": JSON.from("nns_unwrapAllRecords")])
        
        let recordStates = try await nameService.getAllRecordsUnwrapped(NNSName("test.neo"))
        
        XCTAssertEqual(recordStates, [
            .init(name: "unwrapallrecords.neo", recordType: .cname, data: "neow3j.neo"),
            .init(name: "unwrapallrecords.neo", recordType: .txt, data: "unwrapAllRecordsTXT")
        ])
    }
    
    public func testDeleteRecord() throws {
        _ = mockUrlSession.data(["invokescript": JSON.from("nns_returnAny"),
                                 "getblockcount": JSON.from("getblockcount_1000")])
        _ = mockUrlSession.invokeFunctions([IS_AVAILABLE: JSON.from("invokefunction_returnFalse")])
        
        let expectedScript = try ScriptBuilder()
            .contractCall(nameServiceHash, method: DELETE_RECORD,
                          params: [.string("client1.neo"), .integer(16)])
            .toArray()
        
        let b = try nameService.deleteRecord(NNSName("client1.neo"), .txt)
        
        XCTAssertEqual(b.script, expectedScript)
    }
    
    public func testResolve_typeA() async throws {
        _ = mockUrlSession.invokeFunctions([IS_AVAILABLE: JSON.from("invokefunction_returnFalse"),
                                                 RESOLVE: JSON.from("nns_resolve_typeA")])
        
        let record = try await nameService.resolve(NNSName("client1.neo"), .a)
        XCTAssertEqual(record, "157.0.0.1")
    }
    
    public func testResolve_typeCNAME() async throws {
        _ = mockUrlSession.invokeFunctions([IS_AVAILABLE: JSON.from("invokefunction_returnFalse"),
                                                 RESOLVE: JSON.from("nns_resolve_typeCNAME")])
        
        let record = try await nameService.resolve(NNSName("client1.neo"), .cname)
        XCTAssertEqual(record, "neow3j.io")
    }
    
    public func testResolve_typeTXT() async throws {
        _ = mockUrlSession.invokeFunctions([IS_AVAILABLE: JSON.from("invokefunction_returnFalse"),
                                                 RESOLVE: JSON.from("nns_resolve_typeTXT")])
        
        let record = try await nameService.resolve(NNSName("client1.neo"), .txt)
        XCTAssertEqual(record, "NTXJgQrqxnSFFqKe3oBejnnzjms61Yzb8r")
    }
    
    public func testResolve_typeAAAA() async throws {
        _ = mockUrlSession.invokeFunctions([IS_AVAILABLE: JSON.from("invokefunction_returnFalse"),
                                                 RESOLVE: JSON.from("nns_resolve_typeAAAA")])
        
        let record = try await nameService.resolve(NNSName("client1.neo"), .aaaa)
        XCTAssertEqual(record, "3001:2:3:4:5:6:7:8")
    }
    
    public func testResolve_noRecord() async throws {
        _ = mockUrlSession.invokeFunctions([IS_AVAILABLE: JSON.from("invokefunction_returnFalse"),
                                                 RESOLVE: JSON.from("nns_returnAny")])
        
        do {
            _ = try await nameService.resolve(NNSName("client1.neo"), .aaaa)
        } catch {
            guard case ContractError.unresolvableDomainName = error else {
                return XCTFail("Unexpected exception thrown: \(error)")
            }
            XCTAssert(error.localizedDescription.contains(" 'client1.neo' could not be resolved."))
        }
    }
    
    public func testGetNameState() async throws {
        _ = mockUrlSession.invokeFunctions([PROPERTIES: JSON.from("nns_getNameState")])
        
        let nameState = try await nameService.getNameState(NNSName("namestate.neo"))
        XCTAssertEqual(nameState, try! .init(name: "getnamestatewithbytes.neo",
                                             expiration: 1698165160330,
                                             admin: .fromAddress("NV1Q1dTdvzPbThPbSFz7zudTmsmgnCwX6c")))
    }
    
    // MARK: Availability Check
    
    public func testDomainIsNotAvailableButShouldBe() async throws {
        _ = mockUrlSession.invokeFunctions([IS_AVAILABLE: JSON.from("invokefunction_returnFalse")])
        do {
            _ = try await nameService.checkDomainNameAvailability(NNSName("client1.neo"), true)
        } catch {
            guard case NeoSwiftError.illegalArgument = error else {
                return XCTFail("Unexpected exception thrown: \(error)")
            }
            XCTAssertEqual(error.localizedDescription, "The domain name 'client1.neo' is already taken.")
        }
    }
    
    public func testDomainIsAvailableButShouldNot() async throws {
        _ = mockUrlSession.invokeFunctions([IS_AVAILABLE: JSON.from("invokefunction_returnTrue")])
        do {
            _ = try await nameService.checkDomainNameAvailability(NNSName("yak.neo"), false)
        } catch {
            guard case NeoSwiftError.illegalArgument = error else {
                return XCTFail("Unexpected exception thrown: \(error)")
            }
            XCTAssertEqual(error.localizedDescription, "The domain name 'yak.neo' is not registered.")
        }
    }

}

