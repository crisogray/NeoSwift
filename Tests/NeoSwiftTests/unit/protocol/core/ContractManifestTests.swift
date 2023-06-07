
import XCTest
@testable import NeoSwift

class ContractManifestTests: XCTestCase {
    
    public func testSerializeWithWildCardTrust() {
        let contractManifest = ContractManifest(trusts: ["*"])
        XCTAssert(toJsonString(contractManifest).contains("\"trusts\":\"*\""))
    }
    
    public func testSerializeWithNoTrusts() {
        let contractManifest = ContractManifest()
        XCTAssert(toJsonString(contractManifest).contains("\"trusts\":[]"))
    }
    
    public func testSerializeWithOneTrust() {
        let contractManifest = ContractManifest(trusts: ["69ecca587293047be4c59159bf8bc399985c160d"])
        XCTAssert(toJsonString(contractManifest).contains("\"trusts\":[\"69ecca587293047be4c59159bf8bc399985c160d\"]"))
    }
    
    public func testSerializeWithTwoTrusts() {
        let contractManifest = ContractManifest(trusts: ["69ecca587293047be4c59159bf8bc399985c160d", "69ecca587293047be4c59159bf8bc399985c160d"])
        XCTAssert(toJsonString(contractManifest).contains("\"trusts\":[\"69ecca587293047be4c59159bf8bc399985c160d\",\"69ecca587293047be4c59159bf8bc399985c160d\"]"))
    }
    
    public func testSerializeWithWildCardPermissionMethod() {
        let contractPermission = ContractManifest.ContractPermission(contract: "NeoToken", methods: ["*"])
        let contractManifest = ContractManifest(permissions: [contractPermission])
        XCTAssert(toJsonString(contractManifest).contains("\"permissions\":[{\"methods\":\"*\",\"contract\":\"NeoToken\"}]"))
    }
    
    public func testSerializeWithNoPermissions() {
        let contractManifest = ContractManifest()
        XCTAssert(toJsonString(contractManifest).contains("\"permissions\":[]"))
    }
    
    public func testSerializeWithPermissionsOneMethod() {
        let contractPermission = ContractManifest.ContractPermission(contract: "NeoToken", methods: ["method"])
        let contractManifest = ContractManifest(permissions: [contractPermission])
        XCTAssert(toJsonString(contractManifest).contains("\"permissions\":[{\"methods\":[\"method\"],\"contract\":\"NeoToken\"}]"))
    }
    
    public func testSerializeWithMultiplePermissions() {
        let contractPermission1 = ContractManifest.ContractPermission(contract: "NeoToken", methods: ["method"])
        let contractPermission2 = ContractManifest.ContractPermission(contract: "GasToken", methods: ["method1", "method2"])
        let contractPermission3 = ContractManifest.ContractPermission(contract: "SomeToken", methods: ["*"])
        let contractManifest = ContractManifest(permissions: [contractPermission1, contractPermission2, contractPermission3])
        XCTAssert(toJsonString(contractManifest).contains("\"permissions\":[{\"methods\":[\"method\"],\"contract\":\"NeoToken\"},{\"methods\":[\"method1\",\"method2\"],\"contract\":\"GasToken\"},{\"methods\":\"*\",\"contract\":\"SomeToken\"}]"))
    }
    
    public func testSetGroups() {
        var contractManifest = ContractManifest(name: "TestContract")
        XCTAssert(contractManifest.groups.isEmpty)
        contractManifest.groups = try! [.init(pubKey: "0x025f3953adaf5155d9ee63ce40643837219286636fe28d6024c4b1d28f675a12e2",
                                         signature: "uIBPwD2tYw8ESy1GXHksHD6XrzssQOJp0H0sBSJ76CnAxtf1VgZDJ45OAGXZynamiBpNS/f8Lk5aAJ2viB5XxA==")]
        XCTAssertEqual(contractManifest.groups.count, 1)
    }
    
    public func testCreateGroup() {
        var contractManifest = ContractManifest(name: "TestContract")
        XCTAssert(contractManifest.groups.isEmpty)
        contractManifest.groups = try! [.init(pubKey: "0x025f3953adaf5155d9ee63ce40643837219286636fe28d6024c4b1d28f675a12e2",
                                         signature: "tBscf3to/EMw/lLSM07Ko9WPeegYJds76LIcZusDXpwPbvCJUdtiLf+Cf5rF41WuDyUoC5mfOkUOrKHS1y+tWQ==")]
        XCTAssertEqual(contractManifest.groups.count, 1)
        
        let deploySender = try! Hash160("f3e641ce66b1276119296da872f5e97c11538bcb")
        let group2KeyPair = try! Account.fromWIF("L2v2C2RenZgZLRSFSTVK4Ngk68E8PDXVQvJ1ijTp92EasBvXk7R7").keyPair!
        let group2 = try! contractManifest.createGroup(group2KeyPair, deploySender, 2173916934)

        contractManifest.groups = [group2]
        XCTAssertEqual(contractManifest.groups.count, 1)
        XCTAssertEqual(contractManifest.groups[0].pubKey, "03e237d84371612e3d2ce2a71b3c150ded51be3e93d34c494d1424bdae349900a9")
        XCTAssertEqual(contractManifest.groups[0].signature, "lzrUouvaXRl0IM7dhN3PaIUZ9LL9AMw7/1ZknI60BMlPXRW99l246N69F5MW3kAiXFyk0N4cte//Ajfu1ZZ2KQ==")
    }
    
    public func testContractGroupCheckPubKey() {
        let invalidPubKey = "0x03df97fb65edef80f2fc99ac4ae4efd1a30c519c07f8b3621782787f2881a9b7"
        let signature1 = "1USFvVTJEgo1MUqpm6ZEx/NOAh4eyVfit5fg7FAipIYVbPVH8railarQ7THMjKOPbtpC6SyUs4OmpSF8Khc3jA=="
        XCTAssertThrowsError(try ContractManifest.ContractGroup(pubKey: invalidPubKey, signature: signature1)) { error in
            XCTAssertEqual(error.localizedDescription, "The provided value is not a valid public key: 03df97fb65edef80f2fc99ac4ae4efd1a30c519c07f8b3621782787f2881a9b7")
        }
    }
    
    public func testContractGroupCheckBase64Signature() {
        let pubKey = "03df97fb65edef80f2fc99ac4ae4efd1a30c519c07f8b3621782787f2881a9b7b5"
        let invalidSignature = "Neow=="
        XCTAssertThrowsError(try ContractManifest.ContractGroup(pubKey: pubKey, signature: invalidSignature)) { error in
            XCTAssertEqual(error.localizedDescription, "Invalid signature: \(invalidSignature). Please provide a valid signature in base64 format.")
        }
    }
    
    private func toJsonString(_ c: ContractManifest) -> String {
        let json = try! JSONEncoder().encode(c)
        return String(data: json, encoding: .utf8)!
    }
    
}
