
public struct NeoApplicationLog: Codable, Hashable {
    
    public let transactionId: Hash256
    public let executions: [Execution]
    
    enum CodingKeys: String, CodingKey {
        case executions
        case transactionId = "txid"
    }
    
    public struct Execution: Codable, Hashable {
        
        public let trigger: String
        public let state: NeoVMStateType
        public let exception: String?
        public let gasConsumed: String
        public let stack: [StackItem]
        public let notifications: [Notification]
        
        enum CodingKeys: String, CodingKey {
            case trigger, exception, stack, notifications
            case state = "vmstate"
            case gasConsumed = "gasconsumed"
        }
        
    }
    
}
