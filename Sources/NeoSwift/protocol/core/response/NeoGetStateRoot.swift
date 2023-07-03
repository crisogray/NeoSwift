
public class NeoGetStateRoot: Response<NeoGetStateRoot.StateRoot> {
    
    public var stateRoot: StateRoot? {
        return result
    }
    
    public struct StateRoot: Codable, Hashable {
        
        public let version: Int
        public let index: Int
        public let rootHash: Hash256
        public let witnesses: [NeoWitness]
        
        public init(version: Int, index: Int, rootHash: Hash256, witnesses: [NeoWitness]) {
            self.version = version
            self.index = index
            self.rootHash = rootHash
            self.witnesses = witnesses
        }
        
        enum CodingKeys: String, CodingKey {
            case version, index, witnesses
            case rootHash = "roothash"
        }
        
    }
    
}
