
import XCTest
@testable import NeoSwift

class NonFungibleTokenTests: XCTestCase {
    
    private let NF_TOKEN_SCRIPT_HASH = try! Hash160.fromAddress("NQyYa8wycZRkEvQKr5qRUvMUwyDgvQMqL7")
    private let TOKEN_ID: Bytes = [1, 2, 3]
    private let TRANSFER = "transfer"
        
    private let account1 = try! Account.fromWIF(defaultAccountWIF)
    private let account2 = try! Account.fromWIF(client1AccountWIF)
    
    private var mockUrlSession: MockURLSession!
    private var nfTestToken: NonFungibleToken!
    
    override func setUp() {
        mockUrlSession = MockURLSession()
        let neoSwift = NeoSwift.build(HttpService(urlSession: mockUrlSession))
        nfTestToken = NonFungibleToken(scriptHash: NF_TOKEN_SCRIPT_HASH, neoSwift: neoSwift)
    }
    
    public func testTransferNonDivisible() async throws {
        _ = mockUrlSession.invokeFunctions(["decimals": JSON.from("nft_decimals_0"),
                                            "ownerOf": JSON.from("nft_ownerof")])
        
        let expectedScript = try ScriptBuilder()
            .contractCall(NF_TOKEN_SCRIPT_HASH, method: TRANSFER,
                          params: [.hash160(account2.getScriptHash()), .byteArray(TOKEN_ID), .any(nil)])
            .toArray()
        
        let b = try await nfTestToken.transfer(account1, account2.getScriptHash(), TOKEN_ID)
        XCTAssertEqual(b.script, expectedScript)
        XCTAssert((b.signers.first as! AccountSigner).account === account1)
        
        let b2 = try await nfTestToken.transfer(account2.getScriptHash(), TOKEN_ID)
        XCTAssertEqual(b2.script, expectedScript)
        XCTAssert(b2.signers.isEmpty)
    }
    
    public func testTransferNonDivisibleToNNS() async throws {
        _ = mockUrlSession.invokeFunctions(["decimals": JSON.from("nft_decimals_0"),
                                            "ownerOf": JSON.from("nft_ownerof"),
                                            "resolve": JSON.from("nns_resolve_typeTXT")])
        
        let nnsName = try NNSName("neow3j.neo")
        let recipient = try Hash160.fromAddress("NTXJgQrqxnSFFqKe3oBejnnzjms61Yzb8r")
        
        let expectedScript = try ScriptBuilder()
            .contractCall(NF_TOKEN_SCRIPT_HASH, method: TRANSFER,
                          params: [.hash160(recipient), .byteArray(TOKEN_ID), .any(nil)])
            .toArray()
        
        let b = try await nfTestToken.transfer(account1, nnsName, TOKEN_ID)
        XCTAssertEqual(b.script, expectedScript)
        XCTAssert((b.signers.first as! AccountSigner).account === account1)
        
        let b2 = try await nfTestToken.transfer(nnsName, TOKEN_ID)
        XCTAssertEqual(b2.script, expectedScript)
        XCTAssert(b2.signers.isEmpty)
    }
    
    public func testFailOnDivisibleTransferWithNonDivisibleNFT() async throws {
        _ = mockUrlSession.invokeFunctions(["decimals": JSON.from("nft_decimals_5")])
        do {
            _ = try await nfTestToken.transfer(account2, account1.getScriptHash(), TOKEN_ID)
            XCTFail("No exception")
        } catch {
            XCTAssertEqual(error.localizedDescription, "This method is only intended for non-divisible NFTs.")
        }
    }
    
    public func testOwnerOfNonDivisible() async throws {
        _ = mockUrlSession.invokeFunctions(["decimals": JSON.from("nft_decimals_0"),
                                            "ownerOf": JSON.from("nft_ownerof")])
        let owner = try await nfTestToken.ownerOf(TOKEN_ID)
        XCTAssertEqual(owner, account1.scriptHash)
    }
    
    public func testOwnerOfNonDivisible_divisible() async throws {
        _ = mockUrlSession.invokeFunctions(["decimals": JSON.from("nft_decimals_5")])
        do {
            _ = try await nfTestToken.ownerOf(TOKEN_ID)
            XCTFail("No exception")
        } catch {
            XCTAssertEqual(error.localizedDescription, "This method is only intended for non-divisible NFTs.")
        }
    }
    
