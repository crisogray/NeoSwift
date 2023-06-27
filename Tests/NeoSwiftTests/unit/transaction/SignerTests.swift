
import XCTest
@testable import NeoSwift

class SignerTests: XCTestCase {
    
    private let account = try! Account.fromWIF("Kzt94tAAiZSgH7Yt4i25DW6jJFprZFPSqTgLr5dWmWgKDKCjXMfZ")
    private let contract1 = try! Hash160.fromScript("d802a401".bytesFromHex)
    private let contract2 = try! Hash160.fromScript("c503b112".bytesFromHex)
    private let groupPubKey1 = try! ECPublicKey("0306d3e7f18e6dd477d34ce3cfeca172a877f3c907cc6c2b66c295d1fcc76ff8f7".bytesFromHex)
    private let groupPubKey2 = try! ECPublicKey("02958ab88e4cea7ae1848047daeb8883daf5fdf5c1301dbbfe973f0a29fe75de60".bytesFromHex)
    private var accountScriptHash: Hash160!

    override func setUp() {
        super.setUp()
        accountScriptHash = account.scriptHash!
    }
    
    public func testCreateSignerWithCallByEntryWitnessScope() {
        let signer = try! AccountSigner.calledByEntry(accountScriptHash)
        XCTAssertEqual(signer.signerHash, accountScriptHash)
        XCTAssertEqual(signer.scopes, [.calledByEntry])
        XCTAssert(signer.allowedContracts.isEmpty)
        XCTAssert(signer.allowedGroups.isEmpty)
    }
    
    public func testCreateSignerWithGlobalWitnessScope() {
        let signer = try! AccountSigner.global(accountScriptHash)
        XCTAssertEqual(signer.signerHash, accountScriptHash)
        XCTAssertEqual(signer.scopes, [.global])
        XCTAssert(signer.allowedContracts.isEmpty)
        XCTAssert(signer.allowedGroups.isEmpty)
    }
    
    public func testBuildValidSigner1() {
        let signer = try! AccountSigner.calledByEntry(accountScriptHash)
            .setAllowedContracts([contract1, contract2])
        XCTAssertEqual(signer.signerHash, accountScriptHash)
        XCTAssertEqual(signer.scopes, [.calledByEntry, .customContracts])
        XCTAssertEqual(signer.allowedContracts, [contract1, contract2])
        XCTAssert(signer.allowedGroups.isEmpty)
    }
    
    public func testBuildValidSigner2() {
        let signer = try! AccountSigner.none(accountScriptHash)
            .setAllowedContracts([contract1, contract2])
        XCTAssertEqual(signer.signerHash, accountScriptHash)
        XCTAssertEqual(signer.scopes, [.customContracts])
        XCTAssertEqual(signer.allowedContracts, [contract1, contract2])
        XCTAssert(signer.allowedGroups.isEmpty)
    }
    
    public func testBuildValidSigner3() {
        let signer = try! AccountSigner.none(accountScriptHash)
            .setAllowedGroups([groupPubKey1, groupPubKey2])
        XCTAssertEqual(signer.signerHash, accountScriptHash)
        XCTAssertEqual(signer.scopes, [.customGroups])
        XCTAssertEqual(signer.allowedGroups, [groupPubKey1, groupPubKey2])
        XCTAssert(signer.allowedContracts.isEmpty)
    }
    
    public func testFailBuildingSignerWithGlobalScopeAndCustomContracts() {
        XCTAssertThrowsError(try AccountSigner.global(accountScriptHash).setAllowedContracts([contract1, contract2])) { error in
            XCTAssertEqual(error.localizedDescription, "Trying to set allowed contracts on a Signer with global scope.")
        }
    }
    
    public func testFailBuildingSignerWithGlobalScopeAndCustomGroups() {
        XCTAssertThrowsError(try AccountSigner.global(accountScriptHash).setAllowedGroups([groupPubKey1, groupPubKey2])) { error in
            XCTAssertEqual(error.localizedDescription, "Trying to set allowed contract groups on a Signer with global scope.")
        }
    }
    
    public func testFailBuildingSignerWithTooManyContracts() {
        let contracts = (0...16).map { _ in try! Hash160("3ab0be8672e25cf475219d018ded961ec684ca88") }
        XCTAssertThrowsError(try AccountSigner.calledByEntry(accountScriptHash).setAllowedContracts(contracts)) { error in
            XCTAssertEqual(error.localizedDescription, "Trying to set more than \(NeoConstants.MAX_SIGNER_SUBITEMS) allowed contracts on a signer.")
        }
    }
    
