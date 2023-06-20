
import Combine
import XCTest
@testable import NeoSwift

class TransactionBuilderTests: XCTestCase {
    
    let NEO_TOKEN_SCRIPT_HASH = try! Hash160(neoTokenHash)
    let GAS_TOKEN_SCRIPT_HASH = try! Hash160(gasTokenHash)
    let NEP17_TRANSFER = "transfer"
    lazy var SCRIPT_INVOKEFUNCTION_NEO_SYMBOL = { try! ScriptBuilder().contractCall(self.NEO_TOKEN_SCRIPT_HASH, method: "symbol", params: []).toArray().noPrefixHex }()
    lazy var SCRIPT_INVOKEFUNCTION_NEO_SYMBOL_BYTES = { self.SCRIPT_INVOKEFUNCTION_NEO_SYMBOL.bytesFromHex }()
    
    var account1: Account!
    var account2: Account!
    var recipient: Hash160!
    var mockUrlSession: MockURLSession!
    var neoSwift: NeoSwift!

    override func setUp() {
        super.setUp()
        mockUrlSession = MockURLSession()
        neoSwift = .init(config: .init(networkMagic: 769), neoSwiftService: HttpService(url: URL(string: "http://127.0.0.1")!, urlSession: mockUrlSession))
        account1 = try! .init(keyPair: .create(privateKey: "e6e919577dd7b8e97805151c05ae07ff4f752654d6d8797597aca989c02c4cb3".bytesFromHex))
        account2 = try! .init(keyPair: .create(privateKey: "b4b2b579cac270125259f08a5f414e9235817e7637b9a66cfeb3b77d90c8e7f9".bytesFromHex))
        recipient = try! .init("969a77db482f74ce27105f760efa139223431394")
    }
    
    public func testBuildTransactionWithCorrectNonce() async {
        let invokeJson = JSON.from("invokescript_necessary_mock")
        let networkFeeJson = JSON.from("calculatenetworkfee")
        _ = mockUrlSession.data(["invokescript": invokeJson, "calculatenetworkfee": networkFeeJson])
        
        var nonce = Int.random(in: 0..<(2.toPowerOf(32)))
        let transactionBuilder = try! TransactionBuilder(neoSwift)
            .validUntilBlock(1).script([1, 2, 3])
            .signers([AccountSigner.calledByEntry(account1)])
        
        var transaction = try! await transactionBuilder.nonce(nonce).getUnsignedTransaction()
        XCTAssertEqual(transaction.nonce, nonce)
        
        nonce = 0
        transaction = try! await transactionBuilder.nonce(nonce).getUnsignedTransaction()
        XCTAssertEqual(transaction.nonce, nonce)
        
        nonce = 2.toPowerOf(32) - 1
        transaction = try! await transactionBuilder.nonce(nonce).getUnsignedTransaction()
        XCTAssertEqual(transaction.nonce, nonce)
        
        nonce = (-1).toUnsigned
        transaction = try! await transactionBuilder.nonce(nonce).getUnsignedTransaction()
        XCTAssertEqual(transaction.nonce, nonce)
    }
    
    public func testFailBuildingTransactionWithIncorrectNonce() {
        let transactionBuilder = try! TransactionBuilder(neoSwift)
            .validUntilBlock(1).script([1, 2, 3])
            .signers([AccountSigner.calledByEntry(account1)])
        XCTAssertThrowsError(try transactionBuilder.nonce((-1).toUnsigned + 1)) { error in
            XCTAssertEqual(error.localizedDescription, "The value of the transaction nonce must be in the interval [0, 2^32].")
        }
        XCTAssertThrowsError(try transactionBuilder.nonce(2.toPowerOf(32)))
        XCTAssertThrowsError(try transactionBuilder.nonce(-1))
    }
    
    public func testFailBuildingTransactionWithInvalidBlockNumber() {
        XCTAssertThrowsError(
            try TransactionBuilder(neoSwift).validUntilBlock(-1)
                .script([1, 2, 3]).signers([AccountSigner.calledByEntry(account1)])
        ) { error in
            XCTAssert(error.localizedDescription.contains("cannot be less than zero or more than 2^32."))
        }
        XCTAssertThrowsError(
            try TransactionBuilder(neoSwift).validUntilBlock(2.toPowerOf(32))
                .script([1, 2, 3]).signers([AccountSigner.calledByEntry(account1)])
        ) { error in
            XCTAssert(error.localizedDescription.contains("cannot be less than zero or more than 2^32."))
        }
    }
    
    public func testAutomaticallySetNonce() async {
        let blockCountJson = JSON.from("getblockcount_1000")
        let invokeJson = JSON.from("invokescript_necessary_mock")
        let networkFeeJson = JSON.from("calculatenetworkfee")
        _ = mockUrlSession.data(["invokescript": invokeJson, "calculatenetworkfee": networkFeeJson, "getblockcount": blockCountJson])
        
        let tx = try! await TransactionBuilder(neoSwift)
            .script([1, 2, 3]).signers([AccountSigner.calledByEntry(account1)])
            .getUnsignedTransaction()
        XCTAssert(tx.nonce < 2.toPowerOf(32) && tx.nonce > 0)
    }
    
    public func testFailBuildingTxWithoutAnySigner() async {
        do {
            _ = try await TransactionBuilder(neoSwift).validUntilBlock(100)
                .script([1, 2, 3]).getUnsignedTransaction()
            XCTFail("No exception")
        } catch {
            XCTAssert(error.localizedDescription.contains("Cannot create a transaction without signers."))
        }
        let builder = TransactionBuilder(neoSwift)
        XCTAssertThrowsError(try builder.signers(AccountSigner.global(account1), AccountSigner.calledByEntry(account1))) { error in
            XCTAssert(error.localizedDescription.contains("concerning the same account"))
        }
    }
    
