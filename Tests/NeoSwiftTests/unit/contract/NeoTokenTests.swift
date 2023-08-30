
import XCTest
@testable import NeoSwift

class NeoTokenTests: XCTestCase {
    
    private let NEOTOKEN_SCRIPTHASH = "ef4073a0f2b305a38ec4050e4d3d28bc40ea63f5"
    private let VOTE = "vote"
    private let REGISTER_CANDIDATE = "registerCandidate"
    private let UNREGISTER_CANDIDATE = "unregisterCandidate"
    private let GET_GAS_PER_BLOCK = "getGasPerBlock"
    private let SET_GAS_PER_BLOCK = "setGasPerBlock"
    private let GET_REGISTER_PRICE = "getRegisterPrice"
    private let SET_REGISTER_PRICE = "setRegisterPrice"
    private let GET_ACCOUNT_STATE = "getAccountState"
    
    private let account1 = try! Account(keyPair: .create(privateKey: "e6e919577dd7b8e97805151c05ae07ff4f752654d6d8797597aca989c02c4cb3".bytesFromHex))
    
    private var mockUrlSession: MockURLSession!
    private var neoSwift: NeoSwift!
    
    override func setUp() {
        mockUrlSession = MockURLSession()
        neoSwift = .build(HttpService(urlSession: mockUrlSession))
    }
    
    public func testConstants() async throws {
        let neoToken = NeoToken(neoSwift)
        let name = try await neoToken.getName()
        let symbol = try await neoToken.getSymbol()
        let totalSupply = try await neoToken.getTotalSupply()
        let decimals = try await neoToken.getDecimals()
        
        XCTAssertEqual(name, "NeoToken")
        XCTAssertEqual(symbol, "NEO")
        XCTAssertEqual(totalSupply, 100_000_000)
        XCTAssertEqual(decimals, 0)
        XCTAssertEqual(neoToken.scriptHash.string, NEOTOKEN_SCRIPTHASH)
    }
    
    public func testRegisterCandidate() async throws {
        _ = mockUrlSession.data(["invokescript": JSON.from("invokescript_registercandidate"),
                                 "getblockcount": JSON.from("getblockcount_1000")])
        
        let pubKeyBytes = try account1.keyPair!.publicKey.getEncoded(compressed: true)
        let expectedScript = try ScriptBuilder()
            .contractCall(NeoToken.SCRIPT_HASH, method: REGISTER_CANDIDATE,
                          params: [.publicKey(pubKeyBytes)])
            .toArray()
        
        let b = try NeoToken(neoSwift)
            .registerCandidate(account1.keyPair!.publicKey)
            .signers(AccountSigner.global(account1))
        
        XCTAssertEqual(b.signers[0].signerHash, try! account1.getScriptHash())
        XCTAssertEqual(b.script, expectedScript)
        XCTAssert(b.signers[0].scopes.contains(.global))
    }
    
    public func testUnregisterCandidate() async throws {
        _ = mockUrlSession.data(["invokescript": JSON.from("invokescript_unregistercandidate"),
                                 "getblockcount": JSON.from("getblockcount_1000")])
        
        let pubKeyBytes = try account1.keyPair!.publicKey.getEncoded(compressed: true)
        let expectedScript = try ScriptBuilder()
            .contractCall(NeoToken.SCRIPT_HASH, method: UNREGISTER_CANDIDATE,
                          params: [.publicKey(pubKeyBytes)])
            .toArray()
        
        let b = try NeoToken(neoSwift)
            .unregisterCandidate(account1.keyPair!.publicKey)
            .signers(AccountSigner.global(account1))
        
        XCTAssertEqual(b.signers[0].signerHash, try! account1.getScriptHash())
        XCTAssertEqual(b.script, expectedScript)
        XCTAssert(b.signers[0].scopes.contains(.global))
    }
    
    public func testGetCandidates() async throws {
        _ = mockUrlSession.data(["invokefunction": JSON.from("invokefunction_getcandidates")])
        
        let result = try await NeoToken(neoSwift).getCandidates()
        
        XCTAssertEqual(result.count, 2)
        for r in result {
            XCTAssertNotNil(r.publicKey)
            XCTAssertEqual(r.votes, 0)
        }
    }
    
