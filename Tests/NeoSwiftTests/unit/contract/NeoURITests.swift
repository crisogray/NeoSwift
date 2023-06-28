
import XCTest
@testable import NeoSwift

class NeoURITests: XCTestCase {
    
    private let BEGIN_TX = "neo:NZNos2WqTbu5oCgyfss9kUJgBXJqhuYAaj"
    private let BEGIN_TX_ASSET_AMOUNT = "neo:NZNos2WqTbu5oCgyfss9kUJgBXJqhuYAaj?asset=neo&amount=1"
    private let BEGIN_TX_ASSET_NON_NATIVE = "neo:NZNos2WqTbu5oCgyfss9kUJgBXJqhuYAaj?asset=b1e8f1ce80c81dc125e7d0e75e5ce3f7f4d4d36c"
    private let BEGIN_TX_ASSET_AMOUNT_MULTIPLE_ASSETS_AND_AMOUNTS = "neo:NZNos2WqTbu5oCgyfss9kUJgBXJqhuYAaj?asset=neo&amount=1&asset=gas&amount=80"
    private let SENDER_ACCOUNT = try! Account.fromWIF("L2jLP9VXA23Hbzo7PmvLfjwkbUaaz887w3aGaeAz5xWyzjizpu9C")
    private let RECIPIENT_ADDRESS = "NZNos2WqTbu5oCgyfss9kUJgBXJqhuYAaj"
    private let AMOUNT = Decimal(1)
    
    private lazy var SENDER = { try! SENDER_ACCOUNT.getScriptHash() }()
    private lazy var RECIPIENT = { try! Hash160.fromAddress(RECIPIENT_ADDRESS) }()
    
    private var mockUrlSession: MockURLSession!
    private var neoSwift: NeoSwift!
    
    override func setUp() {
        mockUrlSession = .init()
        neoSwift = .build(HttpService(urlSession: mockUrlSession))
    }
    
    public func testFromURI() throws {
        let uri = try NeoURI.fromURI(BEGIN_TX_ASSET_AMOUNT).buildURI().uri
        XCTAssertEqual(uri, URL(string: BEGIN_TX_ASSET_AMOUNT)!)
    }
    
    public func testFromURI_empty() throws {
        XCTAssertThrowsError(try NeoURI.fromURI("")) { error in
            XCTAssertEqual(error.localizedDescription, "The provided string does not conform to the NEP-9 standard.")
        }
    }
    
    public func testFromURI_invalidScheme() throws {
        XCTAssertThrowsError(try NeoURI.fromURI("nao:NZNos2WqTbu5oCgyfss9kUJgBXJqhuYAaj")) { error in
            XCTAssertEqual(error.localizedDescription, "The provided string does not conform to the NEP-9 standard.")
        }
    }
    
    public func testFromURI_invalidQuery() throws {
        XCTAssertThrowsError(try NeoURI.fromURI("neo:NZNos2WqTbu5oCgyfss9kUJgBXJqhuYAaj?asset==neo")) { error in
            XCTAssertEqual(error.localizedDescription, "This URI contains invalid queries.")
        }
    }
    
    public func testFromURI_invalidSeparator() throws {
        XCTAssertThrowsError(try NeoURI.fromURI("neo-NZNos2WqTbu5oCgyfss9kUJgBXJqhuYAaj")) { error in
            XCTAssertEqual(error.localizedDescription, "The provided string does not conform to the NEP-9 standard.")
        }
    }
    
    public func testFromURI_invalidURI_short() throws {
        XCTAssertThrowsError(try NeoURI.fromURI("neo:AK2nJJpJr6o664")) { error in
            XCTAssertEqual(error.localizedDescription, "The provided string does not conform to the NEP-9 standard.")
        }
    }
    
    public func testFromURI_invalidScale_neo() async throws {
        do {
            _ = try await NeoURI.fromURI("neo:NZNos2WqTbu5oCgyfss9kUJgBXJqhuYAaj?asset=neo&amount=1.1")
                .neoSwift(neoSwift).buildTransferFrom(SENDER_ACCOUNT)
            XCTFail("No exception.")
        } catch NeoSwiftError.illegalArgument(let message) {
            XCTAssertEqual(message, "The NEO token does not support any decimal places.")
        }
    }
    
    public func testFromURI_invalidScale_gas() async throws {
        do {
            _ = try await NeoURI.fromURI("neo:NZNos2WqTbu5oCgyfss9kUJgBXJqhuYAaj?asset=gas&amount=0.000000001")
                .neoSwift(neoSwift).buildTransferFrom(SENDER_ACCOUNT)
            XCTFail("No exception.")
        } catch NeoSwiftError.illegalArgument(let message) {
            XCTAssertEqual(message, "The GAS token does not support more than 8 decimal places.")
        }
    }
    