    public func testOverrideSigner() {
        let builder = TransactionBuilder(neoSwift)
        _ = try! builder.signers(AccountSigner.global(account1))
        XCTAssertEqual(builder.signers, try! [AccountSigner.global(account1)])
        
        _ = try! builder.signers(AccountSigner.global(account2))
        XCTAssertEqual(builder.signers, try! [AccountSigner.global(account2)])
    }
    
    public func testAttributesHighPriority() async {
        let invokeJson = JSON.from("invokescript_symbol_neo")
        let networkFeeJson = JSON.from("calculatenetworkfee")
        let committeeJson = JSON.from("getcommittee")
        let blockCountJson = JSON.from("getblockcount_1000")
        _ = mockUrlSession.data(["invokescript": invokeJson, "calculatenetworkfee": networkFeeJson, "getcommittee": committeeJson, "getblockcount": blockCountJson])
        
        let tx = try! await TransactionBuilder(neoSwift).script(SCRIPT_INVOKEFUNCTION_NEO_SYMBOL_BYTES)
            .attributes(.highPriority).signers(AccountSigner.none(account1)).getUnsignedTransaction()
        XCTAssertEqual(tx.attributes, [.highPriority])
    }
    
    public func testAttributesHighPriorityCommittee() async {
        let invokeJson = JSON.from("invokescript_symbol_neo")
        let networkFeeJson = JSON.from("calculatenetworkfee")
        let committeeJson = JSON.from("getcommittee")
        let blockCountJson = JSON.from("getblockcount_1000")
        _ = mockUrlSession.data(["invokescript": invokeJson, "calculatenetworkfee": networkFeeJson, "getcommittee": committeeJson, "getblockcount": blockCountJson])
        
        let multiSigAccount = try! Account.createMultiSigAccount([account2.keyPair!.publicKey, account1.keyPair!.publicKey], 1)
        let tx = try! await TransactionBuilder(neoSwift).script(SCRIPT_INVOKEFUNCTION_NEO_SYMBOL_BYTES)
            .attributes(.highPriority).signers(AccountSigner.none(multiSigAccount)).getUnsignedTransaction()
        XCTAssertEqual(tx.attributes, [.highPriority])
    }
    
    public func testAttributesHighPriorityNotCommitteeMember() async {
        let committeeJson = JSON.from("getcommittee")
        let blockCountJson = JSON.from("getblockcount_1000")
        _ = mockUrlSession.data(["getcommittee": committeeJson, "getblockcount": blockCountJson])
        
        let builder = try! TransactionBuilder(neoSwift).script(SCRIPT_INVOKEFUNCTION_NEO_SYMBOL_BYTES)
            .attributes(.highPriority).signers(AccountSigner.none(account2))
            
        do {
            _ = try await builder.getUnsignedTransaction()
            XCTFail("No exception")
        } catch {
            XCTAssert(error.localizedDescription.contains("Only committee members can send transactions with high priority."))
        }
    }
    
    public func testAttributesHighPriorityOnlyAddedOnce() async {
        let invokeJson = JSON.from("invokescript_symbol_neo")
        let networkFeeJson = JSON.from("calculatenetworkfee")
        let committeeJson = JSON.from("getcommittee")
        let blockCountJson = JSON.from("getblockcount_1000")
        _ = mockUrlSession.data(["invokescript": invokeJson, "calculatenetworkfee": networkFeeJson, "getcommittee": committeeJson, "getblockcount": blockCountJson])
        
        let tx = try! await TransactionBuilder(neoSwift).script(SCRIPT_INVOKEFUNCTION_NEO_SYMBOL_BYTES)
            .attributes(.highPriority).attributes(.highPriority)
            .signers(AccountSigner.none(account1)).getUnsignedTransaction()
        XCTAssertEqual(tx.attributes, [.highPriority])
    }
    
    public func testFailAddingMoreThanMaxAttributesToTx_justAttributes() {
        let attrs: [TransactionAttribute] = (0...NeoConstants.MAX_TRANSACTION_ATTRIBUTES).map { _ in .highPriority }
        XCTAssertThrowsError(try TransactionBuilder(neoSwift).attributes(attrs)) { error in
            XCTAssertEqual(error.localizedDescription, "A transaction cannot have more than \(NeoConstants.MAX_TRANSACTION_ATTRIBUTES) attributes (including signers).")
        }
    }
    
    public func testFailAddingMoreThanMaxAttributesToTx_attributesAndSigners() {
        let builder = TransactionBuilder(neoSwift)
        _ = try! builder.signers(AccountSigner.calledByEntry(.create()), AccountSigner.calledByEntry(.create()),
                             AccountSigner.calledByEntry(.create()))
        let attrs: [TransactionAttribute] = (0...NeoConstants.MAX_TRANSACTION_ATTRIBUTES - 3).map { _ in .highPriority }
        XCTAssertThrowsError(try builder.attributes(attrs)) { error in
            XCTAssertEqual(error.localizedDescription, "A transaction cannot have more than \(NeoConstants.MAX_TRANSACTION_ATTRIBUTES) attributes (including signers).")
        }
    }
    
