

public class NeoGetStateHeight: Response<NeoGetStateHeight.StateHeight> {
    
    public var stateHeight: StateHeight? {
        return result
    }
    
    public struct StateHeight: Codable, Hashable {
        
        public let localRootIndex: Int
        public let validatedRootIndex: Int
        
        enum CodingKeys: String, CodingKey {
            case localRootIndex = "localrootindex"
            case validatedRootIndex = "validatedrootindex"
        }
        
    }
    
}
