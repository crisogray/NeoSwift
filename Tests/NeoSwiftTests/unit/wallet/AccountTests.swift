
import XCTest
@testable import NeoSwift

class AccountTests: XCTestCase {
    
    public func testCreateGenericAccount() {
        let account = try! Account.create()
        XCTAssertNotNil(account)
        XCTAssertNotNil(account.address)
        XCTAssertNotNil(account.verificationScript)
        XCTAssertNotNil(account.keyPair)
        XCTAssertNotNil(account.label)
        XCTAssertNil(account.encryptedPrivateKey)
        XCTAssertFalse(account.isLocked)
        XCTAssertFalse(account.isDefault)
    }
    
    public func testInitAccountFromExistingKeyPair() {
        let keyPair = try! ECKeyPair.create(privateKey: defaultAccountPrivateKey.bytesFromHex)
        let account = try! Account(keyPair: keyPair)
        XCTAssertFalse(account.isMultiSig)
        XCTAssertEqual(account.address, defaultAccountAddress)
        XCTAssertEqual(account.label, defaultAccountAddress)
        XCTAssertEqual(account.verificationScript?.script, defaultAccountVerificationScript.bytesFromHex)
    }
    
    public func testFromVerificationScript() {
        let verificationScript = VerificationScript("0x0c2102163946a133e3d2e0d987fb90cb01b060ed1780f1718e2da28edf13b965fd2b600b4195440d78".bytesFromHex)
        let account = try! Account.fromVerificationScript(verificationScript)
        XCTAssertEqual(account.address, "NZNos2WqTbu5oCgyfss9kUJgBXJqhuYAaj")
        XCTAssertEqual(account.verificationScript?.script, "0x0c2102163946a133e3d2e0d987fb90cb01b060ed1780f1718e2da28edf13b965fd2b600b4195440d78".bytesFromHex)
    }
    
    public func testFromPublicKey() {
        let publicKey = try! ECPublicKey(defaultAccountPublicKey)
        let account = try! Account.fromPublicKey(publicKey)
        XCTAssertEqual(account.address, defaultAccountAddress)
        XCTAssertEqual(account.verificationScript?.script, defaultAccountVerificationScript.bytesFromHex)
    }
    
    public func testCreateMultiSigAccountFromPublicKeys() {
        let publicKey = try! ECPublicKey(defaultAccountPublicKey)
        let account = try! Account.createMultiSigAccount([publicKey], 1)
        XCTAssert(account.isMultiSig)
        XCTAssertEqual(account.address, committeeAccountAddress)
        XCTAssertEqual(account.label, committeeAccountAddress)
        XCTAssertEqual(account.verificationScript?.script, committeeAccountVerificationScript.bytesFromHex)
    }
    
    public func testCreateMultiSigAccountWithAddress() {
        let account = try! Account.createMultiSigAccount(committeeAccountAddress, 4, 7)
        XCTAssert(account.isMultiSig)
        XCTAssertEqual(account.signingThreshold, 4)
        XCTAssertEqual(account.nrOfParticipants, 7)
        XCTAssertEqual(account.address, committeeAccountAddress)
        XCTAssertEqual(account.label, committeeAccountAddress)
        XCTAssertNil(account.verificationScript)
    }
    
    public func testCreateMultiSigAccountFromVerificationScript() {
        let account = try! Account.fromVerificationScript(VerificationScript(committeeAccountVerificationScript.bytesFromHex))
        XCTAssert(account.isMultiSig)
        XCTAssertEqual(account.address, committeeAccountAddress)
        XCTAssertEqual(account.label, committeeAccountAddress)
        XCTAssertEqual(account.verificationScript?.script, committeeAccountVerificationScript.bytesFromHex)
    }
    
    public func testEncryptPublicKey() {
        let keyPair = try! ECKeyPair.create(privateKey: defaultAccountPrivateKey.bytesFromHex)
        let account = try! Account(keyPair: keyPair)
        try! account.encryptPrivateKey(defaultAccountPassword)
        XCTAssertEqual(account.encryptedPrivateKey, defaultAccountEncryptedPrivateKey)
    }
    
    public func testFailEncryptAccountWithoutPrivateKey() {
        let account = try! Account.fromAddress(defaultAccountAddress)
        XCTAssertThrowsError(try account.encryptPrivateKey("pwd")) { error in
            XCTAssertEqual(error.localizedDescription, "The account does not hold a decrypted private key.")
        }
    }
    
