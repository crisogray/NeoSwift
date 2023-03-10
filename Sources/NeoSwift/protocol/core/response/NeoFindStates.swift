
public class NeoFindStates: Response<NeoFindStates.States> {
    
    public var states: States? {
        return result
    }
    
    public struct States: Codable, Hashable {
        
        public let firstProof: String?
        public let lastProof: String?
        public let truncated: Bool
        public let results: [Result]

        public struct Result: Codable, Hashable {
            public let key: String
            public let value: String
        }
        
    }
    
}