    public func testFromURI_multipleAssetsAndAmounts() throws {
        let uri = try NeoURI.fromURI(BEGIN_TX_ASSET_AMOUNT_MULTIPLE_ASSETS_AND_AMOUNTS)
            .buildURI().uri
        XCTAssertEqual(uri, URL(string: BEGIN_TX_ASSET_AMOUNT)!)
    }
    
    public func testFromURI_nonNativeToken() throws {
        let uri = try NeoURI.fromURI(BEGIN_TX_ASSET_NON_NATIVE)
        XCTAssertEqual(uri.token, try!  Hash160("b1e8f1ce80c81dc125e7d0e75e5ce3f7f4d4d36c"))
    }
    
    public func testFromURI_vars() throws {
        let uri = try NeoURI.fromURI(BEGIN_TX_ASSET_AMOUNT)
        
        XCTAssertEqual(uri.recipientAddress, RECIPIENT_ADDRESS)
        XCTAssertEqual(uri.recipient, RECIPIENT)
        XCTAssert([NeoToken.SCRIPT_HASH.string, "neo"].contains(uri.tokenString))
        XCTAssertEqual(uri.token, NeoToken.SCRIPT_HASH)
        XCTAssertEqual(uri.tokenAddress, NeoToken.SCRIPT_HASH.toAddress())
        XCTAssertEqual(uri.amount, AMOUNT)
        XCTAssertEqual(uri.amountString, "\(AMOUNT)")
    }
    
    public func testFromURI_vars_gas() throws {
        let BEGIN_TX_ASSET_GAS = "neo:NZNos2WqTbu5oCgyfss9kUJgBXJqhuYAaj?asset=gas"
        let uri = try NeoURI.fromURI(BEGIN_TX_ASSET_GAS)
        
        XCTAssertEqual(uri.tokenString, "gas")
        XCTAssertEqual(uri.token, GasToken.SCRIPT_HASH)
        XCTAssertEqual(uri.tokenAddress, GasToken.SCRIPT_HASH.toAddress())
    }
    
    public func testBuildURI() throws {
        let uri = try NeoURI().to(RECIPIENT).buildURI()
        
        XCTAssertEqual(uri.uri, URL(string: BEGIN_TX)!)
        XCTAssertEqual(uri.uriString, BEGIN_TX)
        XCTAssertEqual(uri.recipient, RECIPIENT)
        XCTAssertEqual(uri.recipientAddress, RECIPIENT_ADDRESS)
    }
    
    public func testBuildURINonNativeAsset() throws {
        let tokenHash = try Hash160("c0338c7be47126b92eae8a67a2ebaedbbdce6ceb")
        let recipient = try Hash160.fromAddress("NV4fSVvFNHAHtmyCVpQnQ85qXdttUaZkbS")
        let neoURI = try NeoURI()
            .token(tokenHash)
            .to(recipient)
            .amount(13)
            .buildURI()
        
        XCTAssertEqual(neoURI.uriString, "neo:NV4fSVvFNHAHtmyCVpQnQ85qXdttUaZkbS?asset=c0338c7be47126b92eae8a67a2ebaedbbdce6ceb&amount=13")
    }
    
    public func testBuildURI_noAddress() throws {
        XCTAssertThrowsError(try NeoURI().buildURI()) { error in
            XCTAssertEqual(error.localizedDescription, "Could not create a NEP-9 URI without a recipient address.")
        }
    }
    
    public func testBuildURI_asset() throws {
        let uri = try NeoURI().to(RECIPIENT).token("neo").buildURI()
        let BEGIN_TX_ASSET = "neo:NZNos2WqTbu5oCgyfss9kUJgBXJqhuYAaj?asset=neo"
        
        XCTAssertEqual(uri.uri, URL(string: BEGIN_TX_ASSET)!)
        XCTAssertEqual(uri.uriString, BEGIN_TX_ASSET)
    }
    
    public func testBuildURI_amount() throws {
        let uri = try NeoURI().to(RECIPIENT).amount(AMOUNT).buildURI()
        let BEGIN_TX_AMOUNT = "neo:NZNos2WqTbu5oCgyfss9kUJgBXJqhuYAaj?amount=1"
        
        XCTAssertEqual(uri.uri, URL(string: BEGIN_TX_AMOUNT)!)
        XCTAssertEqual(uri.uriString, BEGIN_TX_AMOUNT)
    }
    
    public func testBuildURI_asset_amount() throws {
        let uri = try NeoURI().to(RECIPIENT).token("neo").amount(AMOUNT).buildURI()
        
        XCTAssertEqual(uri.uri, URL(string: BEGIN_TX_ASSET_AMOUNT)!)
        XCTAssertEqual(uri.uriString, BEGIN_TX_ASSET_AMOUNT)
    }
    
