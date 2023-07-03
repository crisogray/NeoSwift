
public struct NeoApplicationLog: Codable, Hashable {
    
    public let transactionId: Hash256
    public let executions: [Execution]
    
    public init(transactionId: Hash256, executions: [Execution]) {
        self.transactionId = transactionId
        self.executions = executions
    }
    
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
        
        public init(trigger: String, state: NeoVMStateType, exception: String?, gasConsumed: String, stack: [StackItem], notifications: [Notification]) {
            self.trigger = trigger
            self.state = state
            self.exception = exception
            self.gasConsumed = gasConsumed
            self.stack = stack
            self.notifications = notifications
        }
        
        enum CodingKeys: String, CodingKey {
            case trigger, exception, stack, notifications
            case state = "vmstate"
            case gasConsumed = "gasconsumed"
        }
        
    }
    
}