    public func testFailAddingMoreThanMaxAttributesToTx_signers() {
        let builder = try! TransactionBuilder(neoSwift).attributes(.highPriority)
        let signers: [AccountSigner] = (0..<NeoConstants.MAX_TRANSACTION_ATTRIBUTES).map { _ in try! .calledByEntry(.create()) }
        XCTAssertThrowsError(try builder.signers(signers)) { error in
            XCTAssertEqual(error.localizedDescription, "A transaction cannot have more than \(NeoConstants.MAX_TRANSACTION_ATTRIBUTES) attributes (including signers).")
        }
    }
    
    public func testAutomaticSettingOfValidUntilBlockVariable() async {
        let invokeJson = JSON.from("invokescript_symbol_neo")
        let networkFeeJson = JSON.from("calculatenetworkfee")
        let blockCountJson = JSON.from("getblockcount_1000")
        _ = mockUrlSession.data(["invokescript": invokeJson, "calculatenetworkfee": networkFeeJson, "getblockcount": blockCountJson])
        
        let tx = try! await TransactionBuilder(neoSwift).script(SCRIPT_INVOKEFUNCTION_NEO_SYMBOL_BYTES)
            .signers(AccountSigner.none(.create())).getUnsignedTransaction()
        XCTAssertEqual(tx.validUntilBlock, neoSwift.maxValidUntilBlockIncrement + 999)
    }
    
    public func testAutomaticSettingOfSystemFeeAndNetworkFee() async {
        let invokeJson = JSON.from("invokescript_symbol_neo")
        let networkFeeJson = JSON.from("calculatenetworkfee")
        _ = mockUrlSession.data(["invokescript": invokeJson, "calculatenetworkfee": networkFeeJson])
        
        let tx = try! await TransactionBuilder(neoSwift).script(SCRIPT_INVOKEFUNCTION_NEO_SYMBOL_BYTES)
            .signers(AccountSigner.none(.create())).validUntilBlock(1000).getUnsignedTransaction()
        XCTAssertEqual(tx.systemFee, 984060)
        XCTAssertEqual(tx.networkFee, 1230610)
    }
    
    public func testFailTryingToSignTransactionWithAccountMissingAPrivateKey() async {
        let invokeJson = JSON.from("invokescript_symbol_neo")
        let networkFeeJson = JSON.from("calculatenetworkfee")
        _ = mockUrlSession.data(["invokescript": invokeJson, "calculatenetworkfee": networkFeeJson])
        
        let builder = try! TransactionBuilder(neoSwift)
            .script(SCRIPT_INVOKEFUNCTION_NEO_SYMBOL_BYTES)
            .signers(AccountSigner.none(Account.fromAddress(account1.address))).validUntilBlock(1000)
        do {
            _ = try await builder.sign()
            XCTFail("No exception")
        } catch {
            XCTAssertEqual(error.localizedDescription, "Cannot create transaction signature because account \(account1.address) does not hold a private key.")
        }
    }
    
    public func testFailAutomaticallySigningWithMultiSigAccountSigner() async {
        let invokeJson = JSON.from("invokescript_symbol_neo")
        let networkFeeJson = JSON.from("calculatenetworkfee")
        let blockCountJson = JSON.from("getblockcount_1000")
        _ = mockUrlSession.data(["invokescript": invokeJson, "calculatenetworkfee": networkFeeJson, "getblockcount": blockCountJson])
        
        let builder = try! TransactionBuilder(neoSwift).script(SCRIPT_INVOKEFUNCTION_NEO_SYMBOL_BYTES)
            .signers(AccountSigner.none(Account.createMultiSigAccount([account1.keyPair!.publicKey], 1)))
        do {
            _ = try await builder.sign()
            XCTFail("No exception")
        } catch {
            XCTAssertEqual(error.localizedDescription, "Transactions with multi-sig signers cannot be signed automatically.")
        }
    }
    
    public func testFailWithNoSigningAccount() async {
        let invokeJson = JSON.from("invokescript_symbol_neo")
        let blockCountJson = JSON.from("getblockcount_1000")
        _ = mockUrlSession.data(["invokescript": invokeJson, "getblockcount": blockCountJson])
        
        let builder = try! TransactionBuilder(neoSwift).script(SCRIPT_INVOKEFUNCTION_NEO_SYMBOL_BYTES)
            .signers(ContractSigner.calledByEntry(Account.create().getScriptHash()))
        do {
            _ = try await builder.sign()
            XCTFail("No exception")
        } catch {
            XCTAssert(error.localizedDescription.contains("transaction requires at least one signing account"))
        }
    }
    
    public func testFailSigningWithAccountWithoutECKeyPair() async {
        let invokeJson = JSON.from("invokescript_symbol_neo")
        let networkFeeJson = JSON.from("calculatenetworkfee")
        let blockCountJson = JSON.from("getblockcount_1000")
        _ = mockUrlSession.data(["invokescript": invokeJson, "calculatenetworkfee": networkFeeJson, "getblockcount": blockCountJson])
        
        let accountWithoutKeyPair = try! Account.fromVerificationScript(account1.verificationScript!)
        let builder = try! TransactionBuilder(neoSwift).script(SCRIPT_INVOKEFUNCTION_NEO_SYMBOL_BYTES)
            .signers(AccountSigner.none(accountWithoutKeyPair))
        do {
            _ = try await builder.sign()
            XCTFail("No exception")
        } catch {
            XCTAssert(error.localizedDescription.contains("does not hold a private key."))
        }
    }
    
