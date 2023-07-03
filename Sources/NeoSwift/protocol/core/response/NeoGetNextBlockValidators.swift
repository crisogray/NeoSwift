
public class NeoGetNextBlockValidators: Response<[NeoGetNextBlockValidators.Validator]> {
    
    public var nextBlockValidators: [Validator]? {
        return result
    }
    
    public struct Validator: Codable, Hashable {
        
        public let publicKey: String
        public let votes: String
        public let active: Bool
        
        public init(publicKey: String, votes: String, active: Bool) {
            self.publicKey = publicKey
            self.votes = votes
            self.active = active
        }
        
        enum CodingKeys: String, CodingKey {
            case votes, active
            case publicKey = "publickey"
        }
        
    }
    
}