    public func testIsCandidate() async throws {
        _ = mockUrlSession.data(["invokefunction": JSON.from("invokefunction_getcandidates")])
        
        let pubKey = try ECPublicKey("02c0b60c995bc092e866f15a37c176bb59b7ebacf069ba94c0ebf561cb8f956238")
        let isCandidate = try await NeoToken(neoSwift).isCandidate(pubKey)
        XCTAssert(isCandidate)
    }
    
    public func testGetAllCandidatesIterator() async throws {
        _ = mockUrlSession.data(["terminatesession": JSON.from("terminatesession"),
                                 "traverseiterator": JSON.from("neo_getAllCandidates_traverseiterator")])
        _ = mockUrlSession.invokeFunctions(["getAllCandidates": JSON.from("invokefunction_iterator_session")])

        let iterator = try await NeoToken(neoSwift).getAllCandidatesIterator()
        let candidates = try await iterator.traverse(2)
        
        XCTAssertEqual(candidates, try! [
            .init(publicKey: .init("02607a38b8010a8f401c25dd01df1b74af1827dd16b821fc07451f2ef7f02da60f"),
                  votes: 340_356),
            .init(publicKey: .init("037279f3a507817251534181116cb38ef30468b25074827db34cbbc6adc8873932"),
                  votes: 10_000_000)
        ])
        
        try await iterator.terminateSession()
    }
    
    public func testGetCandidateVotes() async throws {
        _ = mockUrlSession.invokeFunctions(["getCandidateVote": JSON.from("invokefunction_getCandidateVote")])
        let votes = try await NeoToken(neoSwift).getCandidateVotes(ECKeyPair.createEcKeyPair().publicKey)
        XCTAssertEqual(votes, 721_978)
    }
    
    public func testVote() async throws {
        _ = mockUrlSession.data(["invokescript": JSON.from("invokescript_vote"),
                                 "getblockcount": JSON.from("getblockcount_1000")])
        _ = mockUrlSession.invokeFunctions(["getCandidates": JSON.from("invokefunction_getcandidates")])
        
        let pubKey = try account1.keyPair!.publicKey.getEncoded(compressed: true)
        let expectedScript = try ScriptBuilder()
            .contractCall(NeoToken.SCRIPT_HASH, method: VOTE,
                          params: [.hash160(account1.getScriptHash()), .publicKey(pubKey)])
            .toArray()
        
        let b = try await NeoToken(neoSwift)
            .vote(account1, .init(pubKey))
            .signers(AccountSigner.global(account1))
        
        XCTAssertEqual(b.script, expectedScript)
    }
    
    public func testCancelVote() async throws {
        _ = mockUrlSession.data(["invokescript": JSON.from("invokescript_vote"),
                                 "getblockcount": JSON.from("getblockcount_1000")])
        _ = mockUrlSession.invokeFunctions(["getCandidates": JSON.from("invokefunction_getcandidates")])
        
        let expectedScript = try ScriptBuilder()
            .contractCall(NeoToken.SCRIPT_HASH, method: VOTE,
                          params: [.hash160(account1.getScriptHash()), .any(nil)])
            .toArray()
        
        let b = try await NeoToken(neoSwift)
            .cancelVote(account1)
            .signers(AccountSigner.global(account1))
        
        XCTAssertEqual(b.script, expectedScript)
    }
    
    public func testBuildVoteScript() throws {
        let pubKey = account1.keyPair!.publicKey
        let expectedScript = try ScriptBuilder()
            .contractCall(NeoToken.SCRIPT_HASH, method: VOTE,
                          params: [.hash160(account1.getScriptHash()),
                                   .publicKey(pubKey.getEncoded(compressed: true))])
            .toArray()
        
        let script = try NeoToken(neoSwift).buildVoteScript(account1.getScriptHash(), pubKey)
        
        XCTAssertEqual(script, expectedScript)
    }
    
