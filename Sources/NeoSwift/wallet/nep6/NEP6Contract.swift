
public struct NEP6Contract: Codable, Hashable {
    
    public let script: String?
    public let nep6Parameters: [NEP6Parameter]
    public let deployed: Bool
    
    enum CodingKeys: String, CodingKey {
        case script, deployed
        case nep6Parameters = "parameters"
    }
    
    public struct NEP6Parameter: Codable, Hashable {
        
        public let paramName: String
        public let type: ContractParamterType
        
        enum CodingKeys: String, CodingKey {
            case type, paramName = "name"
        }
        
    }
    
}
