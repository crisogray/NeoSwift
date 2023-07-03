
public class NeoGetUnclaimedGas: Response<NeoGetUnclaimedGas.GetUnclaimedGas> {
    
    public var unclaimedGas: GetUnclaimedGas? {
        return result
    }
    
    public struct GetUnclaimedGas: Codable, Hashable {
        
        public let unclaimed: String
        public let address: String
        
        public init(unclaimed: String, address: String) {
            self.unclaimed = unclaimed
            self.address = address
        }
        
    }
    
}