    public func testOwnerOfNonDivisible_returnNotScriptHash() async throws {
        _ = mockUrlSession.invokeFunctions(["decimals": JSON.from("nft_decimals_0"),
                                            "ownerOf": JSON.from("response_stack_integer")])
        do {
            _ = try await nfTestToken.ownerOf([1])
            XCTFail("No exception")
        } catch {
            XCTAssert(error.localizedDescription.contains("but expected \(StackItem.BYTE_STRING_VALUE)"))
        }
    }
    
    public func testOwnerOfNonDivisible_returnInvalidAddress() async throws {
        _ = mockUrlSession.invokeFunctions(["decimals": JSON.from("nft_decimals_0"),
                                            "ownerOf": JSON.from("response_invalid_address")])
        do {
            _ = try await nfTestToken.ownerOf([1])
            XCTFail("No exception")
        } catch {
            XCTAssert(error.localizedDescription.contains("Return type did not contain script hash in expected format."))
        }
    }
    
    public func testGetDecimals() async throws {
        _ = mockUrlSession.invokeFunctions(["decimals": JSON.from("nft_decimals_5")])
        let decimals = try await nfTestToken.getDecimals()
        XCTAssertEqual(decimals, 5)
    }
    
    public func testBalanceOf() async throws {
        _ = mockUrlSession.invokeFunctions(["balanceOf": JSON.from("nft_balanceof")])
        let balanceOf = try await nfTestToken.balanceOf(account1.getScriptHash())
        XCTAssertEqual(balanceOf, 244)
    }
    
    public func testTokensOf() async throws {
        _ = mockUrlSession.invokeFunctions(["tokensOf": JSON.from("invokefunction_iterator_session")])
        _ = mockUrlSession.data(["traverseiterator": JSON.from("nft_tokensof_traverseiterator")])
        let tokensIterator = try await nfTestToken.tokensOf(account1.getScriptHash())
        let tokens = try await tokensIterator.traverse(100)
        XCTAssertEqual(tokens, ["tokenof1".bytes, "tokenof2".bytes])
    }
    
    public func testGetProperties() async throws {
        _ = mockUrlSession.invokeFunctions(["properties": JSON.from("nft_properties")])
        let properties = try await nfTestToken.properties([1])
        XCTAssertEqual(properties["name"], "A name")
    }
    
    public func testGetProperties_unexpectedReturnType() async throws {
        _ = mockUrlSession.invokeFunctions(["properties": JSON.from("response_stack_integer")])
        do {
            _ =  try await nfTestToken.properties([1])
            XCTFail("No exception")
        } catch {
            XCTAssert(error.localizedDescription.contains("but expected \(StackItem.MAP_VALUE)"))
        }
    }
    
    public func testGetCustomProperties() async throws {
        _ = mockUrlSession.invokeFunctions(["properties": JSON.from("nft_customProperties")])
        let properties = try await nfTestToken.customProperties([1])
        
        XCTAssertEqual(properties.count, 4)
        XCTAssertEqual(properties["name"], .byteString("yak".bytes))
        XCTAssertEqual(properties["map1"], .map([
            .byteString("key1".bytes): .byteString("value1".bytes),
            .byteString("key2".bytes): .integer(42),
        ]))
        XCTAssertEqual(properties["array1"], .array([.byteString("hello1".bytes), .byteString("hello2".bytes)]))
        XCTAssertEqual(properties["array2"], .array([.byteString("b0".bytes), .integer(12)]))
    }
    
    public func testTokens() async throws {
        _ = mockUrlSession.invokeFunctions(["tokens": JSON.from("invokefunction_iterator_session")])
        _ = mockUrlSession.data(["traverseiterator": JSON.from("nft_tokens_traverseiterator")])
        let tokensIterator = try await nfTestToken.tokens()
        let tokens = try await tokensIterator.traverse(20)
        XCTAssertEqual(tokens, ["neow#1".bytes, "neow#2".bytes])
    }
    
