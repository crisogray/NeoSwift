
public class ExpressContractState: Codable, Hashable {
    
    public let hash: Hash160
    public let manifest: ContractManifest
    
    init(hash: Hash160, manifest: ContractManifest) {
        self.hash = hash
        self.manifest = manifest
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        hash = try container.decode(Hash160.self, forKey: .hash)
        manifest = try container.decode(ContractManifest.self, forKey: .manifest)
    }
    
    enum CodingKeys: CodingKey {
        case hash, manifest
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.hash, forKey: .hash)
        try container.encode(self.manifest, forKey: .manifest)
    }
    
    public static func == (lhs: ExpressContractState, rhs: ExpressContractState) -> Bool {
        return lhs.hash == rhs.hash && lhs.manifest == rhs.manifest
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(hash)
        hasher.combine(manifest)
    }
    
}
