import BigInt

public class NeoGetVersion: Response<NeoGetVersion.NeoVersion> {
    
    public var version: NeoVersion? {
        return result
    }
    
    public struct NeoVersion: Codable, Hashable {
        
        public let tcpPort: Int?
        public let wsPort: Int?
        public let nonce: Int
        public let userAgent: String
        public let `protocol`: NeoProtocol?
        
        public init(tcpPort: Int?, wsPort: Int?, nonce: Int, userAgent: String, neoProtocol: NeoProtocol) {
            self.tcpPort = tcpPort
            self.wsPort = wsPort
            self.nonce = nonce
            self.userAgent = userAgent
            self.protocol = neoProtocol
        }
        
        enum CodingKeys: String, CodingKey {
            case nonce, `protocol`
            case tcpPort = "tcpport"
            case wsPort = "wsport"
            case userAgent = "useragent"
        }
        
        public struct NeoProtocol: Codable, Hashable {
            
            public let network: Int
            public let validatorsCount: Int?
            public let msPerBlock: Int
            public let maxValidUntilBlockIncrement: Int
            public let maxTraceableBlocks: Int
            public let addressVersion: Int
            public let maxTransactionsPerBlock: Int
            public let memoryPoolMaxTransactions: Int
            public let initialGasDistribution: Int
            
            public init(network: Int, validatorsCount: Int?, msPerBlock: Int, maxValidUntilBlockIncrement: Int, maxTraceableBlocks: Int, addressVersion: Int, maxTransactionsPerBlock: Int, memoryPoolMaxTransactions: Int, initialGasDistribution: Int) {
                self.network = network
                self.validatorsCount = validatorsCount
                self.msPerBlock = msPerBlock
                self.maxValidUntilBlockIncrement = maxValidUntilBlockIncrement
                self.maxTraceableBlocks = maxTraceableBlocks
                self.addressVersion = addressVersion
                self.maxTransactionsPerBlock = maxTransactionsPerBlock
                self.memoryPoolMaxTransactions = memoryPoolMaxTransactions
                self.initialGasDistribution = initialGasDistribution
            }
            
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
