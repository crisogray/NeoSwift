
public struct PopulatedBlocks: Codable, Hashable {
    
    public let cacheId: String
    public let blocks: [Int]
    
    public init(cacheId: String, blocks: [Int]) {
        self.cacheId = cacheId
        self.blocks = blocks
    }
    
}