    public func testSignTransactionWithAdditionalSigners() async {
        let invokeJson = JSON.from("invokescript_symbol_neo")
        let networkFeeJson = JSON.from("calculatenetworkfee")
        _ = mockUrlSession.data(["invokescript": invokeJson, "calculatenetworkfee": networkFeeJson])
        
        let tx = try! await TransactionBuilder(neoSwift).script(SCRIPT_INVOKEFUNCTION_NEO_SYMBOL_BYTES)
            .signers(AccountSigner.calledByEntry(account1), AccountSigner.calledByEntry(account2))
            .validUntilBlock(1000).sign()
        
        XCTAssertEqual(tx.witnesses.count, 2)
        let signers = tx.witnesses.map { try! $0.verificationScript.getPublicKeys().first! }
        XCTAssert(signers.contains(account1.keyPair!.publicKey))        
        XCTAssert(signers.contains(account2.keyPair!.publicKey))
    }
    
    public func testFailSendingTransactionBecauseItDoesntContainTheRightNumberOfWitnesses() async {
        let invokeJson = JSON.from("invokescript_symbol_neo")
        let networkFeeJson = JSON.from("calculatenetworkfee")
        _ = mockUrlSession.data(["invokescript": invokeJson, "calculatenetworkfee": networkFeeJson])
        
        let tx = try! await TransactionBuilder(neoSwift).script(SCRIPT_INVOKEFUNCTION_NEO_SYMBOL_BYTES)
            .signers(AccountSigner.calledByEntry(.create())).validUntilBlock(1000).getUnsignedTransaction()
        do {
            _ = try await tx.send()
            XCTFail("No exception")
        } catch {
            XCTAssert(error.localizedDescription.contains("The transaction does not have the same number of signers and witnesses."))
        }
    }
    
    public func testContractWitness() async {
        let invokeJson = JSON.from("invokescript_symbol_neo")
        let networkFeeJson = JSON.from("calculatenetworkfee")
        _ = mockUrlSession.data(["invokescript": invokeJson, "calculatenetworkfee": networkFeeJson])
        
        let contracthash = try! Hash160("e87819d005b730645050f89073a4cd7bf5f6bd3c")
        let tx = try! await TransactionBuilder(neoSwift).script(SCRIPT_INVOKEFUNCTION_NEO_SYMBOL_BYTES)
            .signers(ContractSigner.global(contracthash, .string("iamgroot"), .integer(2)), AccountSigner.calledByEntry(.create()))
            .validUntilBlock(1000).sign()
        let invocationScript = try! ScriptBuilder().pushData("iamgroot").pushInteger(2).toArray()
        XCTAssert(tx.witnesses.contains(.init(invocationScript, [])))
    }
    
    public func testSendInvokeFunction() async {
        let invokeJson = JSON.from("invokescript_transfer_with_fixed_sysfee")
        let rawTransactionJson = JSON.from("sendrawtransaction")
        let networkFeeJson = JSON.from("calculatenetworkfee")
        let blockCountJson = JSON.from("getblockcount_1000")
        _ = mockUrlSession.data(["invokescript": invokeJson, "calculatenetworkfee": networkFeeJson,
                                 "getblockcount": blockCountJson, "sendrawtransaction": rawTransactionJson])
        
        let script = try! ScriptBuilder().contractCall(NEO_TOKEN_SCRIPT_HASH, method: NEP17_TRANSFER,
                                                  params: [.hash160(account1.scriptHash!),
                                                           .hash160(recipient), .integer(5),
                                                           .any(nil)]).toArray()
        
        let tx = try! await TransactionBuilder(neoSwift).script(script).signers(AccountSigner.none(account1)).sign()
        let response = try! await tx.send()
        
        XCTAssertNil(response.error)
        XCTAssertEqual(response.sendRawTransaction!.hash, try! Hash256("0x830816f0c801bcabf919dfa1a90d7b9a4f867482cb4d18d0631a5aa6daefab6a"))
    }
    
    public func testTransferNeoFromNormalAccount() async {
        let invokeJson = JSON.from("invokescript_transfer_with_fixed_sysfee")
        let networkFeeJson = JSON.from("calculatenetworkfee")
        _ = mockUrlSession.data(["invokescript": invokeJson, "calculatenetworkfee": networkFeeJson])
        
        let expectedVerificationScript = account1.verificationScript!.script
        let script = try! ScriptBuilder().contractCall(NEO_TOKEN_SCRIPT_HASH, method: NEP17_TRANSFER,
                                                  params: [.hash160(account1.getScriptHash()),
                                                           .hash160(recipient), .integer(5),
                                                           .any(nil)]).toArray()
        let tx = try! await TransactionBuilder(neoSwift).script(script)
            .signers(AccountSigner.none(account1)).validUntilBlock(100).sign()
        
        XCTAssertEqual(tx.script, script)
        XCTAssertEqual(tx.witnesses.count, 1)
        XCTAssertEqual(tx.witnesses.first?.verificationScript.script, expectedVerificationScript)
    }
    
    public func testExtendScript() {
        let script1 = try! ScriptBuilder().contractCall(NEO_TOKEN_SCRIPT_HASH, method: NEP17_TRANSFER,
                                                        params: [.hash160(account1.getScriptHash()),
                                                                 .hash160(recipient), .integer(11),
                                                                 .any(nil)]).toArray()
        let script2 = try! ScriptBuilder().contractCall(NEO_TOKEN_SCRIPT_HASH, method: NEP17_TRANSFER,
                                                        params: [.hash160(account1.getScriptHash()),
                                                                 .hash160(account2.getScriptHash()),
                                                                 .integer(22), .any(nil)]).toArray()
        let builder = TransactionBuilder(neoSwift).script(script1)
        XCTAssertEqual(builder.script, script1)
        
        _ = builder.extendScript(script2)
        XCTAssertEqual(builder.script, script1 + script2)
    }
    
