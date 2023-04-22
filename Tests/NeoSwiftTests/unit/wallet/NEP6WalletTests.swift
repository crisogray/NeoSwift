
import Foundation
import XCTest
@testable import NeoSwift

class NEP6WalletTests: XCTestCase {
 
    let json = """
{
  "name": "Wallet",
  "version": "3.0",
  "scrypt": {
    "n": 16384,
    "r": 8,
    "p": 8
  },
  "accounts": [
    {
      "address": "NLnyLtep7jwyq1qhNPkwXbJpurC4jUT8ke",
      "label": "Account1",
      "isDefault": true,
      "lock": false,
      "key": "6PYVEi6ZGdsLoCYbbGWqoYef7VWMbKwcew86m5fpxnZRUD8tEjainBgQW1",
      "contract": {
        "script": "DCECJJQloGtaH45hM/x5r6LCuEML+TJyl/F2dh33no2JKcULQZVEDXg=",
        "parameters": [
          {
            "name": "signature",
            "type": "Signature"
          }
        ],
        "deployed": false
      },
      "extra": null
    },
    {
      "address": "NWcx4EfYdfqn5jNjDz8AHE6hWtWdUGDdmy",
      "label": "Account2",
      "isdefault": false,
      "lock": false,
      "key": "6PYSQWBqZE5oEFdMGCJ3xR7bz6ezz814oKE7GqwB9i5uhtUzkshe9B6YGB",
      "contract": {
        "script": "DCEDHMqqRt98SU9EJpjIwXwJMR42FcLcBCy9Ov6rpg+kB0ALQZVEDXg=",
        "parameters": [
          {
            "name": "signature",
            "type": "Signature"
          }
        ],
        "deployed": false
      },
      "extra": null
    }
  ],
  "extra": null
}
"""
    
    public func testReadWallet() {
        let wallet = try! JSONDecoder().decode(NEP6Wallet.self, from: json.data(using: .utf8)!)
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
