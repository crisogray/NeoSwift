
import Foundation
import SwiftECC
import BigInt

public struct NeoConstants {

    // MARK: Accounts, Addresses, Keys
    
    /// The maximum number of public keys that can take part in a multi-signature address.
    ///
    /// Taken from Neo.SmartContract.Contract.CreateMultiSigRedeemScript(...) in the C# neo repo at [https://github.com/neo-project/neo](https://github.com/neo-project/neo)
    public static let MAX_PUBLIC_KEYS_PER_MULTISIG_ACCOUNT: Int = 1024
    
    /// The byte size of a ``Hash160`` hash.
    public static let HASH160_SIZE: Int = 20
    
    /// The byte size of a ``Hash256`` hash.
    public static let HASH256_SIZE: Int = 32
    
    /// Size of a private key in bytes.
    public static let PRIVATE_KEY_SIZE: Int = 32
    
    /// Size of a compressed public key in bytes.
    public static let PUBLIC_KEY_SIZE_COMPRESSED: Int = 33
    
    /// Size of a signature in bytes.
    public static let SIGNATURE_SIZE: Int = 64
    
    /// Size of a single signature verification script in bytes.
    ///
    /// 1 (PUSHDATA OpCode) + 1 (byte for data length) + 33 (public key) + 1 (SYSCALL Opcode) + 4 (InteropServiceCode) = 41
    public static let VERIFICATION_SCRIPT_SIZE: Int = 40

    // MARK: Transactions & Contracts
    
    /// The current version used for Neo transaction.
    public static let CURRENT_TX_VERSION: Byte = 0
    
    /// The maximum size of a transaction.
    public static let MAX_TRANSACTION_SIZE: Int = 102400
    
    /// The maximum number of attributes that a transaction can have.
    public static let MAX_TRANSACTION_ATTRIBUTES: Int = 16
    
    /// The maximum number of contracts or groups a signer scope can contain.
    public static let MAX_SIGNER_SUBITEMS: Int = 16
    
    /// The maximum byte length for a valid contract manifest.
    public static let MAX_MANIFEST_SIZE: Int = 0xFFFF
    
    /// The default maximum number of iterator items returned in an RPC response.
    public static let MAX_ITERATOR_ITEMS_DEFAULT: Int = 100

    // MARK: Cryptography
    
    private static let DEFAULT_CURVE: ECCurve = .EC256r1
    public private(set) static var SECP256R1_DOMAIN: Domain = .instance(curve: DEFAULT_CURVE)
    static let SECP256R1_HALF_CURVE_ORDER: BInt = SECP256R1_DOMAIN.order >> 1
    
    // MARK: Fot Testing
    
    public static func startUsingCurveForTests(_ instance: ECCurve) {
        SECP256R1_DOMAIN = .instance(curve: instance)
    }
    
    public static func stopUsingOtherCurveForTests() {
        SECP256R1_DOMAIN = .instance(curve: DEFAULT_CURVE)
    }
    
}
