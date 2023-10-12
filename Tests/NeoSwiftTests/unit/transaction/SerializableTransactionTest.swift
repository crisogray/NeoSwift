
import XCTest
@testable import NeoSwift

class SerializableTransactionTest: XCTestCase {
    
    private var account1 = try! Hash160.fromAddress("NZNos2WqTbu5oCgyfss9kUJgBXJqhuYAaj")
    private var account2 = try! Hash160.fromAddress("NLnyLtep7jwyq1qhNPkwXbJpurC4jUT8ke")
    private var account3 = try! Hash160.fromAddress("NWcx4EfYdfqn5jNjDz8AHE6hWtWdUGDdmy")
    
    private let a4 = try! Account.fromWIF("L3pLaHgKBf7ENNKPH1jfPM8FC9QhPCqwFyWguQ8CDB1G66p78wd6")
    private let a5 = try! Account.fromWIF("KypPpzztxDj26DiCmTkbwQJT2TrgaNtw5Wp3K2nYiMvWu99Xv3rP")
    private let a6 = try! Account.fromWIF("KxjePibw7BEdaS8diPeqgozFWevVx6tLE226jYU6tFF1HSYQ5z5u")
    
    let neoSwift = NeoSwift.build(HttpService(url: URL(string: "http://localhost:40332")!))

    public func testSerializeWithoutAttributesAndWitnesses() {
        let signers = try! [AccountSigner.calledByEntry(account1)]
        let tx = NeoTransaction(neoSwift: neoSwift, version: 0, nonce: 0x01020304,
                                         validUntilBlock: 0x01020304, signers: signers,
                                         systemFee: 10.toPowerOf(8), networkFee: 1, attributes: [],
                                         script: [OpCode.push1.opcode], witnesses: [])
        let expected = ("00" // version
                        + "04030201"  // nonce
                        + "00e1f50500000000"  // system fee (1 GAS)
                        + "0100000000000000"  // network fee (1 GAS fraction)
                        + "04030201"  // valid until block
                        + "01" + "93ad1572a4b35c4b925483ce1701b78742dc460f" + "01"
                        // one calledByEntry signer with scope
                        + "00"
                        + "01" + OpCode.push1.string // 1-byte script with PUSH1 OpCode
                        + "00").bytesFromHex
        XCTAssertEqual(expected, tx.toArray())
    }
    
    public func testSerializeWithAttributesAndWitnesses() {
        let signers = try! [AccountSigner.global(account1), AccountSigner.calledByEntry(account2)]
        let witnesses = [Witness([0], [0])]
        let tx = NeoTransaction(neoSwift: neoSwift, version: 0, nonce: 0x01020304,
                                         validUntilBlock: 0x01020304, signers: signers,
                                         systemFee: 10.toPowerOf(8), networkFee: 1, attributes: [],
                                         script: [OpCode.push1.opcode], witnesses: witnesses)
        let expected = ("00" // version
                        + "04030201"  // nonce
                        + "00e1f50500000000"  // system fee (1 GAS)
                        + "0100000000000000"  // network fee (1 GAS fraction)
                        + "04030201"  // valid until block
                        + "02"  // 2 signers
                        + "93ad1572a4b35c4b925483ce1701b78742dc460f" + "80" // global signer
                        + "09a55874c2da4b86e5d49ff530a1b153eb12c7d6" + "01" // calledByEntry signer
                        + "00"
                        + "01" + OpCode.push1.string // 1-byte script with PUSH1 OpCode
                        + "01" // 1 witness
                        + "01000100" // witness
                ).bytesFromHex
        XCTAssertEqual(expected, tx.toArray())
    }
    