    public func testBuildURI_asset_amount_multipleTimes() throws {
        let uri = try NeoURI()
            .to(RECIPIENT)
            .token("gas")
            .token("neo")
            .amount(90)
            .amount(AMOUNT)
            .buildURI()
        
        XCTAssertEqual(uri.uri, URL(string: BEGIN_TX_ASSET_AMOUNT)!)
        XCTAssertEqual(uri.uriString, BEGIN_TX_ASSET_AMOUNT)
    }
    
    public func testBuildTransfer() async throws {
        _ = mockUrlSession.invokeFunctions(["balanceOf": JSON.from("invokefunction_balanceOf_1000000"),
                                            "decimals": JSON.from("invokefunction_decimals_nep17")])
        
        let expectedScript = try ScriptBuilder()
            .contractCall(NeoToken.SCRIPT_HASH, method: "transfer", params: [.hash160(SENDER), .hash160(RECIPIENT), .integer(100), .any(nil)])
            .toArray()
        
        let b = try await NeoURI()
            .neoSwift(neoSwift)
            .token(NeoToken.SCRIPT_HASH)
            .to(RECIPIENT)
            .amount(AMOUNT)
            .buildTransferFrom(SENDER_ACCOUNT)
        
        XCTAssertEqual(b.script, expectedScript)
    }
    
    public func testBuildTransfer_noNeoSwift() async throws {
        do {
            _ = try await NeoURI()
                .to(RECIPIENT)
                .amount(AMOUNT)
                .buildTransferFrom(SENDER_ACCOUNT)
            XCTFail("No exception.")
        } catch NeoSwiftError.illegalState(let message) {
            XCTAssertEqual(message, "NeoSwift instance is not set.")
        }
    }

    public func testBuildTransfer_noAddress() async throws {
        do {
            _ = try await NeoURI(neoSwift)
                .token(NeoToken.SCRIPT_HASH)
                .amount(AMOUNT)
                .buildTransferFrom(SENDER_ACCOUNT)
            XCTFail("No exception.")
        } catch NeoSwiftError.illegalState(let message) {
            XCTAssertEqual(message, "Recipient is not set.")
        }
    }
    
    public func testBuildTransfer_noAmount() async throws {
        do {
            _ = try await NeoURI(neoSwift)
                .token(NeoToken.SCRIPT_HASH)
                .to(RECIPIENT)
                .buildTransferFrom(SENDER_ACCOUNT)
            XCTFail("No exception.")
        } catch NeoSwiftError.illegalState(let message) {
            XCTAssertEqual(message, "Amount is not set.")
        }
    }
    
    public func testBuildTransfer_noToken() async throws {
        do {
            _ = try await NeoURI(neoSwift)
                .amount(AMOUNT)
                .to(RECIPIENT)
                .buildTransferFrom(SENDER_ACCOUNT)
            XCTFail("No exception.")
        } catch NeoSwiftError.illegalState(let message) {
            XCTAssertEqual(message, "Token is not set.")
        }
    }
    
    public func testBuildTransfer_nonNativeAsset() async throws {
        _ = mockUrlSession.invokeFunctions(["balanceOf": JSON.from("invokefunction_balanceOf_1000000"),
                                            "decimals": JSON.from("invokefunction_decimals_nep17")])
        
        do {
            _ = try await NeoURI(neoSwift)
                .token("b1e8f1ce80c81dc125e7d0e75e5ce3f7f4d4d36c")
                .to(RECIPIENT)
                .amount(AMOUNT)
                .buildTransferFrom(SENDER_ACCOUNT)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    public func testBuildTransfer_nonNativeAsset_invalidAmountDecimals() async throws {
        _ = mockUrlSession.invokeFunctions(["decimals": JSON.from("invokefunction_decimals_nep17")])
        
        do {
            _ = try await NeoURI(neoSwift)
                .token("b1e8f1ce80c81dc125e7d0e75e5ce3f7f4d4d36c")
                .to(RECIPIENT)
                .amount(0.001)
                .buildTransferFrom(SENDER_ACCOUNT)
        } catch NeoSwiftError.illegalArgument(let message) {
            XCTAssert(message!.contains("does not support more than 2 decimal places."))
        }
    }
    
    public func testBuildTransfer_nonNativeAsset_badDecimalReturn() async throws {
        _ = mockUrlSession.invokeFunctions(["decimals": JSON.from("invokefunction_decimals_nep17_badFormat")])
        
        do {
            _ = try await NeoURI(neoSwift)
                .token("b1e8f1ce80c81dc125e7d0e75e5ce3f7f4d4d36c")
                .to(RECIPIENT)
                .amount(AMOUNT)
                .buildTransferFrom(SENDER_ACCOUNT)
        } catch let error as ContractError {
            switch error {
            case .unexpectedReturnType: XCTAssertEqual(error.localizedDescription, "Got stack item of type Boolean but expected Integer.")
            default: XCTFail("Incorrect exception.")
            }
            
        }
    }
    
}
    
