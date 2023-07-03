
public class NeoListPlugins: Response<[NeoListPlugins.Plugin]> {
    
    public var plugins: [Plugin]? {
        return result
    }
    
    public struct Plugin: Codable, Hashable {
        
        public let name: String
        public let version: String
        public let interfaces: [String]
        
        public init(name: String, version: String, interfaces: [String]) {
            self.name = name
            self.version = version
            self.interfaces = interfaces
        }

    }
    
}
