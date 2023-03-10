
public struct Diagnostics: Codable, Hashable {
    
    public let invokedContracts: InvokedContract
    public let storageChanges: [StorageChange]
    
    enum CodingKeys: String, CodingKey {
        case invokedContracts = "invokedcontracts"
        case storageChanges = "storagechanges"
    }
    
    public struct InvokedContract: Codable, Hashable {
        
        public let hash: Hash160
        public let invokedContracts: [InvokedContract]?
        
        enum CodingKeys: String, CodingKey {
            case hash, invokedContracts = "call"
        }
        
    }
    
    public struct StorageChange: Codable, Hashable {
        
        public let state: String
        public let key: String
        public let value: String
        
    }
    
}
