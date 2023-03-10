import BigInt

public class NeoGetVersion: Response<NeoGetVersion.NeoVersion> {
    
    public var version: NeoVersion? {
        return result
    }
    
    public struct NeoVersion: Codable, Hashable {
        
        public let tcpPort: Int
        public let wsPort: Int
        public let nonce: Int
        public let userAgent: String
        public let `protocol`: `Protocol`
        
        enum CodingKeys: String, CodingKey {
            case nonce, `protocol`
            case tcpPort = "tcpport"
            case wsPort = "wsport"
            case userAgent = "useragent"
        }
        
        public struct `Protocol`: Codable, Hashable {
            
            public let network: Int
            public let validatorsCount: Int?
            public let msPerBlock: Int
            public let maxValidUntilBlockIncrement: Int
            public let maxTraceableBlocks: Int
            public let addressVersion: Int
            public let maxTransactionsPerBlock: Int
            public let memoryPoolMaxTransactions: Int
            public let initialGasDistribution: Int
            
            enum CodingKeys: String, CodingKey {
                case network
                case validatorsCount = "validatorscount"
                case msPerBlock = "msperblock"
                case maxValidUntilBlockIncrement = "maxvaliduntilblockincrement"
                case maxTraceableBlocks = "maxtraceableblocks"
                case addressVersion = "addressversion"
                case maxTransactionsPerBlock = "maxtransactionsperblock"
                case memoryPoolMaxTransactions = "memorypoolmaxtransactions"
                case initialGasDistribution = "initialgasdistribution"
            }
            
        }
        
    }
    
}
