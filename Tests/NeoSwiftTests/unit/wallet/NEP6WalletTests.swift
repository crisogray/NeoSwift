
import Foundation
import XCTest
@testable import NeoSwift

class NEP6WalletTests: XCTestCase {
 
    public func testReadWallet() {
        let data = try! Data(contentsOf: Bundle.module.url(forResource: "wallet", withExtension: "json")!)
        let wallet = try! JSONDecoder().decode(NEP6Wallet.self, from: data)
        XCTAssertEqual(wallet.name, "Wallet")
        XCTAssertEqual(wallet.version, Wallet.CURRENT_VERSION)
        XCTAssertEqual(wallet.scrypt, .DEFAULT)
        XCTAssertEqual(wallet.accounts.count, 2)

        let account1 = wallet.accounts[0]
        XCTAssertEqual(account1.address, "NLnyLtep7jwyq1qhNPkwXbJpurC4jUT8ke")
        XCTAssertEqual(account1.label, "Account1")
        XCTAssertTrue(account1.isDefault)
        XCTAssertFalse(account1.lock)
        XCTAssertEqual(account1.key, "6PYVEi6ZGdsLoCYbbGWqoYef7VWMbKwcew86m5fpxnZRUD8tEjainBgQW1")
        XCTAssertNil(account1.extra)
        let contract1 = account1.contract!
        XCTAssertEqual(contract1.script, "DCECJJQloGtaH45hM/x5r6LCuEML+TJyl/F2dh33no2JKcULQZVEDXg=")
        XCTAssertFalse(contract1.isDeployed)
        let parameter1 = contract1.nep6Parameters.first!
        XCTAssertEqual(parameter1.paramName, "signature")
        XCTAssertEqual(parameter1.type, .signature)
        
        let account2 = wallet.accounts[1]
        XCTAssertEqual(account2.address, "NWcx4EfYdfqn5jNjDz8AHE6hWtWdUGDdmy")
        XCTAssertEqual(account2.label, "Account2")
        XCTAssertFalse(account2.isDefault)
        XCTAssertFalse(account2.lock)
        XCTAssertEqual(account2.key, "6PYSQWBqZE5oEFdMGCJ3xR7bz6ezz814oKE7GqwB9i5uhtUzkshe9B6YGB")
        XCTAssertNil(account2.extra)
        
        let contract2 = account2.contract!
        XCTAssertEqual(contract2.script, "DCEDHMqqRt98SU9EJpjIwXwJMR42FcLcBCy9Ov6rpg+kB0ALQZVEDXg=")
        XCTAssertFalse(contract2.isDeployed)
        
        let parameter2 = contract2.nep6Parameters.first!
        XCTAssertEqual(parameter2.paramName, "signature")
        XCTAssertEqual(parameter2.type, .signature)
    }
    
}