    public func testInvokingWithParamsShouldProduceTheCorrectRequest() async {
        let invokeJson = JSON.from("invokefunction_transfer_neo")
        _ = mockUrlSession.data(["invokefunction": invokeJson])
        
        let invokeFunction = try! await neoSwift.invokeFunction(NEO_TOKEN_SCRIPT_HASH, NEP17_TRANSFER,
                                                     [.hash160(account1.getScriptHash()),
                                                      .hash160(recipient), .integer(5),
                                                      .any(nil)], []).send()
        XCTAssertEqual(invokeFunction.invocationResult!.script,
                       "CxUMFJQTQyOSE/oOdl8QJ850L0jbd5qWDBQGSl3MDxYsg0c9Aok46V+3dhMechTAHwwIdHJhbnNmZXIMFIOrBnmtVcBQoTrUP1k26nP16x72QWJ9W1I=")
    }
    
    public func testDoIfSenderCannotCoverFees() async {
        let invokeJson = JSON.from("invokescript_transfer_with_fixed_sysfee")
        let networkFeeJson = JSON.from("calculatenetworkfee")
        let functionJson = JSON.from("invokefunction_balanceOf_1000000")
        _ = mockUrlSession.data(["invokescript": invokeJson, "calculatenetworkfee": networkFeeJson, "invokefunction": functionJson])
        
        let netFee = 1230610
        let sysFee = 9999510
        var tested = false
        
        let script = try! ScriptBuilder().contractCall(GAS_TOKEN_SCRIPT_HASH, method: NEP17_TRANSFER,
                                                       params: [.hash160(account1.getScriptHash()),
                                                                .hash160(recipient),
                                                                .integer(2_000_000),
                                                                .any(nil)]).toArray()
        
        _ = try! await TransactionBuilder(neoSwift).script(script)
            .signers(AccountSigner.calledByEntry(account1))
            .validUntilBlock(2000000).doIfSenderCannotCoverFees({ fee, balance in
                XCTAssert(fee == netFee + sysFee)
                XCTAssert(balance == 1000000)
                tested = true
            }).getUnsignedTransaction()
        
        XCTAssert(tested)
    }
    
    public func testDoIfSenderCannotCoverFees_alreadySpecifiedASupplier() {
        let builder = try! TransactionBuilder(neoSwift).throwIfSenderCannotCoverFees(NeoSwiftError.illegalState())
        XCTAssertThrowsError(try builder.doIfSenderCannotCoverFees({ _, _ in })) { error in
            XCTAssert(error.localizedDescription.contains("Cannot handle a consumer for this case, since an exception"))
        }
    }
    
    public func testThrowIfSenderCannotCoverFees() async {
        let invokeJson = JSON.from("invokescript_transfer_with_fixed_sysfee")
        let networkFeeJson = JSON.from("calculatenetworkfee")
        let functionJson = JSON.from("invokefunction_balanceOf_1000000")
        _ = mockUrlSession.data(["invokescript": invokeJson, "calculatenetworkfee": networkFeeJson, "invokefunction": functionJson])
        
        let script = try! ScriptBuilder().contractCall(NEO_TOKEN_SCRIPT_HASH, method: NEP17_TRANSFER,
                                                  params: [.hash160(account1.getScriptHash()),
                                                           .hash160(recipient), .integer(5),
                                                           .any(nil)]).toArray()
        
        let transactionBuilder = try! TransactionBuilder(neoSwift).script(script).validUntilBlock(2000000)
            .signers(AccountSigner.calledByEntry(account1))
            .throwIfSenderCannotCoverFees(NeoSwiftError.illegalState("test throwIfSenderCannotCoverFees"))
        do {
            _ = try await transactionBuilder.getUnsignedTransaction()
            XCTFail("No exception")
        } catch {
            XCTAssertEqual(error.localizedDescription, "test throwIfSenderCannotCoverFees")
        }
    }
    
    public func testThrowIfSenderCannotCoverFees_alreadySpecifiedAConsumer() {
        let builder = try! TransactionBuilder(neoSwift).doIfSenderCannotCoverFees({ _, _ in })
        XCTAssertThrowsError(try builder.throwIfSenderCannotCoverFees(NeoSwiftError.illegalState())) { error in
            XCTAssert(error.localizedDescription.contains("Cannot handle a supplier for this case, since a consumer"))
        }
    }
    
    public func testInvokeScript() async {
        let invokeJson = JSON.from("invokescript_symbol_neo")
        _ = mockUrlSession.data(["invokescript": invokeJson])
                
        let response = try! await TransactionBuilder(neoSwift).script(SCRIPT_INVOKEFUNCTION_NEO_SYMBOL_BYTES).callInvokeScript()
        XCTAssertEqual(response.invocationResult?.stack.first?.string, "NEO")
    }
    
    public func testInvokeScriptWithoutSettingScript() async {
        let invokeJson = JSON.from("invokescript_symbol_neo")
        _ = mockUrlSession.data(["invokescript": invokeJson])

        do {
            _ = try await TransactionBuilder(neoSwift).callInvokeScript()
            XCTFail("No exception")
        } catch {
            XCTAssertEqual(error.localizedDescription, "Cannot make an 'invokescript' call without the script being configured.")
        }
    }
    
    public func testBuildWithoutSettingScript() async {
        do {
            _ = try await TransactionBuilder(neoSwift).getUnsignedTransaction()
            XCTFail("No exception")
        } catch {
            XCTAssertEqual(error.localizedDescription, "Cannot build a transaction without a script.")
        }
    }
    
