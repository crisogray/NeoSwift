
public class NeoGetPeers: Response<NeoGetPeers.Peers> {
    
    public var peers: Peers? {
        return result
    }
    
    public struct Peers: Codable, Hashable {
        public let connected: [AddressEntry]
        public let bad: [AddressEntry]
        public let unconnected: [AddressEntry]
    }
    
    public struct AddressEntry: Codable, Hashable {
        public let address: String
        public let port: Int
    }
    
}