    public func testDecryptWithStandardScryptParams() {
        let privateKey = try! ECPrivateKey(defaultAccountPrivateKey.bytesFromHex)
        let nep6Account = NEP6Account(address: "", label: "", isDefault: true, lock: false, key: defaultAccountEncryptedPrivateKey, contract: nil, extra: nil)
        let account = try! Account.fromNEP6Account(nep6Account)
        try! account.decryptPrivateKey(defaultAccountPassword)
        XCTAssertEqual(account.keyPair?.privateKey, privateKey)
        try! account.decryptPrivateKey(defaultAccountPassword)
        XCTAssertEqual(account.keyPair?.privateKey, privateKey)
    }
    
    public func testFailDecryptingAccountWithoutDecryptedPrivateKey() {
        let account = try! Account.fromAddress(defaultAccountAddress)
        XCTAssertThrowsError(try account.decryptPrivateKey(defaultAccountPassword)) { error in
            XCTAssertEqual(error.localizedDescription, "The account does not hold an encrypted private key.")
        }
    }
    
    public func testLoadAccountFromNEP6() {
        let url = Bundle.module.url(forResource: "account", withExtension: "json")!
        let nep6Account = try! JSONDecoder().decode(NEP6Account.self, from: Data(contentsOf: url))
        let account = try! Account.fromNEP6Account(nep6Account)
        
        XCTAssertFalse(account.isDefault)
        XCTAssertFalse(account.isLocked)
        XCTAssertEqual(account.address, defaultAccountAddress)
        XCTAssertEqual(account.verificationScript?.script, defaultAccountVerificationScript.bytesFromHex)
    }
    
    public func testLoadMultiSigAccountFromNEP6() {
        let url = Bundle.module.url(forResource: "multiSigAccount", withExtension: "json")!
        let nep6Account = try! JSONDecoder().decode(NEP6Account.self, from: Data(contentsOf: url))
        let account = try! Account.fromNEP6Account(nep6Account)
        
        XCTAssertFalse(account.isDefault)
        XCTAssertFalse(account.isLocked)
        XCTAssertEqual(account.address, committeeAccountAddress)
        XCTAssertEqual(account.verificationScript?.script, committeeAccountVerificationScript.bytesFromHex)
        XCTAssertEqual(account.nrOfParticipants, 1)
        XCTAssertEqual(account.signingThreshold, 1)
    }
    
    public func testToNep6AccountWithOnlyAnAddress() {
        let account = try! Account.fromAddress(defaultAccountAddress)
        let nep6 = try! account.toNEP6Account()
        XCTAssertNil(nep6.contract)
        XCTAssertFalse(nep6.isDefault)
        XCTAssertFalse(nep6.lock)
        XCTAssertEqual(nep6.address, defaultAccountAddress)
        XCTAssertEqual(nep6.label, defaultAccountAddress)
        XCTAssertNil(nep6.key)
    }
    
    public func testFailToNep6AccountWithUnencryptedPrivateKey() {
        let account = try! Account.fromWIF(defaultAccountWIF)
        XCTAssertThrowsError(try account.toNEP6Account()) { error in
            XCTAssertEqual(error.localizedDescription, "Account private key is available but not encrypted.")
        }
    }
    
    public func testToNep6AccountWithEncryptedPrivateKey() {
        let account = try! Account.fromWIF(defaultAccountWIF)
        try! account.encryptPrivateKey("neo")
        let nep6 = try! account.toNEP6Account()
        XCTAssertEqual(nep6.contract?.script, defaultAccountVerificationScript.base64Encoded)
        XCTAssertEqual(nep6.key, defaultAccountEncryptedPrivateKey)
        XCTAssertFalse(nep6.isDefault)
        XCTAssertFalse(nep6.lock)
        XCTAssertEqual(nep6.address, defaultAccountAddress)
        XCTAssertEqual(nep6.label, defaultAccountAddress)
    }
    
    public func testToNep6AccountWithMultiSigAccount() {
        let key = try! ECPublicKey(defaultAccountPublicKey.bytesFromHex)
        let account = try! Account.createMultiSigAccount([key], 1)
        let nep6 = try! account.toNEP6Account()
        XCTAssertEqual(nep6.contract?.script, committeeAccountVerificationScript.base64Encoded)
        XCTAssertFalse(nep6.isDefault)
        XCTAssertFalse(nep6.lock)
        XCTAssertEqual(nep6.address, committeeAccountAddress)
        XCTAssertEqual(nep6.label, committeeAccountAddress)
        XCTAssertNil(nep6.key)
        XCTAssertEqual(nep6.contract?.nep6Parameters, [.init(paramName: "signature0", type: .signature)])
    }
    
