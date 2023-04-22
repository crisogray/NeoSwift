
import XCTest
@testable import NeoSwift

class WalletTests: XCTestCase {
    
    public func testCreateDefaultWallet() {
        let wallet = try! Wallet.create()
        XCTAssertEqual(wallet.name, "NeoSwiftWallet")
        XCTAssertEqual(wallet.version, Wallet.CURRENT_VERSION)
        XCTAssertFalse(wallet.accounts.isEmpty)
    }
    
    public func testCreateWalletWithAccounts() {
        let account1 = try! Account.create()
        let account2 = try! Account.create()
        let wallet = try! Wallet.withAccounts([account1, account2])
        XCTAssertIdentical(account1, wallet.defaultAccount)
        XCTAssertEqual(wallet.accounts.count, 2)
        XCTAssert(wallet.accounts.contains(where: { $0 === account1 }))
        XCTAssert(wallet.accounts.contains(where: { $0 === account2 }))
    }
    
    public func testCreateWalletWithAccounts_noAccounts() {
        XCTAssertThrowsError(try _ = Wallet.withAccounts([])) { error in
            XCTAssertEqual(error.localizedDescription, "No accounts provided to initialize a wallet.")
        }
    }
    
    public func testIsDefault_account() {
        let account = try! Account.create()
        let wallet = try! Wallet.withAccounts([account])
        XCTAssert(wallet.isDefault(account))
    }
    
    public func testHoldsAccount() {
        let account = try! Account.create()
        let wallet = try! Wallet.create()
        _ = try! wallet.addAccounts([account])
        XCTAssert(try! wallet.holdsAccount(account.getScriptHash()))
        
        _ = try! wallet.removeAccount(account)
        XCTAssertFalse(try! wallet.holdsAccount(account.getScriptHash()))
    }
    
    // TODO: NEP6File tests
    
    public func testAddAccount() {
        let account = try! Account.create()
        let wallet = try! Wallet.create()
        _ = try! wallet.addAccounts([account])
        XCTAssertEqual(wallet.accounts.count, 2)
        XCTAssertIdentical(wallet.getAccount(account.scriptHash!), account)
    }
    
    public func testAddSameAccount() {
        let account = try! Account.create()
        let wallet = try! Wallet.create()
        _ = try! wallet.addAccounts([account])
        _ = try! wallet.addAccounts([account])
        XCTAssertEqual(wallet.accounts.count, 2)
        XCTAssertIdentical(wallet.getAccount(account.scriptHash!), account)
    }
    
    public func testAddDuplicateAccount() {
        let account = try! Account.create()
        let wallet = try! Wallet.create()
        _ = try! wallet.addAccounts([account])
        _ = try! wallet.addAccounts([.init(keyPair: account.keyPair!)])
        XCTAssertEqual(wallet.accounts.count, 2)
        XCTAssertIdentical(wallet.getAccount(account.scriptHash!), account)
    }
    
    public func testAddAccountContainedInAnotherWallet() {
        let account = try! Account.create()
        _ = try! Wallet.create().addAccounts([account])
        let wallet2 = try! Wallet.create()
        XCTAssertThrowsError(try wallet2.addAccounts([account])) { error in
            XCTAssert(error.localizedDescription.contains("is already contained in a wallet."))
        }
    }
    
    public func testRemoveAccounts() {
        let address = "NWcx4EfYdfqn5jNjDz8AHE6hWtWdUGDdmy"
        let wallet = try! Wallet.create()
        XCTAssertFalse(try! wallet.removeAccount(Account.fromAddress(address)))
        
        let account1 = try! Account.create()
        let account2 = try! Account.create()
        _ = try! wallet.addAccounts([account1, account2])
        XCTAssert(try! wallet.removeAccount(account1))
        XCTAssert(try! wallet.removeAccount(account2.scriptHash!))
    }
    
    public func testRemoveAccounts_accountParam() {
        let account1 = try! Account.create()
        let account2 = try! Account.create()
        let wallet = try! Wallet.withAccounts([account1, account2])
        XCTAssertEqual(wallet.accounts.count, 2)
        XCTAssert(try! wallet.removeAccount(account1))
        XCTAssertEqual(wallet.accounts.count, 1)
        XCTAssertIdentical(wallet.accounts.first!, account2)
    }
    
    public func testRemoveAccounts_defaultAccount() {
        let account1 = try! Account.create()
        let account2 = try! Account.create()
        let wallet = try! Wallet.withAccounts([account1, account2])
        XCTAssertEqual(wallet.accounts.count, 2)
        XCTAssertIdentical(wallet.defaultAccount, account1)
        _ = try! wallet.removeAccount(account1)
        XCTAssertEqual(wallet.accounts.count, 1)
        XCTAssertIdentical(wallet.defaultAccount, account2)
    }
    
