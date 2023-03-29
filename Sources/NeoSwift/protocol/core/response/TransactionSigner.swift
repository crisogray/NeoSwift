
public struct TransactionSigner: Codable, Hashable {
    
    public let account: Hash160
    @WitnessScopesFromString var scopes: [WitnessScope] = []
    public let allowedContracts: [String]?
    public let allowedGroups: [String]?
    public let rules: [WitnessRule]?
        
    public init(_ signer: Signer) {
        account = signer.signerHash
        scopes = signer.scopes
        allowedContracts = signer.allowedContracts.map(\.string)
        allowedGroups = signer.allowedGroups.compactMap { try? $0.getEncodedCompressedHex() }
        rules = signer.rules
    }
    
    public init(_ account: Hash160, _ scopes: [WitnessScope]) {
        self.account = account
        self.scopes = scopes
        self.allowedContracts = nil
        self.allowedGroups = nil
        self.rules = nil
    }
    
    public init(_ account: Hash160, _ scopes: [WitnessScope], _ allowedContracts: [String],
                _ allowedGroups: [String], _ rules: [WitnessRule]) {
        self.account = account
        self.scopes = scopes
        self.allowedContracts = allowedContracts
        self.allowedGroups = allowedGroups
        self.rules = rules
    }
    
    enum CodingKeys: String, CodingKey {
        case account, scopes, allowedContracts = "allowedcontracts", allowedGroups = "allowedgroups", rules
    }
    
}
