
import BigInt

/// Represents a Neo account.
///
/// An account can be a single-signature or multi-signature account.
/// The latter does not contain EC key material because it is based on multiple EC key pairs.
public class Account {
    
    /// This account's EC key pair if available. Nil if the key pair is not available, e.g., the account was encrypted.
    public private(set) var keyPair: ECKeyPair?
    public let address: String
    public private(set) var label: String?
    public let verificationScript: VerificationScript?
    public private(set) var isLocked: Bool = false
    public private(set) var encryptedPrivateKey: String? = nil
    public var wallet: Wallet? = nil
    
    /// The signing threshold is nil if the account is single-sig.
    public let signingThreshold: Int?
    
    /// The nr of involved keys is nil if the account is single-sig.
    public let nrOfParticipants: Int?
    
    public var scriptHash: Hash160? {
        return try? getScriptHash()
    }
    
    /// Whether the account is default in the wallet.
    public var isDefault: Bool {
        guard let wallet = wallet else { return false }
        return (try? wallet.isDefault(getScriptHash())) ?? false
    }
    
    /// `true` if this account is a multi-sig account. Otherwise `false`.
    public var isMultiSig: Bool {
        return signingThreshold != nil && nrOfParticipants != nil
    }
    
    /// Constructs a new account with the given EC key pair.
    /// - Parameters:
    ///   - keyPair: The key pair of the account
    ///   - signingThreshold: The signing threshold, nil if the account is single-sig
    ///   - nrOfParticipants: The nr of involved keys, nil if the account is single-sig
    public init(keyPair: ECKeyPair, _ signingThreshold: Int? = nil, nrOfParticipants: Int? = nil) throws {
        self.keyPair = keyPair
        self.address = try keyPair.getAddress()
        self.label = address
        self.verificationScript = try .init(keyPair.publicKey)
        self.signingThreshold = signingThreshold
        self.nrOfParticipants = nrOfParticipants
    }
    
    public init(address: String, label: String?, verificationScript: VerificationScript? = nil, signingThreshold: Int? = nil, nrOfParticipants: Int? = nil) {
        self.address = address
        self.label = label
        self.verificationScript = verificationScript
        self.signingThreshold = signingThreshold
        self.nrOfParticipants = nrOfParticipants
    }
    
    public init(keyPair: ECKeyPair? = nil, address: String, label: String?, verificationScript: VerificationScript?, isLocked: Bool, encryptedPrivateKey: String? = nil, wallet: Wallet? = nil, signingThreshold: Int?, nrOfParticipants: Int?) {
        self.keyPair = keyPair
        self.address = address
        self.label = label
        self.verificationScript = verificationScript
        self.isLocked = isLocked
        self.encryptedPrivateKey = encryptedPrivateKey
        self.wallet = wallet
        self.signingThreshold = signingThreshold
        self.nrOfParticipants = nrOfParticipants
    }
    
    public func label(_ label: String) -> Account {
        self.label = label
        return self
    }
    
    public func wallet(_ wallet: Wallet?) -> Account {
        self.wallet = wallet
        return self
    }
    
    public func lock() -> Account {
        self.isLocked = true
        return self
    }
    
    public func unlock() {
        self.isLocked = false
    }
    
    /// Decrypts this account's private key, according to the NEP-2 standard, if not already decrypted. Uses the default Scrypt parameters.
    /// - Parameters:
    ///   - password: The passphrase used to decrypt this account's private key
    ///   - scryptParams: The Scrypt parameters used for decryption
    public func decryptPrivateKey(_ password: String, _ scryptParams: ScryptParams = .DEFAULT) throws {
        if keyPair != nil { return }
        if encryptedPrivateKey == nil {
            throw WalletError.accountState("The account does not hold an encrypted private key.")
        }
        keyPair = try NEP2.decrypt(password, encryptedPrivateKey!, scryptParams)
    }
    
