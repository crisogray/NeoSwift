
public struct Diagnostics: Codable, Hashable {
    
    public let invokedContracts: InvokedContract
    public let storageChanges: [StorageChange]
    
    public init(invokedContracts: InvokedContract, storageChanges: [StorageChange]) {
        self.invokedContracts = invokedContracts
        self.storageChanges = storageChanges
    }
    
    enum CodingKeys: String, CodingKey {
        case invokedContracts = "invokedcontracts"
        case storageChanges = "storagechanges"
    }
    
    public struct InvokedContract: Codable, Hashable {
        
        public let hash: Hash160
        public let invokedContracts: [InvokedContract]?
        
        public init(hash: Hash160, invokedContracts: [InvokedContract]?) {
            self.hash = hash
            self.invokedContracts = invokedContracts
        }
        
        enum CodingKeys: String, CodingKey {
            case hash, invokedContracts = "call"
        }
        
    }
    
    public struct StorageChange: Codable, Hashable {
        
        public let state: String
        public let key: String
        public let value: String
        
        public init(state: String, key: String, value: String) {
            self.state = state
            self.key = key
            self.value = value
        }
        
    }
    
}
