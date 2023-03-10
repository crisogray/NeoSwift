
public class NeoListPlugins: Response<[NeoListPlugins.Plugin]> {
    
    public var plugins: [Plugin]? {
        return result
    }
    
    public struct Plugin: Codable, Hashable {
        
        public let name: String
        public let version: String
        public let interfaces: [String]

    }
    
}
