
import BigInt
import XCTest
@testable import NeoSwift

class WitnessRuleTest: XCTestCase {
    
    func testDecodeBooleanCondition() {
        let json = "{\"action\": \"Allow\",\"condition\": {\"type\": \"Boolean\",\"expression\": \"false\"}}"
        let rule = assertRule(json, .allow)
        guard case .boolean(let bool) = rule.condition else {
            XCTFail()
            return
        }
        XCTAssertFalse(bool)
        XCTAssert(rule.condition.booleanExpression == false)
        XCTAssertEqual(rule.condition, .boolean(false))
        
        let newRule = WitnessRule(action: .allow, condition: .boolean(false))
        XCTAssertEqual(rule, newRule)
    }
    
    func testDecodeNotCondition() {
        let json = "{\"action\": \"Allow\",\"condition\": {\"type\": \"Not\",\"expression\": {\"type\": \"Not\",\"expression\": {\"type\": \"CalledByEntry\"}}}}"
        let rule = assertRule(json, .allow)
        guard case .not(let expression1) = rule.condition,
              case .not(let expression2) = expression1 else {
            XCTFail()
            return
        }
        XCTAssertEqual(expression2, .calledByEntry)
        XCTAssertEqual(rule.condition, .not(.not(.calledByEntry)))
    }
    
    func testDecodeAndCondition() {
        let json = "{\"action\": \"Allow\",\"condition\": {\"type\": \"And\",\"expressions\": [{\"type\": \"CalledByEntry\"},{\"type\": \"Group\",\"group\": \"021821807f923a3da004fb73871509d7635bcc05f41edef2a3ca5c941d8bbc1231\"},{\"type\": \"Boolean\",\"expression\": \"true\"}]}}"
        let rule = assertRule(json, .allow)
        guard case .and(let expressions) = rule.condition else {
            XCTFail()
            return
        }
        XCTAssertEqual(expressions.count, 3)
        guard case .calledByEntry = expressions[0],
              case .group(let decodedPublicKey) = expressions[1],
              case .boolean(let decodedBoolean) = expressions[2] else {
            XCTFail()
            return
        }
        let pubKey = try! ECPublicKey("021821807f923a3da004fb73871509d7635bcc05f41edef2a3ca5c941d8bbc1231")
        XCTAssertEqual(pubKey, decodedPublicKey)
        XCTAssertEqual(pubKey, expressions[1].group)
        
        XCTAssertTrue(decodedBoolean)
        XCTAssert(expressions[2].booleanExpression == true)
        XCTAssertEqual(rule.condition, .and([.calledByEntry, .group(pubKey), .boolean(true)]))
    }
    
    func testDecodeOrCondition() {
        let json = "{\"action\": \"Deny\",\"condition\": {\"type\": \"Or\",\"expressions\": [{\"type\": \"Group\",\"group\": \"023be7b6742268f4faca4835718f3232ddc976855d5ef273524cea36f0e8d102f3\"},{\"type\": \"CalledByEntry\"}]}}"
        let rule = assertRule(json, .deny)
        guard case .or(let expressions) = rule.condition else {
            return XCTFail()
        }
        XCTAssertEqual(expressions.count, 2)
        guard case .group(let decodedPublicKey) = expressions[0],
              case .calledByEntry = expressions[1] else {
            return XCTFail()
        }
        let pubKey = try! ECPublicKey("023be7b6742268f4faca4835718f3232ddc976855d5ef273524cea36f0e8d102f3")
        XCTAssertEqual(pubKey, decodedPublicKey)
        XCTAssertEqual(pubKey, expressions[0].group)
        XCTAssertEqual(rule.condition, .or([.group(pubKey), .calledByEntry]))
    }
    
    func testDecodeScriptHash() {
        let json = "{\"action\": \"Allow\",\"condition\": {\"type\": \"ScriptHash\",\"hash\": \"0xef4073a0f2b305a38ec4050e4d3d28bc40ea63f5\"}}"
        let rule = assertRule(json, .allow)
        guard case .scriptHash(let decodedHash) = rule.condition else {
            return XCTFail()
        }
        let hash = try! Hash160("0xef4073a0f2b305a38ec4050e4d3d28bc40ea63f5")
        XCTAssertEqual(hash, decodedHash)
        XCTAssertEqual(hash, rule.condition.scriptHash)
        XCTAssertEqual(rule.condition, .scriptHash(hash))
    }
    
