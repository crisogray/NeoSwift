
public class NativeContractState: ExpressContractState {
    
    public let id: Int
    public let nef: ContractNef
    public let updateHistory: [Int]
    
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