    public func testBuildWithInvalidScript() async {
        let invokeJson = JSON.from("invokescript_invalidscript")
        let blockCountJson = JSON.from("getblockcount_1000")
        _ = mockUrlSession.data(["invokescript": invokeJson, "getblockcount": blockCountJson])
        
        let builder = try! TransactionBuilder(neoSwift)
            .script("0c0e4f7261636c65436f6e7472616374411af77b67".bytesFromHex)
            .signers(AccountSigner.calledByEntry(account1))
        
        do {
            _ = try await builder.getUnsignedTransaction()
            XCTFail("No exception")
        } catch {
            XCTAssert(error.localizedDescription.contains("Instruction out of bounds"))
        }
    }
    
    public func testBuildWithScript_vmFaults() async {
        let invokeJson = JSON.from("invokescript_exception")
        let blockCountJson = JSON.from("getblockcount_1000")
        _ = mockUrlSession.data(["invokescript": invokeJson, "getblockcount": blockCountJson])
        
        let builder = try! TransactionBuilder(neoSwift)
            .script("0c00120c1493ad1572".bytesFromHex)
            .signers(AccountSigner.calledByEntry(account1))
        
        do {
            _ = try await builder.getUnsignedTransaction()
            XCTFail("No exception")
        } catch {
            XCTAssertEqual(error.localizedDescription, "The vm exited due to the following exception: Value was either too large or too small for an Int32.")
        }
    }
    
    public func testGetUnsignedTransaction() async {
        let invokeJson = JSON.from("invokescript_symbol_neo")
        let blockCountJson = JSON.from("getblockcount_1000")
        let networkFeeJson = JSON.from("calculatenetworkfee")
        _ = mockUrlSession.data(["invokescript": invokeJson, "getblockcount": blockCountJson, "calculatenetworkfee": networkFeeJson])
        
        let tx = try! await TransactionBuilder(neoSwift)
            .script(SCRIPT_INVOKEFUNCTION_NEO_SYMBOL_BYTES)
            .signers(AccountSigner.calledByEntry(account1))
            .getUnsignedTransaction()
        
        XCTAssertEqual(tx.version, 0)
        XCTAssertEqual(tx.signers, try! [AccountSigner.calledByEntry(account1)])
        XCTAssert(tx.witnesses.isEmpty)
    }
    
    public func testVersion() async {
        let invokeJson = JSON.from("invokescript_symbol_neo")
        let blockCountJson = JSON.from("getblockcount_1000")
        let networkFeeJson = JSON.from("calculatenetworkfee")
        _ = mockUrlSession.data(["invokescript": invokeJson, "getblockcount": blockCountJson, "calculatenetworkfee": networkFeeJson])
        
        let tx = try! await TransactionBuilder(neoSwift)
            .version(1)
            .script(SCRIPT_INVOKEFUNCTION_NEO_SYMBOL_BYTES)
            .signers(AccountSigner.calledByEntry(account1))
            .getUnsignedTransaction()
        
        XCTAssertEqual(tx.version, 1)
    }
    
    public func testAdditionalNetworkFee() async {
        let invokeJson = JSON.from("invokescript_symbol_neo")
        let blockCountJson = JSON.from("getblockcount_1000")
        let networkFeeJson = JSON.from("calculatenetworkfee")
        _ = mockUrlSession.data(["invokescript": invokeJson, "getblockcount": blockCountJson, "calculatenetworkfee": networkFeeJson])
        
        let baseNetworkFee = 1230610
        
        let tx = try! await TransactionBuilder(neoSwift)
            .script(SCRIPT_INVOKEFUNCTION_NEO_SYMBOL_BYTES)
            .signers(AccountSigner.calledByEntry(.create()))
            .getUnsignedTransaction()
        XCTAssertEqual(tx.networkFee, baseNetworkFee)
        
        let tx2 = try! await TransactionBuilder(neoSwift)
            .script(SCRIPT_INVOKEFUNCTION_NEO_SYMBOL_BYTES)
            .signers(AccountSigner.none(.create()))
            .additionalNetworkFee(2000)
            .getUnsignedTransaction()
        XCTAssertEqual(tx2.networkFee, baseNetworkFee + 2000)
    }
    
    public func testAdditionalSystemFee() async {
        let invokeJson = JSON.from("invokescript_symbol_neo")
        let blockCountJson = JSON.from("getblockcount_1000")
        let networkFeeJson = JSON.from("calculatenetworkfee")
        _ = mockUrlSession.data(["invokescript": invokeJson, "getblockcount": blockCountJson, "calculatenetworkfee": networkFeeJson])
        
        let baseSystemFee = 984060
        
        let tx = try! await TransactionBuilder(neoSwift)
            .script(SCRIPT_INVOKEFUNCTION_NEO_SYMBOL_BYTES)
            .signers(AccountSigner.calledByEntry(.create()))
            .getUnsignedTransaction()
        XCTAssertEqual(tx.systemFee, baseSystemFee)
        
        let tx2 = try! await TransactionBuilder(neoSwift)
            .script(SCRIPT_INVOKEFUNCTION_NEO_SYMBOL_BYTES)
            .signers(AccountSigner.none(.create()))
            .additionalSystemFee(3000)
            .getUnsignedTransaction()
        XCTAssertEqual(tx2.systemFee, baseSystemFee + 3000)
    }
    
