
public class Notification: Codable, Hashable {
    
    public let contract: Hash160
    public let eventName: String
    public let state: StackItem
    
    public init(contract: Hash160, eventName: String, state: StackItem) {
        self.contract = contract
        self.eventName = eventName
        self.state = state
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.contract = try container.decode(Hash160.self, forKey: .contract)
        self.state = try container.decode(StackItem.self, forKey: .state)
        self.eventName = try container.decode(String.self, forKey: .eventName)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.contract, forKey: .contract)
        try container.encode(self.state, forKey: .state)
        try container.encode(self.eventName, forKey: .eventName)
    }

    enum CodingKeys: String, CodingKey {
        case contract, state
        case eventName = "eventname"
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(contract)
        hasher.combine(eventName)
        hasher.combine(state)
    }
    
    public static func == (lhs: Notification, rhs: Notification) -> Bool {
        return lhs.contract == rhs.contract && lhs.eventName == rhs.eventName && lhs.state == rhs.state
    }
    
}
