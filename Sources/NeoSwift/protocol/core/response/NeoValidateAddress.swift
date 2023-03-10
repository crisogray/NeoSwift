
public class NeoValidateAddress: Response<NeoValidateAddress.Result> {
    
    public var validation: Result? {
        return result
    }
    
    public struct Result: Codable {
        
        public let address: String
        public let isValid: Bool
        
        enum CodingKeys: String, CodingKey {
            case address, isValid = "isvalid"
        }
        
    }
    
}
