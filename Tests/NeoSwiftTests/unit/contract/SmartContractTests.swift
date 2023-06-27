
import XCTest
@testable import NeoSwift

class SmartContractTests: XCTestCase {
    
    private let NEO_SCRIPT_HASH = NeoToken.SCRIPT_HASH
    private let SOME_SCRIPT_HASH = try! Hash160("969a77db482f74ce27105f760efa139223431394")
    private let account1 = try! Account.fromWIF("L1WMhxazScMhUrdv34JqQb1HFSQmWeN2Kpc1R9JGKwL7CDNP21uR")
    private let recipient = try! Hash160("969a77db482f74ce27105f760efa139223431394")
    
    private var mockUrlSession: MockURLSession!
    private var someContract: SmartContract!
    private var neoContract: SmartContract!
    
    private let NEP17_TRANSFER = "transfer"
    private let NEP17_BALANCEOF = "balanceOf"
    private let NEP17_NAME = "name"
    private let NEP17_TOTALSUPPLY = "totalSupply"

    override func setUp() {
        super.setUp()
        mockUrlSession = MockURLSession()
        let neoSwift = NeoSwift.build(HttpService(urlSession: mockUrlSession))
        someContract = SmartContract(scriptHash: SOME_SCRIPT_HASH, neoSwift: neoSwift)
        neoContract = SmartContract(scriptHash: NEO_SCRIPT_HASH, neoSwift: neoSwift)
    }
    
    public func testConstructSmartContract() {
        XCTAssertEqual(neoContract.scriptHash, NEO_SCRIPT_HASH)
    }
    
    public func testGetManifest() async throws {
        _ = mockUrlSession.data(["getcontractstate": JSON.from("contractstate")])
        let manifest = try await someContract.getManifest()
        
        XCTAssertEqual(manifest.name, "neow3j")
    }
    
    public func testGetName() async throws {
        _ = mockUrlSession.data(["getcontractstate": JSON.from("contractstate")])
        let name = try await someContract.getName()
        
        XCTAssertEqual(name, "neow3j")
    }
    
    public func testInvokeWithEmptytring() {
        XCTAssertThrowsError(try neoContract.invokeFunction("", [])) { error in
            guard case NeoSwiftError.illegalArgument(let message) = error else {
                return XCTFail()
            }
            XCTAssertEqual(message, "The invocation function must not be empty.")
        }
    }
    
    public func testBuildInvokeFunctionScript() throws {
        let expectedScript = try ScriptBuilder()
            .contractCall(NEO_SCRIPT_HASH, method: NEP17_TRANSFER,
                          params: [.hash160(account1.scriptHash!), .hash160(recipient), .integer(42)])
            .toArray()
        
        let script = try neoContract.buildInvokeFunctionScript(NEP17_TRANSFER, [.hash160(account1.scriptHash!), .hash160(recipient), .integer(42)])
        
        XCTAssertEqual(script, expectedScript)
    }
    
    public func testInvokeFunction() throws {
        let expectedScript = try ScriptBuilder()
            .contractCall(NEO_SCRIPT_HASH, method: NEP17_TRANSFER,
                          params: [.hash160(account1.scriptHash!), .hash160(recipient), .integer(42)])
            .toArray()
        
        let builder = try neoContract.invokeFunction(NEP17_TRANSFER, [.hash160(account1.scriptHash!), .hash160(recipient), .integer(42)])
        
        XCTAssertEqual(builder.script, expectedScript)
    }
    
    public func testCallFunctionReturningString() async throws {
        _ = mockUrlSession.data(["invokefunction": JSON.from("invokefunction_symbol")])
        let name = try await someContract.callFunctionReturningString("symbol")
        
        XCTAssertEqual(name, "ant")
    }
    
    public func testCallFunctionReturningNonString() async throws {
        _ = mockUrlSession.data(["invokefunction": JSON.from("invokefunction_totalSupply")])
        do {
            _ = try await neoContract.callFunctionReturningString(NEP17_NAME)
            XCTFail("No exception.")
        } catch ContractError.unexpectedReturnType {
            return
        } catch {
            XCTFail("Incorrect exception.")
        }
    }
    