    public func testCreateAccountFromWIF() {
        let account = try! Account.fromWIF(defaultAccountWIF)
        let expectedKeyPair = try! ECKeyPair.create(privateKey: defaultAccountPrivateKey.bytesFromHex)
        XCTAssertEqual(account.keyPair, expectedKeyPair)
        XCTAssertEqual(account.address, defaultAccountAddress)
        XCTAssertEqual(account.label, defaultAccountAddress)
        XCTAssertNil(account.encryptedPrivateKey)
        XCTAssertEqual(account.scriptHash?.string, defaultAccountScriptHash)
        XCTAssertFalse(account.isDefault)
        XCTAssertFalse(account.isLocked)
        XCTAssertEqual(account.verificationScript?.script, defaultAccountVerificationScript.bytesFromHex)
    }
    
    public func testCreateAccountFromAddress() {
        let account = try! Account.fromAddress(defaultAccountAddress)
        XCTAssertEqual(account.address, defaultAccountAddress)
        XCTAssertEqual(account.label, defaultAccountAddress)
        XCTAssertEqual(account.scriptHash?.string, defaultAccountScriptHash)
        XCTAssertFalse(account.isDefault)
        XCTAssertFalse(account.isLocked)
        XCTAssertNil(account.verificationScript)
    }
    
    public func testGetNep17Balances() async {
        let json = nep17BalancesOfDefaultAccountJson
        let mockUrlSession = MockURLSession().data(json)
        let httpService = HttpService(url: URL(string: "http://127.0.0.1")!, urlSession: mockUrlSession)
        let neoSwift = NeoSwift.build(httpService)
        
        let account = try! Account.fromAddress(defaultAccountAddress)
        let balances = try! await account.getNep17Balances(neoSwift)
        
        XCTAssertEqual(balances.count, 2)
        XCTAssert(try! balances.keys.contains(.init(gasTokenHash)))
        XCTAssert(try! balances.keys.contains(.init(neoTokenHash)))
        XCTAssert(balances.values.contains(300000000))
        XCTAssert(balances.values.contains(5))
    }
    
    public func testIsMultiSig() {
        let a = try! Account.fromAddress(defaultAccountAddress)
        XCTAssertFalse(a.isMultiSig)
        
        let a1 = try! Account.createMultiSigAccount(committeeAccountAddress, 1, 1)
        XCTAssert(a1.isMultiSig)
        
        let a2 = try! Account.fromVerificationScript(VerificationScript(committeeAccountVerificationScript.bytesFromHex))
        XCTAssert(a2.isMultiSig)
        
        let a3 = try! Account.fromVerificationScript(VerificationScript(defaultAccountVerificationScript.bytesFromHex))
        XCTAssertFalse(a3.isMultiSig)
        
        let a4 = try! Account.createMultiSigAccount([.init(defaultAccountPublicKey)], 1)
        XCTAssert(a4.isMultiSig)
    }
    
    public func testUnlock() {
        var account = try! Account.fromAddress(defaultAccountAddress)
        account = account.lock()
        XCTAssert(account.isLocked)
        account.unlock()
        XCTAssertFalse(account.isLocked)
    }
    
    public func testIsDefault() {
        let account = try! Account.fromAddress(defaultAccountAddress)
        let wallet = try! Wallet.create().addAccounts([account])
        XCTAssertFalse(account.isDefault)
        
        _ = try! wallet.defaultAccount(account.getScriptHash())
        XCTAssertTrue(account.isDefault)
    }
    
    public func testWalletLink() {
        let account = try! Account.fromAddress(defaultAccountAddress)
        let wallet = try! Wallet.create()
        XCTAssertNil(account.wallet)
        
        _ = try! wallet.addAccounts([account])
        XCTAssertNotNil(account.wallet)
        XCTAssertIdentical(wallet, account.wallet)
    }
    
    public func testNilValuesWhenNotMultiSig() {
        let account = try! Account.fromAddress(defaultAccountAddress)
        XCTAssertNil(account.signingThreshold)
        XCTAssertNil(account.nrOfParticipants)
    }

    
}
