
public struct NeoAddress: Codable, Hashable {
    
    public let address: String
    public let hasKey: Bool
    public let label: String?
    public let watchOnly: Bool
    
    enum CodingKeys: String, CodingKey {
        case address, label
        case hasKey = "haskey"
        case watchOnly = "watchonly"
    }
    
}
