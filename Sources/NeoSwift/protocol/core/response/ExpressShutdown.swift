
public struct ExpressShutdown: Codable, Hashable {

    @StringDecode public private(set) var processId: Int
    
    public init(processId: Int) {
        self.processId = processId
    }
    
    enum CodingKeys: String, CodingKey {
        case processId = "process-id"
    }
    
}