    public func testTransferDivisible() async throws {
        _ = mockUrlSession.invokeFunctions(["decimals": JSON.from("nft_decimals_5")])
        let expectedScript = try ScriptBuilder()
            .contractCall(NF_TOKEN_SCRIPT_HASH, method: TRANSFER, params: [
                .hash160(account1.getScriptHash()),
                .hash160(account2.getScriptHash()),
                .integer(25000),
                .byteArray(TOKEN_ID),
                .any(nil)
            ])
            .toArray()
        
        let b = try await nfTestToken.transfer(account1, account2.getScriptHash(), 25000, TOKEN_ID)
        XCTAssertEqual(b.script, expectedScript)
        XCTAssert((b.signers.first as! AccountSigner).account === account1)

        let b2 = try await nfTestToken.transfer(account1.getScriptHash(), account2.getScriptHash(), 25000, TOKEN_ID)
        XCTAssertEqual(b2.script, expectedScript)
        XCTAssert(b2.signers.isEmpty)
    }
    
    public func testTransferDivisibleToNNS() async throws {
        _ = mockUrlSession.invokeFunctions(["decimals": JSON.from("nft_decimals_5"),
                                            "resolve": JSON.from("nns_resolve_typeTXT")])
        
        let nnsName = try NNSName("neow3j.neo")
        let recipient = try Hash160.fromAddress("NTXJgQrqxnSFFqKe3oBejnnzjms61Yzb8r")
        
        let expectedScript = try ScriptBuilder()
            .contractCall(NF_TOKEN_SCRIPT_HASH, method: TRANSFER, params: [
                .hash160(account1.getScriptHash()),
                .hash160(recipient),
                .integer(25000),
                .byteArray(TOKEN_ID),
                .any(nil)
            ])
            .toArray()
        
        let b = try await nfTestToken.transfer(account1, nnsName, 25000, TOKEN_ID)
        XCTAssertEqual(b.script, expectedScript)
        XCTAssert((b.signers.first as! AccountSigner).account === account1)

        let b2 = try await nfTestToken.transfer(account1.getScriptHash(), nnsName, 25000, TOKEN_ID)
        XCTAssertEqual(b2.script, expectedScript)
        XCTAssert(b2.signers.isEmpty)
    }
    
    public func testFailOnNonDivisibleTransferWithDivisibleNFT() async throws {
        _ = mockUrlSession.invokeFunctions(["decimals": JSON.from("nft_decimals_0")])
        do {
            _ = try await nfTestToken.transfer(account1, account2.getScriptHash(), 25000, TOKEN_ID)
            XCTFail("No exception")
        } catch {
            XCTAssertEqual(error.localizedDescription, "This method is only intended for divisible NFTs.")
        }
    }
    
    public func testOwnersOf() async throws {
        _ = mockUrlSession.invokeFunctions(["decimals": JSON.from("nft_decimals_5"),
                                            "ownerOf": JSON.from("invokefunction_iterator_session")])
        _ = mockUrlSession.data(["traverseiterator": JSON.from("nft_ownersof_traverseiterator")])

        let iterator = try await nfTestToken.ownersOf("tokenId".bytes)
        let owners = try await iterator.traverse(100)
        
        XCTAssertEqual(owners, try! [
            Hash160("88c48eaef7e64b646440da567cd85c9060efbf63"),
            Hash160("739b39ff986ca3839861bbfb443364975c4e59a2")
        ])
    }
    
    public func testOwnersOf_nonDivisible() async throws {
        _ = mockUrlSession.invokeFunctions(["decimals": JSON.from("nft_decimals_0")])
        do {
            _ = try await nfTestToken.ownersOf(TOKEN_ID)
            XCTFail("No exception")
        } catch {
            XCTAssertEqual(error.localizedDescription, "This method is only intended for divisible NFTs.")
        }
    }
    
    public func testBalanceOfDivisible() async throws {
        _ = mockUrlSession.invokeFunctions(["decimals": JSON.from("nft_decimals_5"),
                                            "balanceOf": JSON.from("nft_balanceof")])
        let balance = try await nfTestToken.balanceOf(account1.getScriptHash(), TOKEN_ID)
        XCTAssertEqual(balance, 244)
    }
    
    public func testBalanceOf_nonDivisible() async throws {
        _ = mockUrlSession.invokeFunctions(["decimals": JSON.from("nft_decimals_0")])
        do {
            _ = try await nfTestToken.balanceOf(account1.getScriptHash(), TOKEN_ID)
            XCTFail("No exception")
        } catch {
            XCTAssertEqual(error.localizedDescription, "This method is only intended for divisible NFTs.")
        }
    }
    
}