    public func testSetFirstSigner() {
        let s1 = try! AccountSigner.global(account1)
        let s2 = try! AccountSigner.calledByEntry(account2)
        
        let builder = try! TransactionBuilder(neoSwift)
            .script(SCRIPT_INVOKEFUNCTION_NEO_SYMBOL_BYTES)
            .signers(s1, s2)
        XCTAssertEqual(builder.signers, [s1, s2])
        
        _ = try! builder.firstSigner(s2.signerHash)
        XCTAssertEqual(builder.signers, [s2, s1])
        
        _ = try! builder.firstSigner(account1)
        XCTAssertEqual(builder.signers, [s1, s2])
    }
    
    public func testSetFirstSigner_feeOnlyPresent() {
        let s1 = try! AccountSigner.none(account1)
        let s2 = try! AccountSigner.calledByEntry(account2)
        
        let builder = try! TransactionBuilder(neoSwift)
            .script(SCRIPT_INVOKEFUNCTION_NEO_SYMBOL_BYTES)
            .signers(s1, s2)
        XCTAssertEqual(builder.signers, [s1, s2])
        XCTAssertThrowsError(try _ = builder.firstSigner(s2.signerHash)) { error in
            XCTAssert(error.localizedDescription.contains("contains a signer with fee-only witness scope"))
        }
    }
    
    public func testSetFirstSigner_notPresent() {
        let s1 = try! AccountSigner.global(account1)
        
        let builder = try! TransactionBuilder(neoSwift)
            .script(SCRIPT_INVOKEFUNCTION_NEO_SYMBOL_BYTES)
            .signers(s1)
        XCTAssertEqual(builder.signers, [s1])
        XCTAssertThrowsError(try _ = builder.firstSigner(account2.scriptHash!)) { error in
            XCTAssert(error.localizedDescription.contains("Could not find a signer with script hash"))
        }
    }
    
    public func testTrackingTransactionShouldReturnCorrectBlock() {
        let invokeJson = JSON.from("invokescript_transfer_with_fixed_sysfee")
        let rawTransactionJson = JSON.from("sendrawtransaction")
        let networkFeeJson = JSON.from("calculatenetworkfee")
        let blockCountJson = JSON.from("getblockcount_1000")
        _ = mockUrlSession.data(["invokescript": invokeJson, "calculatenetworkfee": networkFeeJson,
                                 "getblockcount": blockCountJson, "sendrawtransaction": rawTransactionJson])
        
        let neoSwift = MockNeoSwift(config: .init(networkMagic: 769), neoSwiftService: HttpService(url: URL(string: "http://127.0.0.1")!, urlSession: mockUrlSession))
        neoSwift.overrideCatchUpToLatestAndSubscribeToNewBlocksPublisher = true
        
        let script = try! ScriptBuilder().contractCall(NEO_TOKEN_SCRIPT_HASH, method: NEP17_TRANSFER,
                                                       params: [.hash160(account1.scriptHash!),
                                                                .hash160(recipient), .integer(5),
                                                                .any(nil)]).toArray()
        
        let expectation = XCTestExpectation()
        let blockNum = Counter()

        Task {
            let tx = try! await TransactionBuilder(neoSwift)
                .script(script).nonce(0)
                .signers(AccountSigner.calledByEntry(account1))
                .sign()
            
            var cancellables: Set<AnyCancellable> = []
            
            _ = try! await tx.send()
            _ = try! await tx.track().sink(receiveCompletion: { completion in
                switch completion {
                case .finished: expectation.fulfill()
                case .failure(let error): XCTFail(error.localizedDescription)
                }
            }, receiveValue: blockNum.set).store(in: &cancellables)
        }
        _ = XCTWaiter.wait(for: [expectation], timeout: 100)
        XCTAssertEqual(blockNum.value, 1002)
    }
    
    public func testTrackingTransaction_txNotSent() async {
        let invokeJson = JSON.from("invokescript_transfer_with_fixed_sysfee")
        let networkFeeJson = JSON.from("calculatenetworkfee")
        let blockCountJson = JSON.from("getblockcount_1000")
        _ = mockUrlSession.data(["invokescript": invokeJson, "calculatenetworkfee": networkFeeJson, "getblockcount": blockCountJson])
        
        let script = try! ScriptBuilder().contractCall(NEO_TOKEN_SCRIPT_HASH, method: NEP17_TRANSFER,
                                                  params: [.hash160(account1.scriptHash!),
                                                           .hash160(recipient), .integer(5),
                                                           .any(nil)]).toArray()
        
        let tx = try! await TransactionBuilder(neoSwift)
            .script(script).nonce(0)
            .signers(AccountSigner.calledByEntry(account1))
            .sign()
        
        do {
            _ = try await tx.track()
            XCTFail("No exception")
        } catch {
            XCTAssertEqual(error.localizedDescription, "Cannot subscribe before transaction has been sent.")
        }
    }
    
    public func testGetAppliationLog() async {
        let functionJson = JSON.from("invokefunction_balanceOf_1000000")
        let invokeJson = JSON.from("invokescript_transfer")
        let rawTransactionJson = JSON.from("sendrawtransaction")
        let networkFeeJson = JSON.from("calculatenetworkfee")
        let blockCountJson = JSON.from("getblockcount_1000")
        let applicationLogJson = JSON.from("getapplicationlog")
        _ = mockUrlSession.data(["invokescript": invokeJson, "calculatenetworkfee": networkFeeJson,
                                 "invokefunciton": functionJson, "getblockcount": blockCountJson,
                                 "sendrawtransaction": rawTransactionJson, "getapplicationlog": applicationLogJson])
        let script = try! ScriptBuilder().contractCall(NEO_TOKEN_SCRIPT_HASH, method: NEP17_TRANSFER,
                                                  params: [.hash160(account1.scriptHash!),
                                                           .hash160(account1.scriptHash!),
                                                           .integer(1), .any(nil)]).toArray()
        let tx = try! await TransactionBuilder(neoSwift)
            .script(script)
            .signers(AccountSigner.calledByEntry(account1))
            .sign()
        
        _ = try! await tx.send()
        let applicationLog = try! await tx.getApplicationLog()
        XCTAssertEqual(applicationLog.transactionId, try! Hash256("0xeb52f99ae5cf923d8905bdd91c4160e2207d20c0cb42f8062f31c6743770e4d1"))
    }
    