    public func testFailBuildingSignerWithTooManyContractsAddedSeparately() {
        let contracts = (0...15).map { _ in try! Hash160("3ab0be8672e25cf475219d018ded961ec684ca88") }
        let signer = try! AccountSigner.none(accountScriptHash).setAllowedContracts([Hash160("3ab0be8672e25cf475219d018ded961ec684ca88")])
        XCTAssertThrowsError(try signer.setAllowedContracts(contracts)) { error in
            XCTAssertEqual(error.localizedDescription, "Trying to set more than \(NeoConstants.MAX_SIGNER_SUBITEMS) allowed contracts on a signer.")
        }
    }
    
    public func testFailBuildingSignerWithTooManyGroups() {
        let groups = (0...16).map { _ in try! ECPublicKey("0306d3e7f18e6dd477d34ce3cfeca172a877f3c907cc6c2b66c295d1fcc76ff8f7".bytesFromHex) }
        XCTAssertThrowsError(try AccountSigner.calledByEntry(accountScriptHash).setAllowedGroups(groups)) { error in
            XCTAssertEqual(error.localizedDescription, "Trying to set more than \(NeoConstants.MAX_SIGNER_SUBITEMS) allowed contract groups on a signer.")
        }
    }
    
    public func testFailBuildingSignerWithTooManyGroupsAddedSeparately() {
        let groups = (0...15).map { _ in try! ECPublicKey("0306d3e7f18e6dd477d34ce3cfeca172a877f3c907cc6c2b66c295d1fcc76ff8f7".bytesFromHex) }
        let signer = try! AccountSigner.none(accountScriptHash)
            .setAllowedGroups([ECPublicKey("0306d3e7f18e6dd477d34ce3cfeca172a877f3c907cc6c2b66c295d1fcc76ff8f7".bytesFromHex)])
        XCTAssertThrowsError(try signer.setAllowedGroups(groups)) { error in
            XCTAssertEqual(error.localizedDescription, "Trying to set more than \(NeoConstants.MAX_SIGNER_SUBITEMS) allowed contract groups on a signer.")
        }
    }
    
    public func testSerializeGlobalScope() {
        let writer = BinaryWriter()
        try! AccountSigner.global(accountScriptHash).serialize(writer)
        let expected = accountScriptHash.string.reversedHex + [WitnessScope.global.byte].noPrefixHex
        XCTAssertEqual(expected.bytesFromHex, writer.toArray())
    }
    
    public func testSerializingWithCustomContractsScopeProducesCorrectByteArray() {
        let signer = try! AccountSigner.none(accountScriptHash).setAllowedContracts([contract1, contract2])
        let expected = accountScriptHash.string.reversedHex
        + [WitnessScope.customContracts.byte].noPrefixHex + "02"
        + contract1.string.reversedHex + contract2.string.reversedHex
        XCTAssertEqual(expected.bytesFromHex, signer.toArray())
    }
    
    public func testSerializeCustomGroupsScope() {
        let writer = BinaryWriter()
        try! AccountSigner.none(accountScriptHash).setAllowedGroups([groupPubKey1, groupPubKey2]).serialize(writer)
        let expected = accountScriptHash.string.reversedHex
        + [WitnessScope.customGroups.byte].noPrefixHex + "02"
        + groupPubKey1.toArray().noPrefixHex + groupPubKey2.toArray().noPrefixHex
        XCTAssertEqual(expected.bytesFromHex, writer.toArray())
    }
    
    public func testSerializeWithMultipleScopesContractsGroupsAndRules() {
        let writer = BinaryWriter()
        try! AccountSigner.calledByEntry(accountScriptHash)
            .setAllowedGroups([groupPubKey1, groupPubKey2])
            .setAllowedContracts([contract1, contract2])
            .setRules([.init(action: .allow, condition: .calledByContract(contract1))])
            .serialize(writer)
        let expected = accountScriptHash.string.reversedHex
        + "7102" + contract1.string.reversedHex + contract2.string.reversedHex
        + "02" + groupPubKey1.toArray().noPrefixHex + groupPubKey2.toArray().noPrefixHex
        + "010128" + contract1.string.reversedHex
        XCTAssertEqual(expected.bytesFromHex, writer.toArray())
    }
    
    public func testDeserialize() {
        let data = accountScriptHash.string.reversedHex
        + "7102" + contract1.string.reversedHex + contract2.string.reversedHex
        + "02" + groupPubKey1.toArray().noPrefixHex + groupPubKey2.toArray().noPrefixHex
        + "010128" + contract1.string.reversedHex
        
        let signer = try! Signer.from(data.bytesFromHex)
        
        XCTAssertEqual(signer.signerHash, accountScriptHash)
        XCTAssertEqual(signer.scopes, [.calledByEntry, .customContracts, .customGroups, .witnessRules])
        XCTAssertEqual(signer.allowedContracts, [contract1, contract2])
        XCTAssertEqual(signer.allowedGroups, [groupPubKey1, groupPubKey2])
        
        let rule = signer.rules[0]
        XCTAssertEqual(rule.action, .allow)
        XCTAssertEqual(rule.condition, .calledByContract(contract1))
    }
    