    public func testDeserialize() {
        let data = ("00" // version
                    + "62bdaa0e"  // nonce
                    + "c272890000000000"  // system fee
                    + "a65a130000000000"  // network fee
                    + "99232000"  // valid until block
                    + "01" + "941343239213fa0e765f1027ce742f48db779a96" + "01"
                    // one called by entry signer
                    + "01" + "01" // one attribute - high priority
                    + "01" + OpCode.push1.string  // 1-byte script with PUSH1 OpCode
                    + "01" // 1 witness
                    + "01000100").bytesFromHex
        let transaction = try! NeoTransaction.from(data)
        XCTAssertEqual(transaction.version, 0)
        XCTAssertEqual(transaction.nonce, 246070626)
        XCTAssertEqual(transaction.sender, try! Hash160("969a77db482f74ce27105f760efa139223431394"))
        XCTAssertEqual(transaction.systemFee, 9007810)
        XCTAssertEqual(transaction.networkFee, 1268390)
        XCTAssertEqual(transaction.validUntilBlock, 2106265)
        XCTAssertEqual(transaction.attributes, [.highPriority])
        XCTAssertEqual(transaction.signers.count, 1)
        XCTAssertEqual(transaction.signers[0].signerHash, try! Hash160("969a77db482f74ce27105f760efa139223431394"))
        XCTAssert(transaction.signers[0].scopes.contains(.calledByEntry))
        XCTAssertEqual(transaction.script, [OpCode.push1.opcode])
        XCTAssertEqual(transaction.witnesses, [.init([0], [0])])
        
        XCTAssertNil(transaction.neoSwift)
        transaction.neoSwift = .build(HttpService(url: URL(string: "http://localhost:40332")!))
        XCTAssertNotNil(transaction.neoSwift)
    }
    
    public func testDeserializeWithoutWitness() {
        let data = ("00" // version
                    + "62bdaa0e"  // nonce
                    + "c272890000000000"  // system fee
                    + "a65a130000000000"  // network fee
                    + "99232000"  // valid until block
                    + "01" + "941343239213fa0e765f1027ce742f48db779a96" + "01"
                    // one called by entry signer
                    + "01" + "01" // one attribute - high priority
                    + "01" + OpCode.push1.string  // 1-byte script with PUSH1 OpCode
            ).bytesFromHex
        let transaction = try! NeoTransaction.from(data)
        XCTAssertEqual(transaction.version, 0)
        XCTAssertEqual(transaction.nonce, 246070626)
        XCTAssertEqual(transaction.sender, try! Hash160("969a77db482f74ce27105f760efa139223431394"))
        XCTAssertEqual(transaction.systemFee, 9007810)
        XCTAssertEqual(transaction.networkFee, 1268390)
        XCTAssertEqual(transaction.validUntilBlock, 2106265)
        XCTAssertEqual(transaction.attributes, [.highPriority])
        XCTAssertEqual(transaction.signers.count, 1)
        XCTAssertEqual(transaction.signers[0].signerHash, try! Hash160("969a77db482f74ce27105f760efa139223431394"))
        XCTAssert(transaction.signers[0].scopes.contains(.calledByEntry))
        XCTAssertEqual(transaction.script, [OpCode.push1.opcode])
    }
    
    public func testDeserializeWithZeroWitnesses() {
        let data = ("00" // version
                    + "62bdaa0e"  // nonce
                    + "c272890000000000"  // system fee
                    + "a65a130000000000"  // network fee
                    + "99232000"  // valid until block
                    + "01" + "941343239213fa0e765f1027ce742f48db779a96" + "01"
                    // one called by entry signer
                    + "01" + "01" // one attribute - high priority
                    + "01" + OpCode.push1.string  // 1-byte script with PUSH1 OpCode
                    + "00").bytesFromHex
        let transaction = try! NeoTransaction.from(data)
        XCTAssertEqual(transaction.version, 0)
        XCTAssertEqual(transaction.nonce, 246070626)
        XCTAssertEqual(transaction.sender, try! Hash160("969a77db482f74ce27105f760efa139223431394"))
        XCTAssertEqual(transaction.systemFee, 9007810)
        XCTAssertEqual(transaction.networkFee, 1268390)
        XCTAssertEqual(transaction.validUntilBlock, 2106265)
        XCTAssertEqual(transaction.attributes, [.highPriority])
        XCTAssertEqual(transaction.signers.count, 1)
        XCTAssertEqual(transaction.signers[0].signerHash, try! Hash160("969a77db482f74ce27105f760efa139223431394"))
        XCTAssert(transaction.signers[0].scopes.contains(.calledByEntry))
        XCTAssertEqual(transaction.script, [OpCode.push1.opcode])
    }
    
