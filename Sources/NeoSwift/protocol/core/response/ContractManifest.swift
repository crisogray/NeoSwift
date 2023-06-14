
public struct ContractManifest: Codable, Hashable {
    
    public let name: String?
    @SingleValueOrNilArray public var groups: [ContractGroup]
    public private(set) var features: [String : AnyHashable]?
    @SingleValueOrNilArray public private(set) var supportedStandards: [String]
    public let abi: ContractABI?
    @SingleValueOrNilArray public private(set) var permissions: [ContractPermission]
    @WildcardContainerSerialized @SingleValueOrNilArray public private(set) var trusts: [String]
    public let extra: [String : AnyHashable]?
    
    public init(name: String? = nil, groups: [ContractGroup] = [], features: [String : AnyHashable] = [:], supportedStandards: [String] = [], abi: ContractABI? = nil, permissions: [ContractPermission] = [], trusts: [String] = [], extra: [String : AnyHashable]? = nil) {
        self.name = name
        self.groups = groups
        self.features = features
        self.supportedStandards = supportedStandards
        self.abi = abi
        self.permissions = permissions
        self.trusts = trusts
        self.extra = extra
    }
    
    enum CodingKeys: String, CodingKey {
        case name, groups, features, abi, permissions, trusts, extra
        case supportedStandards = "supportedstandards"
    }
    
    public func createGroup(_ groupECKeyPair: ECKeyPair, _ deploymentSender: Hash160, _ nefCheckSum: Int) throws -> ContractGroup {
        let contractHashBytes = try ScriptBuilder.buildContractHashScript(deploymentSender, nefCheckSum, name ?? "")
        let signatureData = try Sign.signMessage(contractHashBytes, groupECKeyPair)
        return try ContractGroup(pubKey: groupECKeyPair.publicKey.getEncodedCompressedHex(), signature: signatureData.concatenated.base64Encoded)
    }
    
    public struct ContractGroup: Codable, Hashable {
        
        public let pubKey: String
        public let signature: String
        
        enum CodingKeys: String, CodingKey {
            case pubKey, _pubKey = "pubkey"
            case signature
        }
    
        public init(pubKey: String, signature: String) throws {
            let pubKey = pubKey.cleanedHexPrefix
            guard pubKey.bytesFromHex.count == NeoConstants.PUBLIC_KEY_SIZE_COMPRESSED else {
                throw NeoSwiftError.illegalArgument("The provided value is not a valid public key: \(pubKey)")
            }
            guard !signature.base64Decoded.isEmpty else {
                throw NeoSwiftError.illegalArgument("Invalid signature: \(signature). Please provide a valid signature in base64 format.")
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
        @WildcardContainerSerialized @SingleValueOrNilArray public private(set) var methods: [String]
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


