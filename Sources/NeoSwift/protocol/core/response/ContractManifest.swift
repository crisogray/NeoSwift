
public struct ContractManifest: Codable, Hashable {
    
    public let name: String
    @SingleValueOrNilArray public private(set) var groups: [ContractGroup]
    public let features: [String : AnyHashable]?
    @SingleValueOrNilArray public private(set) var supportedStandards: [String]
    public let abi: ContractABI
    @SingleValueOrNilArray public private(set) var permissions: [ContractPermission]
    @WildcardContainerSerialized @SingleValueOrNilArray public private(set) var trusts: [String]
    public let extra: [String : AnyHashable]?
    
    enum CodingKeys: String, CodingKey {
        case name, groups, features, abi, permissions, trusts, extra
        case supportedStandards = "supportedstandards"
    }
    
    public struct ContractGroup: Codable, Hashable {
        
        public let pubKey: String
        public let signature: String
        
        enum CodingKeys: String, CodingKey {
            case pubKey, _pubKey = "pubkey"
            case signature
        }
    
        init(pubKey: String, signature: String) throws {
            guard pubKey.bytesFromHex.count == NeoConstants.PUBLIC_KEY_SIZE_COMPRESSED else {
                throw "The provided value is not a valid public key: \(pubKey)"
            }
            guard !signature.base64Decoded.isEmpty else {
                throw "Invalid signature: \(signature). Please provide a valid signature in base64 format."
            }
            self.pubKey = pubKey
            self.signature = signature
        }
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            if let pubKey = try? container.decode(String.self, forKey: .pubKey) { self.pubKey = pubKey }
            else { pubKey = try container.decode(String.self, forKey: ._pubKey) }
            signature = try container.decode(String.self, forKey: .signature)
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(pubKey, forKey: .pubKey)
            try container.encode(signature, forKey: .signature)
        }

    }
    
    public struct ContractABI: Codable, Hashable {
        
        public let methods: [ContractMethod]
        public let events: [ContractEvent]
        
        public struct ContractMethod: Codable, Hashable {
            
            public let name: String
            public let parameters: [ContractParameter]
            public let offset: Int
            public let returnType: ContractParamterType
            public let safe: Bool
            
            enum CodingKeys: String, CodingKey {
                case name, parameters, offset, safe
                case returnType = "returntype"
            }
            
        }
        
        public struct ContractEvent: Codable, Hashable {
            public let name: String
            public let parameters: [ContractParameter]
        }
        
    }
    
    public struct ContractPermission: Codable, Hashable {
        public let contract: String
        @SingleValueOrNilArray public private(set) var methods: [String]
    }
    
}

@propertyWrapper
public struct WildcardContainerSerialized: Codable, Hashable {
    
    public var wrappedValue: SingleValueOrNilArray<String>
    
    public init(wrappedValue: SingleValueOrNilArray<String>) {
        self.wrappedValue = wrappedValue
    }
    
    enum CodingKeys: CodingKey {
        case wrappedValue
    }
    
    public init(from decoder: Decoder) throws {
        self.wrappedValue = try SingleValueOrNilArray(from: decoder)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        if wrappedValue.wrappedValue == ["*"] { try container.encode("*") }
        else { try container.encode(wrappedValue.wrappedValue) }
    }
    
}


