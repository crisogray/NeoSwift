
public class NeoGetPeers: Response<NeoGetPeers.Peers> {
    
    public var peers: Peers? {
        return result
    }
    
    public struct Peers: Codable, Hashable {
        public let connected: [AddressEntry]
        public let bad: [AddressEntry]
        public let unconnected: [AddressEntry]
        
        public init(connected: [AddressEntry], bad: [AddressEntry], unconnected: [AddressEntry]) {
            self.connected = connected
            self.bad = bad
            self.unconnected = unconnected
        }
        
    }
    
    public struct AddressEntry: Codable, Hashable {
        public let address: String
        public let port: Int
        
        public init(address: String, port: Int) {
            self.address = address
            self.port = port
        }
        
    }
    
}
