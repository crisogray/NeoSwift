
import BIP39

public class Bip39Account: Account {
    
    public let mnemonic: String
    
    private init(_ keyPair: ECKeyPair, _ mnemonic: String) throws {
        self.mnemonic = mnemonic
        try super.init(keyPair: keyPair)
    }
    
    public static func create(_ password: String) throws -> Bip39Account {
        let m = try Mnemonic(phrase: Mnemonic().phrase, passphrase: password)
        let keyPair = try ECKeyPair.create(privateKey: m.seed.sha256())
        return try .init(keyPair, m.phrase.joined(separator: " "))
    }
    
    public static func fromBip39Mneumonic(_ password: String, _ mnemonic: String) throws -> Bip39Account {
        let m = try Mnemonic(phrase: mnemonic.split(separator: " ").map(String.init), passphrase: password)
        let keyPair = try ECKeyPair.create(privateKey: m.seed.sha256())
        return try .init(keyPair, mnemonic)
    }
    
}
