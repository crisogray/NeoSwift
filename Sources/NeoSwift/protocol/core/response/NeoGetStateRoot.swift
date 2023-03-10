
public class NeoGetStateRoot: Response<NeoGetStateRoot.StateRoot> {
    
    public var stateRoot: StateRoot? {
        return result
    }
    
    public struct StateRoot: Codable, Hashable {
        
        public let version: Int
        public let index: Int
        public let rootHash: Hash256
        public let witnesses: [NeoWitness]
        
        enum CodingKeys: String, CodingKey {
            case version, index, witnesses
            case rootHash = "roothash"
        }
        
    }
    
}