    public func testRemoveAccounts_lastRemainingAccount() {
        let wallet = try! Wallet.create()
        let lastAccount = wallet.accounts.first!
        XCTAssertIdentical(wallet, lastAccount.wallet)
        XCTAssertIdentical(lastAccount, wallet.defaultAccount)
        XCTAssertThrowsError(try wallet.removeAccount(lastAccount)) { error in
            XCTAssert(error.localizedDescription.contains("is the only account in the wallet. It cannot be removed."))
        }
    }
    
    public func testDefaultWalletToNEP6Wallet() {
        let walletName = "TestWallet"
        let account = try! Account.create()
        let wallet = try! Wallet.withAccounts([account]).name(walletName)
        try! wallet.encryptAllAccounts("12345678")
        
        let nep6Account = NEP6Account(address: account.address, label: account.label, isDefault: false,
                                      lock: false, key: account.encryptedPrivateKey, contract: nil, extra: nil)
        let nep6Wallet = NEP6Wallet(name: walletName, version: Wallet.CURRENT_VERSION, scrypt: .DEFAULT, accounts: [nep6Account], extra: nil)
        XCTAssertEqual(try! wallet.toNEP6Wallet(), nep6Wallet)
    }
    
    public func testToNEP6WalletWithUnencryptedPrivateKey() {
        let account = try! Account.create()
        let wallet = try! Wallet.withAccounts([account])
        XCTAssertThrowsError(try _ = wallet.toNEP6Wallet()) { error in
            XCTAssertEqual(error.localizedDescription, "Account private key is available but not encrypted.")
        }
    }
    
    // TODO: NEP6 File Tests
    
    public func testCreateGenericWallet() {
        let wallet = try! Wallet.create()
        XCTAssertEqual(wallet.name, "NeoSwiftWallet")
        XCTAssertEqual(wallet.version, Wallet.CURRENT_VERSION)
        XCTAssertEqual(wallet.scryptParams, .DEFAULT)
        XCTAssertEqual(wallet.accounts.count, 1)
        XCTAssertNotNil(wallet.accounts.first?.keyPair)
    }
    
    // TODO: More NEP6 File Tests

    public func testCreateGenericWalletWithPassword() {
        let wallet = try! Wallet.create("12345678")
        XCTAssertEqual(wallet.name, "NeoSwiftWallet")
        XCTAssertEqual(wallet.version, Wallet.CURRENT_VERSION)
        XCTAssertEqual(wallet.scryptParams, .DEFAULT)
        XCTAssertEqual(wallet.accounts.count, 1)
        XCTAssertNotNil(wallet.accounts.first?.encryptedPrivateKey)
        XCTAssertNil(wallet.accounts.first?.keyPair)
        
        try! wallet.decryptAllAccounts("12345678")
        XCTAssertNotNil(wallet.accounts.first?.keyPair)
        XCTAssertNotNil(wallet.accounts.first?.encryptedPrivateKey)
    }
    
    public func testGetAndSetDefaultAccount() {
        let wallet = try! Wallet.create()
        XCTAssertNotNil(wallet.defaultAccount)
        
        let account = try! Account.create()
        _ = try! wallet.addAccounts([account]).defaultAccount(account)
        XCTAssertNotNil(wallet.defaultAccount)
        XCTAssertIdentical(wallet.defaultAccount, account)
    }
    
    public func testFailSettingDefaultAccountNotContainedInWallet() {
        let wallet = try! Wallet.create()
        let account = try! Account.create()
        XCTAssertThrowsError(try _ = wallet.defaultAccount(account)) { error in
            XCTAssert(error.localizedDescription.contains("Wallet does not contain the account"))
        }
    }
    
    public func testEncryptWallet() {
        let wallet = try! Wallet.create()
        _ = try! wallet.addAccounts([.create()])
        XCTAssertNotNil(wallet.accounts[0].keyPair)
        XCTAssertNotNil(wallet.accounts[1].keyPair)
        try! wallet.encryptAllAccounts("pw")
        XCTAssertNil(wallet.accounts[0].keyPair)
        XCTAssertNil(wallet.accounts[1].keyPair)
    }
    
    public func testGetNep17Balances() async {
        let defaultJson = nep17BalancesOfDefaultAccountJson.data(using: .utf8)!
        let committeeJson = nep17BalancesOfCommitteeAccountJson.data(using: .utf8)!
        let mockUrlSession = MockURLSession().data(committeeJson, defaultJson)
        let httpService = HttpService(url: URL(string: "http://127.0.0.1")!, urlSession: mockUrlSession)
        let neoSwift = NeoSwift.build(httpService)
        
        let account1 = try! Account.fromAddress(committeeAccountAddress)
        let account2 = try! Account.fromAddress(defaultAccountAddress)
        let wallet = try! Wallet.withAccounts([account1, account2])
        let balances = try! await wallet.getNep17TokenBalances(neoSwift)
        
        XCTAssertEqual(balances.count, 2)
        XCTAssert(try! balances.keys.contains(.init(gasTokenHash)))
        XCTAssert(try! balances.keys.contains(.init(neoTokenHash)))
        XCTAssert(balances.values.contains(411285799730))
        XCTAssert(balances.values.contains(50000000))
    }
    
}