    public func testBuildCancelVoteScript() throws {
        let expectedScript = try ScriptBuilder()
            .contractCall(NeoToken.SCRIPT_HASH, method: VOTE,
                          params: [.hash160(account1.getScriptHash()), .any(nil)])
            .toArray()
        
        let script = try NeoToken(neoSwift).buildVoteScript(account1.getScriptHash(), nil)
        XCTAssertEqual(script, expectedScript)
    }
    
    public func testGetGasPerBlock() async throws {
        _ = mockUrlSession.invokeFunctions([GET_GAS_PER_BLOCK: JSON.from("invokefunction_getGasPerBlock")])
        let gas = try await NeoToken(neoSwift).getGasPerBlock()
        XCTAssertEqual(gas, 500_000)
    }
    
    public func testSetGasPerBlock() throws {
        _ = mockUrlSession.data(["invokescript": JSON.from("invokescript_vote"),
                                 "getblockcount": JSON.from("getblockcount_1000")])
        
        let gas = 10_000
        
        let expectedScript = try ScriptBuilder()
            .contractCall(NeoToken.SCRIPT_HASH, method: SET_GAS_PER_BLOCK,
                          params: [.integer(gas)])
            .toArray()
        
        let txBuilder = try NeoToken(neoSwift)
            .setGasPerBlock(gas)
            .signers(AccountSigner.calledByEntry(account1))
        
        XCTAssertEqual(txBuilder.script, expectedScript)
    }
    
    public func testGetRegisterPrice() async throws {
        _ = mockUrlSession.invokeFunctions([GET_REGISTER_PRICE: JSON.from("invokefunction_getRegisterPrice")])
        let price = try await NeoToken(neoSwift).getRegisterPrice()
        XCTAssertEqual(price, 100_000_000_000)
    }
    
    public func testSetRegisterPrice() throws {
        _ = mockUrlSession.data(["invokescript": JSON.from("invokescript_vote"),
                                 "getblockcount": JSON.from("getblockcount_1000")])
        
        let price = 50_000_000_000
        
        let expectedScript = try ScriptBuilder()
            .contractCall(NeoToken.SCRIPT_HASH, method: SET_REGISTER_PRICE,
                          params: [.integer(price)])
            .toArray()
        
        let txBuilder = try NeoToken(neoSwift)
            .setRegisterPrice(price)
            .signers(AccountSigner.calledByEntry(account1))
        
        XCTAssertEqual(txBuilder.script, expectedScript)
    }
    
    public func testGetAccountState() async throws {
        _ = mockUrlSession.invokeFunctions([GET_ACCOUNT_STATE: JSON.from("neoToken_getAccountState")])
        
        let neoAccountState = try await NeoToken(neoSwift).getAccountState(account1.getScriptHash())
        
        XCTAssertEqual(neoAccountState.balance, 20_000)
        XCTAssertEqual(neoAccountState.balanceHeight, 259)

        let publicKey = try ECPublicKey("037279f3a507817251534181116cb38ef30468b25074827db34cbbc6adc8873932")
        
        XCTAssertEqual(neoAccountState.publicKey, publicKey)
    }
    
    public func testGetAccountState_noVote() async throws {
        _ = mockUrlSession.invokeFunctions([GET_ACCOUNT_STATE: JSON.from("neoToken_getAccountState_noVote")])
        
        let neoAccountState = try await NeoToken(neoSwift).getAccountState(account1.getScriptHash())
        
        XCTAssertEqual(neoAccountState.balance, 12_000)
        XCTAssertEqual(neoAccountState.balanceHeight, 820)
        XCTAssertNil(neoAccountState.publicKey)
    }
    
    public func testGetAccountState_noBalance() async throws {
        _ = mockUrlSession.invokeFunctions([GET_ACCOUNT_STATE: JSON.from("neoToken_getAccountState_noBalance")])
        
        let neoAccountState = try await NeoToken(neoSwift).getAccountState(account1.getScriptHash())
        
        XCTAssertEqual(neoAccountState.balance, 0)
        XCTAssertNil(neoAccountState.balanceHeight)
        XCTAssertNil(neoAccountState.publicKey)
    }
    
}

