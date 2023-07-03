
public struct NeoAddress: Codable, Hashable {
    
    public let address: String
    public let hasKey: Bool
    public let label: String?
    public let watchOnly: Bool
    
    public init(address: String, hasKey: Bool, label: String?, watchOnly: Bool) {
        self.address = address
        self.hasKey = hasKey
        self.label = label
        self.watchOnly = watchOnly
    }
    
    enum CodingKeys: String, CodingKey {
        case address, label
        case hasKey = "haskey"
        case watchOnly = "watchonly"
    }
    
}