    public func testCallFunctionReturningInt() async throws {
        _ = mockUrlSession.data(["invokefunction": JSON.from("invokefunction_totalSupply")])
        let supply = try await someContract.callFunctionReturningInt(NEP17_TOTALSUPPLY)
        
        XCTAssertEqual(supply, 300_0000_000_000_000)
    }
    
    public func testCallFunctionReturningNonInt() async throws {
        _ = mockUrlSession.data(["invokefunction": JSON.from("invokefunction_returnTrue")])
        do {
            _ = try await neoContract.callFunctionReturningString(NEP17_TRANSFER)
            XCTFail("No exception.")
        } catch ContractError.unexpectedReturnType {
            return
        } catch {
            XCTFail("Incorrect exception.")
        }
    }
    
    public func testCallFunctionReturningBool() async throws {
        _ = mockUrlSession.data(["invokefunction": JSON.from("invokefunction_returnFalse")])
        let b = try await someContract.callFunctionReturningBool(NEP17_TOTALSUPPLY)
        
        XCTAssertFalse(b)
    }
    
    public func testCallFunctionReturningBool_zero() async throws {
        _ = mockUrlSession.data(["invokefunction": JSON.from("invokefunction_returnIntZero")])
        let b = try await someContract.callFunctionReturningBool(NEP17_TOTALSUPPLY)
        
        XCTAssertFalse(b)
    }
    
    public func testCallFunctionReturningBool_one() async throws {
        _ = mockUrlSession.data(["invokefunction": JSON.from("invokefunction_returnIntOne")])
        let b = try await someContract.callFunctionReturningBool(NEP17_TOTALSUPPLY)
        
        XCTAssertTrue(b)
    }
    
    public func testCallFunctionReturningNonBool() async throws {
        _ = mockUrlSession.data(["invokefunction": JSON.from("invokefunction_getcandidates")])
        do {
            _ = try await neoContract.callFunctionReturningBool("getCandidates")
            XCTFail("No exception.")
        } catch ContractError.unexpectedReturnType {
            return
        } catch {
            XCTFail("Incorrect exception.")
        }
    }
    
    public func testCallFunctionReturningScriptHash() async throws {
        _ = mockUrlSession.invokeFunctions(["ownerOf": JSON.from("nft_ownerof")])
        let scriptHash = try await someContract.callFunctionReturningScriptHash("ownerOf")
        
        XCTAssertEqual(scriptHash, try! Hash160("69ecca587293047be4c59159bf8bc399985c160d"))
    }
    
    public func testCallFunctionReturningIterator() async throws {
        _ = mockUrlSession
            .data(["traverseiterator": JSON.from("nft_tokensof_traverseiterator")])
            .invokeFunctions(["tokensOf": JSON.from("invokefunction_iterator_session")])
        let iterator = try await someContract.callFunctionReturningIterator("tokensOf")
        
        XCTAssertEqual(iterator.iteratorId, "190d19ca-e935-4ad0-95c9-93b8cf6d115c")
        XCTAssertEqual(iterator.sessionId, "a7b35b13-bdfc-4ab3-a398-88a9db9da4fe")
    }
    
    public func testCallFunctionReturningIterator_traverseWithFunction() async throws {
        _ = mockUrlSession
            .data(["traverseiterator": JSON.from("nft_tokensof_traverseiterator")])
            .invokeFunctions(["tokensOf": JSON.from("invokefunction_iterator_session")])
        let iterator = try await someContract.callFunctionReturningIterator("tokensOf", mapper: \.string)
        
        XCTAssertEqual(iterator.iteratorId, "190d19ca-e935-4ad0-95c9-93b8cf6d115c")
        XCTAssertEqual(iterator.sessionId, "a7b35b13-bdfc-4ab3-a398-88a9db9da4fe")
        
        let strings = try await iterator.traverse(100)
        XCTAssertEqual(strings[0], "tokenof1")
        XCTAssertEqual(strings[1], "tokenof2")
    }
    
