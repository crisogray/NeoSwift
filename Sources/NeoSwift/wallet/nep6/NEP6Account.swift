
public struct NEP6Account: Codable, Hashable {
    
    public let address: String
    public let label: String?
    public let isDefault: Bool
    public let lock: Bool
    public let key: String?
    public let contract: NEP6Contract?
    public let extra: [String : AnyHashable]?
    
    init(address: String, label: String?, isDefault: Bool, lock: Bool, key: String?, contract: NEP6Contract?, extra: [String : AnyHashable]?) {
        self.address = address
        self.label = label
        self.isDefault = isDefault
        self.lock = lock
        self.key = key
        self.contract = contract
        self.extra = extra
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.address = try container.decode(String.self, forKey: .address)
        self.label = try? container.decode(String.self, forKey: .label)
        self.isDefault = try (try? container.decode(Bool.self, forKey: .isDefault)) ?? container.decode(Bool.self, forKey: ._isDefault)
        self.lock = try container.decode(Bool.self, forKey: .lock)
        self.key = try? container.decode(String.self, forKey: .key)
        self.contract = try? container.decode(NEP6Contract.self, forKey: .contract)
        self.extra = try container.decodeIfPresent([String : AnyHashable].self, forKey: .extra)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.address, forKey: .address)
        try container.encode(self.label, forKey: .label)
        try container.encode(self.isDefault, forKey: .isDefault)
        try container.encode(self.lock, forKey: .lock)
        try container.encode(self.key, forKey: .key)
        try container.encode(self.contract, forKey: .contract)
        try container.encodeIfPresent(self.extra, forKey: .extra)
    }

    enum CodingKeys: String, CodingKey {
        case address, label, lock, key, contract, extra, isDefault
        case _isDefault = "isdefault"
    }
    
    public static func == (lhs: NEP6Account, rhs: NEP6Account) -> Bool {
        return lhs.address == rhs.address
    }
    
}