    public func testSize() {
        let signers = try! [AccountSigner.global(account1), AccountSigner.calledByEntry(account2)]
        let witnesses = [Witness([0], [0])]
        let tx = NeoTransaction(neoSwift: neoSwift, version: 0, nonce: 0x01020304,
                                         validUntilBlock: 0x01020304, signers: signers,
                                         systemFee: 10.toPowerOf(8), networkFee: 1, attributes: [],
                                         script: [OpCode.push1.opcode], witnesses: witnesses)
        XCTAssertEqual(tx.size, 76)
    }
    
    public func testFailDeserializingWithTooManyTransactionAttributes() {
        var string = "00" // version 0
        + "62bdaa0e"  // nonce
        + "c272890000000000"  // system fee
        + "a65a130000000000"  // network fee
        + "99232000"  // valid until block
        + "11"
        (0...16).forEach { _ in string.append("941343239213fa0e765f1027ce742f48db779a9601") }
        string.append("00")
        
        XCTAssertThrowsError(try NeoTransaction.from(string.bytesFromHex)) { error in
            XCTAssert(error.localizedDescription.contains("A transaction can hold at most "))
        }
    }

    public func testGetTxId() {
        let signers = try! [AccountSigner.calledByEntry(account3)]
        let script = "110c146cd3d4f4f7e35c5ee7d0e725c11dc880cef1e8b10c14c6a1c24a5b87fb8ccd7ac5f7948ffe526d4e01f713c00c087472616e736665720c1425059ecb4878d3a875f91c51ceded330d4575fde41627d5b5238".bytesFromHex
        let tx = NeoTransaction(neoSwift: neoSwift, version: 0, nonce: 226292130,
                                         validUntilBlock: 2103398, signers: signers,
                                         systemFee: 9007990, networkFee: 1244390, attributes: [],
                                         script: script, witnesses: [])
        XCTAssertEqual(tx.txId, try! Hash256("22ffa2d8680cea4928e2e74ceee560eedfa6e35f199640a7fe725c1f9da0b19e"))
    }
    
    public func testToArrayWithoutWitnesses() {
        let signers = try! [AccountSigner.calledByEntry(account3)]
        let script = "110c146cd3d4f4f7e35c5ee7d0e725c11dc880cef1e8b10c14c6a1c24a5b87fb8ccd7ac5f7948ffe526d4e01f713c00c087472616e736665720c1425059ecb4878d3a875f91c51ceded330d4575fde41627d5b5238".bytesFromHex
        let tx = NeoTransaction(neoSwift: neoSwift, version: 0, nonce: 226292130,
                                         validUntilBlock: 2103398, signers: signers,
                                         systemFee: 9007990, networkFee: 1244390,
                                         attributes: [], script: script, witnesses: [])
        let expected = "00a2f17c0d7673890000000000e6fc120000000000661820000175715e89bbba44a25dc9ca8d4951f104c25c253d010055110c146cd3d4f4f7e35c5ee7d0e725c11dc880cef1e8b10c14c6a1c24a5b87fb8ccd7ac5f7948ffe526d4e01f713c00c087472616e736665720c1425059ecb4878d3a875f91c51ceded330d4575fde41627d5b5238".bytesFromHex
        XCTAssertEqual(tx.toArrayWithoutWitnesses(), expected)
    }
    
    public func testGetHashData() async {
        _ = try! neoSwift.config.setNetworkMagic(769)
        let signers = try! [AccountSigner.none(.fromScriptHash(account1))]
        let tx = NeoTransaction(neoSwift: neoSwift, version: 0, nonce: 0,
                                         validUntilBlock: 0, signers: signers,
                                         systemFee: 0, networkFee: 0, attributes: [],
                                         script: [Byte(1), Byte(2), Byte(3)], witnesses: [])
        let withoutWitness = "000000000000000000000000000000000000000000000000000193ad1572a4b35c4b925483ce1701b78742dc460f000003010203".bytesFromHex
        let expected = try! await neoSwift.getNetworkMagicNumberBytes() + withoutWitness.sha256()
        let actual = try! await tx.getHashData()
        XCTAssertEqual(expected, actual)
    }
    