    public func testGetApplicationLog_txNotSent() async {
        let functionJson = JSON.from("invokefunction_balanceOf_1000000")
        let invokeJson = JSON.from("invokescript_transfer")
        let networkFeeJson = JSON.from("calculatenetworkfee")
        let blockCountJson = JSON.from("getblockcount_1000")
        _ = mockUrlSession.data(["invokescript": invokeJson, "calculatenetworkfee": networkFeeJson,
                                 "invokefunciton": functionJson, "getblockcount": blockCountJson])
        
        let script = try! ScriptBuilder().contractCall(NEO_TOKEN_SCRIPT_HASH, method: NEP17_TRANSFER,
                                                  params: [.hash160(account1.scriptHash!),
                                                           .hash160(account1.scriptHash!),
                                                           .integer(1), .any(nil)]).toArray()
        
        let tx = try! await TransactionBuilder(neoSwift)
            .script(script)
            .signers(AccountSigner.calledByEntry(account1))
            .sign()
        
        do {
            _ = try await tx.getApplicationLog()
            XCTFail("No exception")
        } catch {
            XCTAssertEqual(error.localizedDescription, "Cannot get the application log before transaction has been sent.")
        }
    }
    
    public func testGetApplicationLog_notExisting() async{
        let functionJson = JSON.from("invokefunction_balanceOf_1000000")
        let invokeJson = JSON.from("invokescript_transfer")
        let rawTransactionJson = JSON.from("sendrawtransaction")
        let networkFeeJson = JSON.from("calculatenetworkfee")
        let blockCountJson = JSON.from("getblockcount_1000")
        let applicationLogJson = JSON.from("getapplicationlog_unknowntx")
        _ = mockUrlSession.data(["invokescript": invokeJson, "calculatenetworkfee": networkFeeJson,
                                 "invokefunciton": functionJson, "getblockcount": blockCountJson,
                                 "sendrawtransaction": rawTransactionJson, "getapplicationlog": applicationLogJson])
        
        let script = try! ScriptBuilder().contractCall(NEO_TOKEN_SCRIPT_HASH, method: NEP17_TRANSFER,
                                                  params: [.hash160(account1.scriptHash!),
                                                           .hash160(account1.scriptHash!),
                                                           .integer(1), .any(nil)]).toArray()
        let tx = try! await TransactionBuilder(neoSwift)
            .script(script)
            .signers(AccountSigner.calledByEntry(account1))
            .sign()
        
        _ = try! await tx.send()
        
        do {
            _ = try await tx.getApplicationLog()
            XCTFail("No exception")
        } catch {}
    }
    
    public func testTransmissionOnFault() async {
        let invokeJson = JSON.from("invokescript_fault")
        let networkFeeJson = JSON.from("calculatenetworkfee")
        let blockCountJson = JSON.from("getblockcount_1000")
        _ = mockUrlSession.data(["invokescript": invokeJson, "calculatenetworkfee": networkFeeJson, "getblockcount": blockCountJson])
        
        neoSwift.allowTransmissionOnFault()
        XCTAssert(neoSwift.config.allowsTransmissionOnFault)
        
        let failingScript = try! ScriptBuilder().contractCall(.init(neoTokenHash), method: "balanceOf", params: []).toArray().noPrefixHex
        
        let account = try! Account.fromAddress(defaultAccountAddress)
        let builder = try! TransactionBuilder(neoSwift).script(failingScript.bytesFromHex).signers(AccountSigner.none(account))
        
        let result = try! await builder.callInvokeScript().invocationResult!
        XCTAssert(result.hasStateFault)
        
        let gasConsumed = Int(result.gasConsumed)!
        let tx = try! await builder.getUnsignedTransaction()
        XCTAssertEqual(tx.systemFee, gasConsumed)
        
        neoSwift.preventTransmissionOnFault()
        XCTAssertFalse(neoSwift.config.allowsTransmissionOnFault)
    }
    
    public func testPreventTransmissionOnFault() async {
        let invokeJson = JSON.from("invokescript_fault")
        let blockCountJson = JSON.from("getblockcount_1000")
        _ = mockUrlSession.data(["invokescript": invokeJson, "getblockcount": blockCountJson])
        
        XCTAssertFalse(neoSwift.config.allowsTransmissionOnFault)
        
        let failingScript = try! ScriptBuilder().contractCall(.init(neoTokenHash), method: "balanceOf", params: []).toArray().noPrefixHex
        
        let account = try! Account.fromAddress(defaultAccountAddress)
        let builder = try! TransactionBuilder(neoSwift).script(failingScript.bytesFromHex).signers(AccountSigner.none(account))
        
        let result = try! await builder.callInvokeScript().invocationResult!
        XCTAssert(result.hasStateFault)
        
        do {
            _ = try await builder.getUnsignedTransaction()
            XCTFail("No exception")
        } catch {
            XCTAssert(error.localizedDescription.contains("The vm exited due to the following exception: "))
        }
    }
    
}
