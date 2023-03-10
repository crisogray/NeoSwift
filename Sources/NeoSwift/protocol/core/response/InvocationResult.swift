
public struct InvocationResult: Codable, Hashable {
    
    public let script: String
    public let state: NeoVMStateType
    public let gasConsumed: String
    public let exception: String?
    public let notifications: [Notification]?
    public let diagnostics: Diagnostics?
    public let stack: [StackItem]
    public let tx: String?
    public let pendingSignature: PendingSignature?
    public let sessionId: String?
    
    enum CodingKeys: String, CodingKey {
        case script, state, exception, notifications, diagnostics, stack, tx
        case gasConsumed = "gasconsumed"
        case pendingSignature = "pendingsignature"
        case sessionId = "session"
    }
    
    public struct PendingSignature: Codable, Hashable {
        
        public let type: String
        public let data: String
        public let items: [String : Item]
        public let network: Int
        
        public struct Item: Codable, Hashable {
            
            public let script: String
            public let parameters: [ContractParameter]
            public let signatures: [String : String]
            
        }
        
    }
    
}