    public func testFailDeserializingWithTooManyContracts() {
        var serialized = accountScriptHash.string.reversedHex + "1111"
        for _ in 0...16 { serialized.append(contract1.string.reversedHex) }
        XCTAssertThrowsError(_ = try Signer.from(serialized.bytesFromHex)) { error in
            XCTAssert(error.localizedDescription.contains("A signer's scope can only contain \(NeoConstants.MAX_SIGNER_SUBITEMS) allowed contracts."))
        }
    }
    
    public func testFailDeserializingWithTooManyContractGroups() {
        var serialized = accountScriptHash.string.reversedHex + "2111"
        for _ in 0...16 { serialized.append(groupPubKey1.toArray().noPrefixHex) }
        XCTAssertThrowsError(_ = try Signer.from(serialized.bytesFromHex)) { error in
            XCTAssert(error.localizedDescription.contains("A signer's scope can only contain \(NeoConstants.MAX_SIGNER_SUBITEMS) allowed contract groups."))
        }
    }
    
    public func testFailDeserializingWithTooManyRules() {
        var serialized = accountScriptHash.string.reversedHex + "4111"
        for _ in 0...16 { serialized.append("0128\(contract1.string.reversedHex)") }
        XCTAssertThrowsError(_ = try Signer.from(serialized.bytesFromHex)) { error in
            XCTAssert(error.localizedDescription.contains("A signer's scope can only contain \(NeoConstants.MAX_SIGNER_SUBITEMS) rules."))
        }
    }
    
    public func testSize() {
        let rule = WitnessRule(action: .allow, condition: .and([.boolean(true), .boolean(false)]))
        let signer = try! AccountSigner.calledByEntry(accountScriptHash)
            .setAllowedGroups([groupPubKey1, groupPubKey2])
            .setAllowedContracts([contract1, contract2])
            .setRules([rule, rule])
        XCTAssertEqual(signer.size, 144)
    }
    
    public func testEquals() {
        let signer1 = try! AccountSigner.global(accountScriptHash)
        let signer2 = try! AccountSigner.global(accountScriptHash)
        XCTAssertEqual(signer1, signer2)
        
        let signer3 = try! AccountSigner.calledByEntry(accountScriptHash)
        let signer4 = try! AccountSigner.calledByEntry(accountScriptHash)
        XCTAssertEqual(signer3, signer4)
        
        let signer5 = try! AccountSigner.calledByEntry(accountScriptHash)
            .setAllowedGroups([groupPubKey1, groupPubKey2])
            .setAllowedContracts([contract1, contract2])
        let signer6 = try! AccountSigner.calledByEntry(accountScriptHash)
            .setAllowedGroups([groupPubKey1, groupPubKey2])
            .setAllowedContracts([contract1, contract2])
        XCTAssertEqual(signer5, signer6)
    }
    
    public func testFailDepthCheck() {
        let condition: WitnessCondition = .scriptHash(accountScriptHash)
        let and: WitnessCondition = .and([.and([.and([.not(condition)])])])
        let rule = WitnessRule(action: .allow, condition: and)
        XCTAssertThrowsError(_ = try AccountSigner.none(account).setRules([rule])) { error in
            XCTAssertEqual(error.localizedDescription, "A maximum nesting depth of \(WitnessCondition.MAX_NESTING_DEPTH) is allowed for witness conditions.")
        }
    }
    
    public func testFailAddingRuleToGlobalSigner() {
        let condition: WitnessCondition = .scriptHash(accountScriptHash)
        let rule = WitnessRule(action: .allow, condition: condition)
        XCTAssertThrowsError(_ = try AccountSigner.global(account).setRules([rule])) { error in
            XCTAssertEqual(error.localizedDescription, "Trying to set witness rules on a Signer with global scope.")
        }
    }
    
    public func testFailOnTooManyRules() {
        let condition: WitnessCondition = .scriptHash(accountScriptHash)
        let rule = WitnessRule(action: .allow, condition: condition)
        let signer = try! AccountSigner.none(account)
        for _ in 0..<NeoConstants.MAX_SIGNER_SUBITEMS { try! _ = signer.setRules([rule]) }
        XCTAssertThrowsError(try signer.setRules([rule])) { error in
            XCTAssertEqual(error.localizedDescription, "Trying to set more than \(NeoConstants.MAX_SIGNER_SUBITEMS) allowed witness rules on a signer.")
        }
    }
    
    public func testSerializeandDeserializeMaxNestedRules() {
        let writer = BinaryWriter()
        let rule = WitnessRule(action: .allow, condition: .and([.and([.boolean(true)])]))
        try! AccountSigner.none(.ZERO).setRules([rule]).serialize(writer)
        let expected = "0000000000000000000000000000000000000000400101020102010001"
        XCTAssertEqual(expected.bytesFromHex, writer.toArray())
    }
    
}