    /// Encrypts this account's private key according to the NEP-2 standard using the default Scrypt parameters.
    /// - Parameters:
    ///   - password: The passphrase used to encrypt this account's private key
    ///   - scryptParams: The Scrypt parameters used for encryption
    public func encryptPrivateKey(_ password: String, _ scryptParams: ScryptParams = .DEFAULT) throws {
        if keyPair == nil {
            throw WalletError.accountState("The account does not hold a decrypted private key.")
        }
        encryptedPrivateKey = try NEP2.encrypt(password, keyPair!, scryptParams)
        keyPair = nil
    }
    
    public func getScriptHash() throws -> Hash160 {
        return try .fromAddress(address)
    }
    
    public func getSigningThreshold() throws -> Int {
        guard isMultiSig, let signingThreshold = signingThreshold else {
            throw WalletError.accountState("Cannot get signing threshold from account \(address), because it is not multi-sig.")
        }
        return signingThreshold
    }
    
    public func getNrOfParticipants() throws -> Int {
        guard isMultiSig, let nrOfParticipants = nrOfParticipants else {
            throw WalletError.accountState("Cannot get number of participants from account \(address), because it is not multi-sig.")
        }
        return nrOfParticipants
    }
    
    /// Gets the balances of all NEP-17 tokens that this account owns.
    ///
    /// The token amounts are returned in token fractions. E.g., an amount of 1 GAS is returned as 1*10^8 GAS fractions.
    ///
    /// Requires on a neo-node with the RpcNep17Tracker plugin installed. The balances are not cached locally.
    /// Every time this method is called a request is send to the neo-node.
    /// - Parameter neoSwift: The ``NeoSwift/NeoSwift`` object used to call the neo node
    /// - Returns: The map of token script hashes to token amounts
    public func getNep17Balances(_ neoSwift: NeoSwift) async throws -> [Hash160 : Int] {
        let result = try await neoSwift.getNep17Balances(getScriptHash()).send().getResult().balances
        return try result.reduce(into: .init()) { a, b in a[b.assetHash] = try Int(string: b.amount) }
    }
    
    public func toNEP6Account() throws -> NEP6Account {
        if keyPair != nil && encryptedPrivateKey == nil {
            throw WalletError.accountState("Account private key is available but not encrypted.")
        }
        guard let verificationScript = verificationScript else {
            return NEP6Account(address: address, label: label, isDefault: isDefault, lock: isLocked, key: encryptedPrivateKey, contract: nil, extra: nil)
        }
        var parameters = [NEP6Contract.NEP6Parameter]()
        if verificationScript.isMultiSigScript() {
            for i in 0..<(try verificationScript.getNrOfAccounts()) {
                parameters.append(.init(paramName: "signature\(i)", type: .signature))
            }
        } else if verificationScript.isSingleSigScript() {
            parameters.append(.init(paramName: "signature", type: .signature))
        }
        let script = verificationScript.script.base64Encoded
        let contract = NEP6Contract(script: script, nep6Parameters: parameters, isDeployed: false)
        return NEP6Account(address: address, label: label, isDefault: isDefault, lock: isLocked, key: encryptedPrivateKey, contract: contract, extra: nil)
    }
    
    /// Creates an account from the given verification script.
    /// - Parameter script: The verification script
    /// - Returns: The account with a verification script
    public static func fromVerificationScript(_ script: VerificationScript) throws -> Account {
        let address = try Hash160.fromScript(script.script).toAddress()
        var signingThreshold: Int? = nil, nrOfParticipants: Int? = nil
        if script.isMultiSigScript() {
            signingThreshold = try script.getSigningThreshold()
            nrOfParticipants = try script.getNrOfAccounts()
        }
        return Account(address: address, label: address, verificationScript: script, signingThreshold: signingThreshold, nrOfParticipants: nrOfParticipants)
    }
    
    /// Creates an account from the given public key.
    ///
    /// Derives the verification script from the public key, which is needed to calculate the network fee of a transaction.
    /// - Parameter publicKey: The public key
    /// - Returns: The account with a verification script
    public static func fromPublicKey(_ publicKey: ECPublicKey) throws -> Account {
        let script = try VerificationScript(publicKey)
        let address = try Hash160.fromScript(script.script).toAddress()
        return Account(address: address, label: address, verificationScript: script)
    }
    