    func testDecodeGroupCondition() {
        let json = "{\"action\": \"Allow\",\"condition\": {\"type\": \"Group\",\"group\": \"0352321377ac7b4e1c4c2ebfe28f4d82fa3c213f7ccfcc9dac62da37fb9b433f0c\"}}"
        let rule = assertRule(json, .allow)
        guard case .group(let decodedPublicKey) = rule.condition else {
            return XCTFail()
        }
        let publicKey = try! ECPublicKey("0352321377ac7b4e1c4c2ebfe28f4d82fa3c213f7ccfcc9dac62da37fb9b433f0c")
        XCTAssertEqual(publicKey, decodedPublicKey)
        XCTAssertEqual(publicKey, rule.condition.group)
        XCTAssertEqual(rule.condition, .group(publicKey))
    }
    
    func testDecodeCalledByEntryCondition() {
        let json = "{\"action\": \"Deny\",\"condition\": {\"type\": \"CalledByEntry\"}}"
        XCTAssertEqual(assertRule(json, .deny).condition, .calledByEntry)
    }
    
    func testDecodeCalledByContractCondition() {
        let json = "{\"action\": \"Allow\",\"condition\": {\"type\": \"CalledByContract\",\"hash\": \"0xef4073a0f2b305a38ec4050e4d3d28bc40ea63e4\"}}"
        let rule = assertRule(json, .allow)
        guard case .calledByContract(let decodedHash) = rule.condition else {
            return XCTFail()
        }
        let hash = try! Hash160("0xef4073a0f2b305a38ec4050e4d3d28bc40ea63e4")
        XCTAssertEqual(hash, decodedHash)
        XCTAssertEqual(hash, rule.condition.scriptHash)
        XCTAssertEqual(rule.condition, .calledByContract(hash))
    }
    
    func testDecodeCalledByGroupCondition() {
        let json = "{\"action\": \"Deny\",\"condition\": {\"type\":\"CalledByGroup\",\"group\":\"035a1ced7ae274a881c3f479452c8bca774c89f653d54c5c5959a01371a8c696fd\"}}"
        let rule = assertRule(json, .deny)
        guard case .calledByGroup(let decodedPublicKey) = rule.condition else {
            return XCTFail()
        }
        let publicKey = try! ECPublicKey("035a1ced7ae274a881c3f479452c8bca774c89f653d54c5c5959a01371a8c696fd")
        XCTAssertEqual(publicKey, decodedPublicKey)
        XCTAssertEqual(publicKey, rule.condition.group)
        XCTAssertEqual(rule.condition, .calledByGroup(publicKey))
    }
    
    func testNilBoolean() {
        let json = "{\"action\": \"Deny\",\"condition\": {\"type\":\"CalledByGroup\",\"group\":\"035a1ced7ae274a881c3f479452c8bca774c89f653d54c5c5959a01371a8c696fd\"}}"
        XCTAssertNil(assertRule(json, .deny).condition.booleanExpression)
    }
    
    func testNilExpression() {
        let json = "{\"action\": \"Deny\",\"condition\": {\"type\":\"CalledByGroup\",\"group\":\"035a1ced7ae274a881c3f479452c8bca774c89f653d54c5c5959a01371a8c696fd\"}}"
        XCTAssertNil(assertRule(json, .deny).condition.expression)
    }
    
    func testNilExpressionList() {
        let json = "{\"action\": \"Deny\",\"condition\": {\"type\":\"Boolean\",\"expression\":\"false\"}}"
        XCTAssertNil(assertRule(json, .deny).condition.expressionList)
    }
    
    func testNilScriptHash() {
        let json = "{\"action\": \"Deny\",\"condition\": {\"type\":\"And\",\"expressions\": [{\"type\": \"CalledByEntry\"},{\"type\": \"Group\",\"group\": \"021821807f923a3da004fb73871509d7635bcc05f41edef2a3ca5c941d8bbc1231\"}]}}"
        XCTAssertNil(assertRule(json, .deny).condition.scriptHash)
    }
    
    func testNilGroup() {
        let json = "{\"action\": \"Deny\",\"condition\": {\"type\":\"CalledByEntry\"}}"
        XCTAssertNil(assertRule(json, .deny).condition.group)
    }
        
    func assertRule(_ json: String, _ action: WitnessAction) -> WitnessRule {
        let decoder = JSONDecoder()
        let rule = try! decoder.decode(WitnessRule.self, from: json.data(using: .utf8)!)
        XCTAssert(rule.action == action)
        return rule
    }
    
