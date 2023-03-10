
public class NeoGetNextBlockValidators: Response<[NeoGetNextBlockValidators.Validator]> {
    
    public var nextBlockValidators: [Validator]? {
        return result
    }
    
    public struct Validator: Codable, Hashable {
        
        public let publicKey: String
        public let votes: String
        public let active: Bool
        
        enum CodingKeys: String, CodingKey {
            case votes, active
            case publicKey = "publickey"
        }
        
    }
    
}
