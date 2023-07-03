
public struct NEP6Contract: Codable, Hashable {
    
    public let script: String?
    public let nep6Parameters: [NEP6Parameter]
    public let isDeployed: Bool
    
    public init(script: String?, nep6Parameters: [NEP6Parameter], isDeployed: Bool) {
        self.script = script
        self.nep6Parameters = nep6Parameters
        self.isDeployed = isDeployed
    }
    
    enum CodingKeys: String, CodingKey {
        case script
        case isDeployed = "deployed"
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
