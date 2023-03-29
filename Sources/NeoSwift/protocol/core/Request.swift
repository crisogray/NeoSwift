
typealias NeoResponse = Response

public struct Request<T, U>: Codable where T: Response<U> {
        
    public let jsonrpc = "2.0"
    public let method: String
    public let params: [AnyHashable]
    public let id: Int
    private var neoSwiftService: NeoSwiftService?
    
    init(method: String, params: [AnyHashable], neoSwiftService: NeoSwiftService) {
        self.method = method
        self.params = params
        self.id = NeoSwiftConfig.REQUEST_COUNTER.getAndIncrement()
        self.neoSwiftService = neoSwiftService
    }
    
    public func send() async throws -> T {
        return try await neoSwiftService!.send(self)
    }
    
    enum CodingKeys: CodingKey {
        case jsonrpc, method, params, id
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(jsonrpc, forKey: .jsonrpc)
        try container.encode(params, forKey: .params)
        try container.encode(id, forKey: .id)
    }
    
}

