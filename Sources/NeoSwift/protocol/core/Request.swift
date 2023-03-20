
typealias NeoResponse = Response

public struct Request<T, U> where T: Response<U> {
        
    public let jsonrpc = "2.0"
    public let method: String
    public let params: [AnyHashable]
    public let id: Int
    private let neoSwiftService: NeoSwiftService?
    
    init(method: String, params: [AnyHashable], neoSwiftService: NeoSwiftService?) {
        self.method = method
        self.params = params
        self.id = NeoConfig.requestCounter.getAndIncrement()
        self.neoSwiftService = neoSwiftService
    }
    
    public func send() throws -> T {
        return try neoSwiftService!.send(self)
    }
    
    public func sendAsync(_ callback: @escaping (T?, Error?) -> Void) {
        neoSwiftService!.sendAsync(self, callback)
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

