
public class NeoSendRawTransaction: Response<NeoSendRawTransaction.RawTransaction> {
    
    public var sendRawTransaction: RawTransaction? {
        return result
    }
    
    public struct RawTransaction: Codable, Hashable {
        public let hash: Hash256
    }
    
}
