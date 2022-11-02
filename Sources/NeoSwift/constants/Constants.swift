
import Foundation
import SwiftECC
import BigInt

struct NeoConstants {
    
    // MARK: Cryptography
    
    static let SECP256R1_DOMAIN: Domain = Domain.instance(curve: .EC256r1)
    static let SECP256R1_HALF_CURVE_ORDER: BInt = SECP256R1_DOMAIN.order >> 1

    // MARK: Accounts, Addresses, Keys

    static let MAX_PUBLIC_KEYS_PER_MULTISIG_ACCOUNT: Int = 1024
    static let HASH160_SIZE: Int = 20
    static let HASH256_SIZE: Int = 32
    static let PRIVATE_KEY_SIZE: Int = 32
    static let PUBLIC_KEY_SIZE_COMPRESSED: Int = 33
    static let SIGNATURE_SIZE: Int = 64
    static let VERIFICATION_SCRIPT_SIZE: Int = 40

    // MARK: Transactions & Contracts

    static let CURRENT_TX_VERSION: Byte = 0
    static let MAX_TRANSACTION_SIZE: Int = 102400;
    static let MAX_TRANSACTION_ATTRIBUTES: Int = 16;
    static let MAX_SIGNER_SUBITEMS: Int = 16;
    static let MAX_MANIFEST_SIZE: Int = 0xFFFF;
    
}
