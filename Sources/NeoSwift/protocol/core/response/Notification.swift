
public struct Notification: Codable, Hashable {
    
    public let contract: Hash160
    public let eventName: String
    public let state: StackItem
    
    enum CodingKeys: String, CodingKey {
        case contract, state
        case eventName = "eventname"
    }
    
}