    func testBooleanConditionSerializeDeserialize() {
        let condition = WitnessCondition.boolean(true)
        let bytes = "0001".bytesFromHex

        let deserialized = WitnessCondition.from(bytes)
        XCTAssertEqual(deserialized, condition)
        
        let writer = BinaryWriter()
        condition.serialize(writer)
        XCTAssertEqual(bytes, writer.toArray())
    }
    
    func testNotConditionSerializeDeserialize() {
        let condition = WitnessCondition.not(.boolean(true))
        let bytes = "010001".bytesFromHex
        
        let deserialized = WitnessCondition.from(bytes)
        XCTAssertEqual(deserialized, condition)
        
        let writer = BinaryWriter()
        condition.serialize(writer)
        XCTAssertEqual(bytes, writer.toArray())
    }
    
    func testAndConditionSerializeDeserialize() {
        let condition = WitnessCondition.and([.boolean(true), .boolean(false)])
        let bytes = "020200010000".bytesFromHex
        
        let deserialized = WitnessCondition.from(bytes)
        XCTAssertEqual(condition, deserialized)
        
        let writer = BinaryWriter()
        condition.serialize(writer)
        XCTAssertEqual(bytes, writer.toArray())
    }
    
    func testOrConditionSerializeDeserialize() {
        let condition = WitnessCondition.or([.boolean(true), .boolean(false)])
        let bytes = "030200010000".bytesFromHex
        
        let deserialized = WitnessCondition.from(bytes)
        XCTAssertEqual(condition, deserialized)
        
        let writer = BinaryWriter()
        condition.serialize(writer)
        XCTAssertEqual(bytes, writer.toArray())
    }
    
    func testScriptHashConditionSerializeDeserialize() {
        let hash = try! Hash160(defaultAccountScriptHash)
        
        let condition = WitnessCondition.scriptHash(hash)
        let bytes = "18\(Bytes(defaultAccountScriptHash.bytesFromHex.reversed()).toHexString())".bytesFromHex
        
        let deserialized = WitnessCondition.from(bytes)
        XCTAssertEqual(condition, deserialized)
        
        let writer = BinaryWriter()
        condition.serialize(writer)
        XCTAssertEqual(bytes, writer.toArray())
    }
    
    func testGroupConditionSerializeDeserialize() {
        let key = try! ECPublicKey(defaultAccountPublicKey)
        
        let condition = WitnessCondition.group(key)
        let bytes = "19\(defaultAccountPublicKey)".bytesFromHex
        
        let deserialized = WitnessCondition.from(bytes)
        XCTAssertEqual(condition, deserialized)
        
        let writer = BinaryWriter()
        condition.serialize(writer)
        XCTAssertEqual(bytes, writer.toArray())
    }
    
    func testCalledByEntryConditionSerializeDeserialize() {
        let condition = WitnessCondition.calledByEntry
        let bytes = "20".bytesFromHex
        
        let deserialized = WitnessCondition.from(bytes)
        XCTAssertEqual(condition, deserialized)
        
        let writer = BinaryWriter()
        condition.serialize(writer)
        XCTAssertEqual(bytes, writer.toArray())
    }
    
    func testCalledByContractConditionSerializeDeserialize() {
        let hash = try! Hash160(defaultAccountScriptHash)
        
        let condition = WitnessCondition.calledByContract(hash)
        let bytes = "28\(Bytes(defaultAccountScriptHash.bytesFromHex.reversed()).toHexString())".bytesFromHex
        
        let deserialized = WitnessCondition.from(bytes)
        XCTAssertEqual(condition, deserialized)
        
        let writer = BinaryWriter()
        condition.serialize(writer)
        XCTAssertEqual(bytes, writer.toArray())
    }
    
    func testCalledByGroupGroupConditionSerializeDeserialize() {
        let key = try! ECPublicKey(defaultAccountPublicKey)
        
        let condition = WitnessCondition.calledByGroup(key)
        let bytes = "29\(defaultAccountPublicKey)".bytesFromHex
        
        let deserialized = WitnessCondition.from(bytes)
        XCTAssertEqual(condition, deserialized)
        
        let writer = BinaryWriter()
        condition.serialize(writer)
        XCTAssertEqual(bytes, writer.toArray())
    }
    
}