    public func testTooBigTransaction() async {
        let tooBigScript = Bytes(repeating: 0, count: NeoConstants.MAX_TRANSACTION_SIZE - 32)
        let tx = NeoTransaction(neoSwift: neoSwift, version: 0, nonce: 0,
                                         validUntilBlock: 0, signers: [],
                                         systemFee: 0, networkFee: 0, attributes: [],
                                         script: tooBigScript, witnesses: [])
        XCTAssertEqual(tx.size, NeoConstants.MAX_TRANSACTION_SIZE + 1)
        do {
            _ = try await tx.send()
            XCTFail()
        } catch {
            XCTAssert(error.localizedDescription.contains("The transaction exceeds the maximum transaction size."))
        }
    }
    
    public func testMaxTransactionSize() {
        let tooBigScript = Bytes(repeating: 0, count: NeoConstants.MAX_TRANSACTION_SIZE - 33)
        let tx = NeoTransaction(neoSwift: neoSwift, version: 0, nonce: 0,
                                         validUntilBlock: 0, signers: [],
                                         systemFee: 0, networkFee: 0, attributes: [],
                                         script: tooBigScript, witnesses: [])
        XCTAssertEqual(tx.size, NeoConstants.MAX_TRANSACTION_SIZE)
    }
    
    public func testAddMultiSigWitnessWithPubKeySigMap() async {
        _ = try! neoSwift.config.setNetworkMagic(769)
        let multiSigAccount = try! Account.createMultiSigAccount([a4.keyPair!.publicKey, a5.keyPair!.publicKey, a6.keyPair!.publicKey], 3)
        let dummyTx = try! NeoTransaction(neoSwift: neoSwift, version: 0, nonce: 0x01020304, validUntilBlock: 0x01020304,
                                              signers: [AccountSigner.calledByEntry(multiSigAccount)],
                                              systemFee: 10.toPowerOf(8), networkFee: 1, attributes: [],
                                              script: [OpCode.push1.opcode], witnesses: [])
        let dummyBytes = try! await dummyTx.getHashData()
        let sig4 = try! Sign.signMessage(dummyBytes, a4.keyPair!)
        let sig5 = try! Sign.signMessage(dummyBytes, a5.keyPair!)
        let sig6 = try! Sign.signMessage(dummyBytes, a6.keyPair!)
        let keyMap = [a4.keyPair!.publicKey: sig4, a5.keyPair!.publicKey: sig5, a6.keyPair!.publicKey: sig6]
        _ = try! dummyTx.addMultiSigWitness(multiSigAccount.verificationScript!, keyMap)
        let expectedMultiSigWitness = try! Witness.creatMultiSigWitness([sig4, sig5, sig6], multiSigAccount.verificationScript!)
        XCTAssertEqual(dummyTx.witnesses, [expectedMultiSigWitness])
    }
    
    public func testAddMultiSigWitnessWithAccounts() async {
        _ = try! neoSwift.config.setNetworkMagic(769)
        let multiSigAccount = try! Account.createMultiSigAccount([a4.keyPair!.publicKey, a5.keyPair!.publicKey, a6.keyPair!.publicKey], 3)
        let dummyTx = try! NeoTransaction(neoSwift: neoSwift, version: 0, nonce: 0x01020304, validUntilBlock: 0x01020304,
                                              signers: [AccountSigner.calledByEntry(multiSigAccount)],
                                              systemFee: 10.toPowerOf(8), networkFee: 1, attributes: [],
                                              script: [OpCode.push1.opcode], witnesses: [])
        let dummyBytes = try! await dummyTx.getHashData()
        let sig4 = try! Sign.signMessage(dummyBytes, a4.keyPair!)
        let sig5 = try! Sign.signMessage(dummyBytes, a5.keyPair!)
        let sig6 = try! Sign.signMessage(dummyBytes, a6.keyPair!)
        _ = try! await dummyTx.addMultiSigWitness(multiSigAccount.verificationScript!, a5, a6, a4)
        _ = try! await dummyTx.addMultiSigWitness(multiSigAccount.verificationScript!, a6, a4, a5)
        let expectedMultiSigWitness = try! Witness.creatMultiSigWitness([sig4, sig5, sig6], multiSigAccount.verificationScript!)
        XCTAssertEqual(dummyTx.witnesses, [expectedMultiSigWitness, expectedMultiSigWitness])
    }
        
