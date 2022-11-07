
import Foundation
import SwiftECC
import BigInt

struct NeoConstants {
    
    // MARK: Cryptography
    
    private(set) public static var SECP256R1_DOMAIN: Domain = .instance(curve: .EC256r1)
    static let SECP256R1_HALF_CURVE_ORDER: BInt = SECP256R1_DOMAIN.order >> 1

    // MARK: Accounts, Addresses, Keys

    public static let MAX_PUBLIC_KEYS_PER_MULTISIG_ACCOUNT: Int = 1024
    public static let HASH160_SIZE: Int = 20
    public static let HASH256_SIZE: Int = 32
    public static let PRIVATE_KEY_SIZE: Int = 32
    public static let PUBLIC_KEY_SIZE_COMPRESSED: Int = 33
    public static let SIGNATURE_SIZE: Int = 64
    public static let VERIFICATION_SCRIPT_SIZE: Int = 40

    // MARK: Transactions & Contracts

    public static let CURRENT_TX_VERSION: Byte = 0
    public static let MAX_TRANSACTION_SIZE: Int = 102400
    public static let MAX_TRANSACTION_ATTRIBUTES: Int = 16
    public static let MAX_SIGNER_SUBITEMS: Int = 16
    public static let MAX_MANIFEST_SIZE: Int = 0xFFFF
    
    public static func startUsingK1CurveForTests() {
        SECP256R1_DOMAIN = .instance(curve: .EC256k1)
    }
    
    public static func stopUsingK1CurveForTests() {
        SECP256R1_DOMAIN = .instance(curve: .EC256r1)
    }
    
}