    public func testCallFunctionTraversingIterator() async throws {
        _ = mockUrlSession
            .data(["traverseiterator": JSON.from("traverseiterator"),
                   "terminatesession": JSON.from("terminatesession")])
            .invokeFunctions(["iterateTokens": JSON.from("invokefunction_iterator_session")])
        let tokens = try await someContract.callFunctionAndTraverseIterator("iterateTokens")
        
        XCTAssertEqual(tokens.count, 2)
        
        let token1 = try tokens[0].getList()
        XCTAssertEqual(token1[0].string, "neow#1")
        XCTAssertEqual(token1[1].string, "besttoken")

        let token2 = try tokens[1].getList()
        XCTAssertEqual(token2[0].string, "neow#2")
        XCTAssertEqual(token2[1].string, "almostbesttoken")
    }
    
    public func testCallFunctionTraversingIterator_withFunction() async throws {
        _ = mockUrlSession
            .data(["traverseiterator": JSON.from("traverseiterator"),
                   "terminatesession": JSON.from("terminatesession")])
            .invokeFunctions(["tokens": JSON.from("invokefunction_iterator_session")])
        
        let strings = try await someContract.callFunctionAndTraverseIterator("tokens", mapper: \.list?[1].string)
        
        XCTAssertEqual(strings[0], "besttoken")
        XCTAssertEqual(strings[1], "almostbesttoken")
    }
    
    public func testCallFunctionReturningIteratorOtherReturnType() async throws {
        _ = mockUrlSession.invokeFunctions(["symbol": JSON.from("invokefunction_symbol")])
        do {
            _ = try await neoContract.callFunctionReturningIterator("symbol")
            XCTFail("No exception.")
        } catch ContractError.unexpectedReturnType {
            return
        } catch {
            XCTFail("Incorrect exception.")
        }
    }
    
    public func testCallFunctionReturningIterator_sessionsDisabled() async throws {
        _ = mockUrlSession.invokeFunctions(["tokensOf": JSON.from("invokefunction_iterator_sessionDisabled")])
        do {
            _ = try await neoContract.callFunctionReturningIterator("tokensOf")
            XCTFail("No exception.")
        } catch NeoSwiftError.illegalState(let message) {
            XCTAssertEqual(message, "No session id was found. The connected Neo node might not support sessions.")
        } catch {
            XCTFail("Incorrect exception.")
        }
    }
    
    public func testInvokingFunctionPerformsCorrectCall() async throws {
        _ = mockUrlSession.invokeFunctions([NEP17_BALANCEOF: JSON.from("invokefunction_balanceOf_3")])
        
        let response = try await neoContract.callInvokeFunction(NEP17_BALANCEOF, [.hash160(account1.getScriptHash())])
        
        XCTAssertEqual(response.invocationResult?.stack.first?.integer, 3)
    }
    
    public func testInvokingFunctionPerformsCorrectCall_WithoutParameters() async throws {
        _ = mockUrlSession.data(["invokefunction": JSON.from("invokefunction_symbol_neo")])
        
        let invokeFunction = try await neoContract.callInvokeFunction("symbol")
        
        XCTAssertEqual(invokeFunction.invocationResult?.stack.first?.string, "NEO")
    }
    
    public func testCallFunctionAndUnwrapIterator() async throws {
        _ = mockUrlSession.data(["invokescript": JSON.from("invokescript_ownerOf_array")])
        
        let iteratorArray = try await someContract.callFunctionAndUnwrapIterator("ownerOf", [], 20)
        
        XCTAssertEqual(iteratorArray.count, 2)
        XCTAssertEqual(iteratorArray[0].address, "NSdNMyrz7Bp8MXab41nTuz1mRCnsFr5Rsv")
        XCTAssertEqual(iteratorArray[1].address, "NhxK1PEmijLVD6D4WSuPoUYJVk855L21ru")
    }
    
    public func testCallInvokeFunction_missingFunction() async throws {
        _ = mockUrlSession.invokeFunctions(["symbol": JSON.from("invokefunction_symbol")])
        do {
            _ = try await neoContract.callInvokeFunction("")
            XCTFail("No exception.")
        } catch NeoSwiftError.illegalArgument(let message) {
            XCTAssertEqual(message, "The invocation function must not be empty.")
        } catch {
            XCTFail("Incorrect exception.")
        }
    }
    
}