    public func testContractParameterContextJson() async {
        let service = HttpService(url: URL(string: "http://localhost:40332")!)
        let neoSwift = NeoSwift(config: .init(networkMagic: 769), neoSwiftService: service)
        
        let pubKey = try! ECKeyPair.createEcKeyPair().publicKey
        let multiSigAccount = try! Account.createMultiSigAccount([pubKey, pubKey, pubKey], 2)
        let singleAccount1 = try! Account.create(), singleAccount2 = try! Account.create()
        let signers: [AccountSigner] = try! [.none(singleAccount1),
                                             .calledByEntry(singleAccount2),
                                             .calledByEntry(multiSigAccount)]
        let tx = NeoTransaction(neoSwift: neoSwift, version: 0, nonce: 0x01020304,
                                              validUntilBlock: 0x01020304, signers: signers,
                                              systemFee: 10.toPowerOf(8), networkFee: 1, attributes: [],
                                              script: [OpCode.push1.opcode], witnesses: [])
        let account1Witness = try! await Witness.create(tx.getHashData(), singleAccount1.keyPair!)
        _ = tx.addWitness(account1Witness)
        let ctx = try! await tx.toContractParametersContext()
        XCTAssertEqual(ctx.type, "Neo.Network.P2P.Payloads.Transaction")
        XCTAssertEqual(ctx.network, 769)
        XCTAssertEqual(ctx.data, tx.toArrayWithoutWitnesses().base64Encoded)
        XCTAssertEqual(ctx.hash, tx.txId?.string)
        XCTAssertEqual(ctx.items.count, 3)
        
        let item = ctx.items["0x" + singleAccount1.scriptHash!.string]!
        XCTAssertEqual(item.script, singleAccount1.verificationScript?.script.base64Encoded)
        XCTAssertEqual(item.parameters, [.init(type: .signature, value: account1Witness.invocationScript.getSignatures().first?.concatenated)])
        XCTAssertEqual(item.signatures.count, 1)
        XCTAssertEqual(try! item.signatures[singleAccount1.keyPair!.publicKey.getEncodedCompressedHex()],
                       account1Witness.invocationScript.getSignatures().first!.concatenated.base64Encoded)
        
        let item2 = ctx.items["0x" + singleAccount2.scriptHash!.string]!
        XCTAssertEqual(item2.script, singleAccount2.verificationScript?.script.base64Encoded)
        XCTAssertEqual(item2.parameters, [.init(type: .signature, value: nil)])
        XCTAssert(item2.signatures.isEmpty)
        
        let item3 = ctx.items["0x" + multiSigAccount.scriptHash!.string]!
        XCTAssertEqual(item3.script, multiSigAccount.verificationScript?.script.base64Encoded)
        XCTAssertEqual(item3.parameters, [.init(type: .signature, value: nil), .init(type: .signature, value: nil)])
        XCTAssert(item3.signatures.isEmpty)
    }
    
    public func testToContractParameterContextJson_unsupportedContractSigners() async {
        let service = HttpService(url: URL(string: "http://localhost:40332")!)
        let neoSwift = NeoSwift(config: .init(networkMagic: 769), neoSwiftService: service)
        
        let singleSigAccount1 = try! Account.create()
        let dummyHash = try! Hash160("f32bf2a3e36a9fd3411337ffcd48eed7bec727ce")
        let signers: [Signer] = try! [AccountSigner.none(singleSigAccount1), ContractSigner.calledByEntry(dummyHash)]
        let tx = NeoTransaction(neoSwift: neoSwift, version: 0, nonce: 0x01020304,
                                              validUntilBlock: 0x01020304, signers: signers,
                                              systemFee: 10.toPowerOf(8), networkFee: 1, attributes: [],
                                              script: [OpCode.push1.opcode], witnesses: [])
        let account1Witness = try! await Witness.create(tx.getHashData(), singleSigAccount1.keyPair!)
        _ = tx.addWitness(account1Witness)
        
        do {
            try await _ = tx.toContractParametersContext()
            XCTFail("No exception")
        } catch {
            XCTAssertEqual(error.localizedDescription, "Cannot handle contract signers")
        }
    }
    
}
