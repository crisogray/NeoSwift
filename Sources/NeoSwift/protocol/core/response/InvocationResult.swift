
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
    
    public var hasStateFault: Bool {
        return state == .fault
    }
    
    public init(script: String, state: NeoVMStateType, gasConsumed: String, exception: String?, notifications: [Notification]?, diagnostics: Diagnostics?, stack: [StackItem], tx: String?, pendingSignature: PendingSignature?, sessionId: String?) {
        self.script = script
        self.state = state
        self.gasConsumed = gasConsumed
        self.exception = exception
        self.notifications = notifications
        self.diagnostics = diagnostics
        self.stack = stack
        self.tx = tx
        self.pendingSignature = pendingSignature
        self.sessionId = sessionId
    }
    
    public func getFirstStackItem() throws -> StackItem {
        guard let item = stack.first else {
            throw NeoSwiftError.indexOutOfBounds("The stack is empty. This means that no items were left on the NeoVM stack after this invocation.")
        }
        return item
    }
    
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
        
        public init(type: String, data: String, items: [String : Item], network: Int) {
            self.type = type
            self.data = data
            self.items = items
            self.network = network
        }
        
        public struct Item: Codable, Hashable {
            
            public let script: String
            public let parameters: [ContractParameter]
            public let signatures: [String : String]
            
            public init(script: String, parameters: [ContractParameter], signatures: [String : String]) {
                self.script = script
                self.parameters = parameters
                self.signatures = signatures
            }
            
        }
        
    }
    
}
