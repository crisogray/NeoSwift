
public class NativeContractState: ExpressContractState {
    
    public let id: Int
    public let nef: ContractNef
    public let updateHistory: [Int]
    
    public init(id: Int, hash: Hash160, nef: ContractNef, manifest: ContractManifest, updateHistory: [Int]) {
        self.id = id
        self.nef = nef
        self.updateHistory = updateHistory
        super.init(hash: hash, manifest: manifest)
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(SafeDecode<Int>.self, forKey: .id).value
        nef = try container.decode(ContractNef.self, forKey: .nef)
        updateHistory = try container.decode([Int].self, forKey: .updateHistory)
        try super.init(from: decoder)
    }
    
    enum CodingKeys: String, CodingKey {
        case hash, manifest, id, nef
        case updateHistory = "updatehistory"
    }
    
}
