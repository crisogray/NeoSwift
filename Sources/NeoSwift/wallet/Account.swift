
import BigInt

public class Account {
    
    public private(set) var keyPair: ECKeyPair?
    public let address: String
    public private(set) var label: String
    public let verificationScript: VerificationScript?
    public private(set) var isLocked: Bool = false
    public private(set) var encryptedPrivateKey: String? = nil
    public var wallet: Wallet? = nil
    public let signingThreshold: Int?
    public let nrOfParticipants: Int?
    
    public var scriptHash: Hash160? {
        return try? getScriptHash()
    }
    
    public var isDefault: Bool {
        return false // TODO: Wallet isDefault
    }
    
    public var isMultiSig: Bool {
        return signingThreshold != nil && nrOfParticipants != nil
    }
    
    init(address: String, label: String, verificationScript: VerificationScript? = nil, signingThreshold: Int? = nil, nrOfParticipants: Int? = nil) {
        self.address = address
        self.label = label
        self.verificationScript = verificationScript
        self.signingThreshold = signingThreshold
        self.nrOfParticipants = nrOfParticipants
    }

    init(keyPair: ECKeyPair, _ signingThreshold: Int? = nil, nrOfParticipants: Int? = nil) throws {
        self.keyPair = keyPair
        self.address = try keyPair.getAddress()
        self.label = address
        self.verificationScript = try .init(keyPair.publicKey)
        self.signingThreshold = signingThreshold
        self.nrOfParticipants = nrOfParticipants
    }
    
    init(keyPair: ECKeyPair? = nil, address: String, label: String, verificationScript: VerificationScript?, isLocked: Bool, encryptedPrivateKey: String? = nil, wallet: Wallet? = nil, signingThreshold: Int?, nrOfParticipants: Int?) {
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
    
    public func lock() -> Account {
        self.isLocked = true
        return self
    }
    
    public func unlock() {
        self.isLocked = false
    }
    
    public func decryptPrivateKey(_ password: String, _ scryptParams: ScryptParams = .DEFAULT) throws {
        if keyPair != nil { return }
        if encryptedPrivateKey == nil {
            throw "The account does not hold an encrypted private key."
        }
        keyPair = try NEP2.decrypt(password, encryptedPrivateKey!, scryptParams)
    }
    
    public func encryptPrivateKey(_ password: String, _ scryptParams: ScryptParams = .DEFAULT) throws {
        if keyPair == nil {
            throw "The account does not hold a decrypted private key."
        }
        encryptedPrivateKey = try NEP2.encrypt(password, keyPair!, scryptParams)
        keyPair = nil
    }
    
    public func getScriptHash() throws -> Hash160 {
        return try .fromAddress(address)
    }
    
    public func getSigningThreshold() throws -> Int {
        guard isMultiSig, let signingThreshold = signingThreshold else {
            throw "Cannot get signing threshold from account \(address), because it is not multi-sig."
        }
        return signingThreshold
    }
    
    public func getNrOfParticipants() throws -> Int {
        guard isMultiSig, let nrOfParticipants = nrOfParticipants else {
            throw "Cannot get number of participants from account \(address), because it is not multi-sig."
        }
        return nrOfParticipants
    }
    
    public func getNep17Balances(_ neoSwift: NeoSwift) async throws -> [Hash160 : Int] {
        let result = try await neoSwift.getNep17Balances(getScriptHash()).send().getResult().balances
        return try result.reduce(into: [Hash160 : Int]()) { a, b in a[b.assetHash] = try Int(string: b.amount) }
    }
    
    public func toNEP6Account() throws -> NEP6Account {
        if keyPair != nil && encryptedPrivateKey == nil {
            throw "Account private key is available but not encrypted."
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
        let contract = NEP6Contract(script: script, nep6Parameters: parameters, deployed: false)
        return NEP6Account(address: address, label: label, isDefault: isDefault, lock: isLocked, key: encryptedPrivateKey, contract: contract, extra: nil)
    }
    
    public static func fromVerificationScript(_ script: VerificationScript) throws -> Account {
        let address = try Hash160.fromScript(script.script).toAddress()
        var signingThreshold: Int? = nil, nrOfParticipants: Int? = nil
        if script.isMultiSigScript() {
            signingThreshold = try script.getSigningThreshold()
            nrOfParticipants = try script.getNrOfAccounts()
        }
        return Account(address: address, label: address, verificationScript: script, signingThreshold: signingThreshold, nrOfParticipants: nrOfParticipants)
    }
    
    public static func fromPublicKey(_ publicKey: ECPublicKey) throws -> Account {
        let script = try VerificationScript(publicKey)
        let address = try Hash160.fromScript(script.script).toAddress()
        return Account(address: address, label: address, verificationScript: script)
    }
    
    public static func createMultiSigAccount(_ publicKeys: [ECPublicKey], _ signingThreshold: Int) throws -> Account {
        let script = try VerificationScript(publicKeys, signingThreshold)
        let address = try Hash160.fromScript(script.script).toAddress()
        return Account(address: address, label: address, verificationScript: script, signingThreshold: signingThreshold, nrOfParticipants: publicKeys.count)
    }
    
    public static func createMultiSigAccount(_ address: String, _ signingThreshold: Int, _ nrOfParticipants: Int) throws -> Account {
        return Account(address: address, label: address, signingThreshold: signingThreshold, nrOfParticipants: nrOfParticipants)
    }
    
    public static func fromWIF(_ wif: String) throws -> Account {
        let privateKey = try BInt(magnitude: wif.privateKeyFromWIF())
        let keyPair = try ECKeyPair.create(privateKey: privateKey)
        return try Account(keyPair: keyPair)
    }
    
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
    
    public static func fromAddress(_ address: String) throws -> Account {
        if !address.isValidAddress { throw "Invalid address." }
        return Account(address: address, label: address)
    }
    
    public static func fromScriptHash(_ scriptHash: Hash160) throws -> Account {
        return try fromAddress(scriptHash.toAddress())
    }
    
    public static func create() throws -> Account {
        do {
            return try Account(keyPair: .createEcKeyPair())
        } catch {
            throw "Failed to create a new EC key pair."
        }
    }
    
}
