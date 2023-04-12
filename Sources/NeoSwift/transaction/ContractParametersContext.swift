
public struct ContractParametersContext: Codable {
    
    public let type: String = "Neo.Network.P2P.Payloads.Transaction"
    public let hash: String
    public let data: String
    public let items: [String: ContextItem]
    public let network: Int

    init(hash: String, data: String, items: [String : ContextItem]?, network: Int) {
        self.hash = hash
        self.data = data
        self.items = items ?? [:]
        self.network = network
    }
    
    public struct ContextItem: Codable {
        public let script: String
        public let parameters: [ContractParameter]?
        public let signatures: [String : String]
        
        init(script: String, parameters: [ContractParameter]?, signatures: [String : String]?) {
            self.script = script
            self.parameters = parameters
            self.signatures = signatures ?? [:]
        }
        
    }
    
}
