
public class ContractState: ExpressContractState {
    
    public let id: Int
    public let nef: ContractNef
    public let updateCounter: Int
    
    init(id: Int, updateCounter: Int, hash: Hash160, nef: ContractNef, manifest: ContractManifest) {
        self.id = id
        self.nef = nef
        self.updateCounter = updateCounter
        super.init(hash: hash, manifest: manifest)
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(SafeDecode<Int>.self, forKey: .id).value
        nef = try container.decode(ContractNef.self, forKey: .nef)
        updateCounter = try container.decode(SafeDecode<Int>.self, forKey: .updateCounter).value
        try super.init(from: decoder)
    }
    
    enum CodingKeys: String, CodingKey {
        case hash, manifest, id, nef
        case updateCounter = "updatecounter"
    }
    
    public static func == (lhs: ContractState, rhs: ContractState) -> Bool {
        return lhs.id == rhs.id && lhs.nef == rhs.nef && lhs.updateCounter == rhs.updateCounter && lhs.hash == rhs.hash && lhs.manifest == rhs.manifest
    }
    
    public override func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(nef)
        hasher.combine(updateCounter)
        super.hash(into: &hasher)
    }
    
}
