
public class NeoFindStates: Response<NeoFindStates.States> {
    
    public var states: States? {
        return result
    }
    
    public struct States: Codable, Hashable {
        
        public let firstProof: String?
        public let lastProof: String?
        public let truncated: Bool
        public let results: [Result]

        public init(firstProof: String?, lastProof: String?, truncated: Bool, results: [Result]) {
            self.firstProof = firstProof
            self.lastProof = lastProof
            self.truncated = truncated
            self.results = results
        }
        
        public struct Result: Codable, Hashable {
            public let key: String
            public let value: String
        }
        
    }
    
}
