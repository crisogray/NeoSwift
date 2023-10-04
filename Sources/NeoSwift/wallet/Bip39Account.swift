
import BIP39

/// Class encapsulating a BIP-39 compatible NEO account.
public class Bip39Account: Account {
    
    /// Generated BIP-39 mnemonic for the account.
    public let mnemonic: String
    
    private init(_ keyPair: ECKeyPair, _ mnemonic: String) throws {
        self.mnemonic = mnemonic
        try super.init(keyPair: keyPair)
    }
    
    /// Generates a BIP-39 compatible NEO account. The private key for the wallet can be calculated using following algorithm:\n
    /// `Key = SHA-256(BIP_39_SEED(mnemonic, password))`
    /// The password will *only* be used as passphrase for BIP-39 seed (i.e., used to recover the account).
    /// - Parameter password: The passphrase with which to encrypt the private key
    /// - Returns: A BIP-39 compatible Neo account
    public static func create(_ password: String) throws -> Bip39Account {
        let m = try Mnemonic(phrase: Mnemonic().phrase, passphrase: password)
        let keyPair = try ECKeyPair.create(privateKey: m.seed.sha256())
        return try .init(keyPair, m.phrase.joined(separator: " "))
    }
    
    /// Recovers a key pair based on BIP-39 mnemonic and password.
    /// - Parameters:
    ///   - password: The passphrase given when the BIP-39 account was generated
    ///   - mnemonic: The generated mnemonic with the given passphrase
    /// - Returns: A Bip39Account builder
    public static func fromBip39Mneumonic(_ password: String, _ mnemonic: String) throws -> Bip39Account {
        let m = try Mnemonic(phrase: mnemonic.split(separator: " ").map(String.init), passphrase: password)
        let keyPair = try ECKeyPair.create(privateKey: m.seed.sha256())
        return try .init(keyPair, mnemonic)
    }
    
}
