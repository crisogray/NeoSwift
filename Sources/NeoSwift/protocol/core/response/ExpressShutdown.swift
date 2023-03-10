
public struct ExpressShutdown: Codable, Hashable {

    @StringDecode public private(set) var processId: Int
    
    enum CodingKeys: String, CodingKey {
        case processId = "process-id"
    }
    
}
