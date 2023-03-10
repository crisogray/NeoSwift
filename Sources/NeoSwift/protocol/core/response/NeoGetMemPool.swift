
public class NeoGetMemPool: Response<NeoGetMemPool.MemPoolDetails> {
    
    public var memPoolDetails: MemPoolDetails? {
        return result
    }
    
    public struct MemPoolDetails: Codable, Hashable {
        public let height: Int
        public let verified: [Hash256]
        public let unverified: [Hash256]
    }
    
}