    /// Creates a multi-sig account from the given public keys. Mind that the ordering of the keys is important for later usage of the account.
    /// - Parameters:
    ///   - publicKeys: The public keys from which to derive the multi-sig account
    ///   - signingThreshold: The number of signatures needed when using this account for signing transactions
    /// - Returns: The multi-sig account
    public static func createMultiSigAccount(_ publicKeys: [ECPublicKey], _ signingThreshold: Int) throws -> Account {
        let script = try VerificationScript(publicKeys, signingThreshold)
        let address = try Hash160.fromScript(script.script).toAddress()
        return Account(address: address, label: address, verificationScript: script, signingThreshold: signingThreshold, nrOfParticipants: publicKeys.count)
    }
    
    /// Creates a multi-sig account holding the given address.
    /// - Parameters:
    ///   - address: The address of the multi-sig account
    ///   - signingThreshold: The number of signatures needed when using this account for signing transactions
    ///   - nrOfParticipants: The number of participating accounts
    /// - Returns: The multi-sig account
    public static func createMultiSigAccount(_ address: String, _ signingThreshold: Int, _ nrOfParticipants: Int) throws -> Account {
        return Account(address: address, label: address, signingThreshold: signingThreshold, nrOfParticipants: nrOfParticipants)
    }
    
    /// Creates an account from the given WIF.
    /// - Parameter wif: The WIF of the account
    /// - Returns: The account
    public static func fromWIF(_ wif: String) throws -> Account {
        let privateKey = try BInt(magnitude: wif.privateKeyFromWIF())
        let keyPair = try ECKeyPair.create(privateKey: privateKey)
        return try Account(keyPair: keyPair)
    }
    
    /// Creates an account from the provided NEP-6 account.
    /// - Parameter nep6Acct: The account in NEP-6 format
    /// - Returns: The account
    public static func fromNEP6Account(_ nep6Acct: NEP6Account) throws -> Account {
        var verificationScript: VerificationScript? = nil
        var signingThreshold: Int? = nil, nrOfParticipants: Int? = nil
        if let contract = nep6Acct.contract, let script = contract.script, !script.isEmpty {
            verificationScript = VerificationScript(script.base64Decoded)
            if verificationScript!.isMultiSigScript() {
                signingThreshold = try verificationScript!.getSigningThreshold()
                nrOfParticipants = try verificationScript!.getNrOfAccounts()
            }
        }
        return Account(address: nep6Acct.address, label: nep6Acct.label, verificationScript: verificationScript, isLocked: nep6Acct.lock,
                       encryptedPrivateKey: nep6Acct.key, signingThreshold: signingThreshold, nrOfParticipants: nrOfParticipants)
    }
    
    /// Creates an account from the given address.
    ///
    /// Note that an account created with this method does not contain a verification script nor an EC key pair.
    /// Therefore, it cannot be used for transaction signing.
    ///
    /// Don't use this method for creating a multi-sig account from an address. Use ``Account/createMultiSigAccount(_:_:_:)`` instead.
    /// - Parameter address: The address of the account. Must be a valid Neo address.
    /// Make sure that the address version used in this address is the same as the one configured in ``NeoSwiftConfig/addressVersion``.
    /// - Returns: The account
    public static func fromAddress(_ address: String) throws -> Account {
        if !address.isValidAddress { throw NeoSwiftError.illegalArgument("Invalid address.") }
        return Account(address: address, label: address)
    }
    
    /// Creates an account from the given script hash.
    ///
    /// Note that an account created with this method does not contain a verification script nor an EC key pair.
    /// Therefore, it cannot be used for transaction signing.
    /// - Parameter scriptHash: The script hash of the account
    /// - Returns: The account
    public static func fromScriptHash(_ scriptHash: Hash160) throws -> Account {
        return try fromAddress(scriptHash.toAddress())
    }
    
    /// Creates a new account with a fresh key pair.
    /// - Returns: The new account
    public static func create() throws -> Account {
        do {
            return try Account(keyPair: .createEcKeyPair())
        } catch {
            throw NeoSwiftError.runtime("Failed to create a new EC key pair.")
        }
    }
    
}
