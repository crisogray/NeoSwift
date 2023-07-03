
public class NeoValidateAddress: Response<NeoValidateAddress.Result> {
    
    public var validation: Result? {
        return result
    }
    
    public struct Result: Codable {
        
        public let address: String
        public let isValid: Bool
        
        public init(address: String, isValid: Bool) {
            self.address = address
            self.isValid = isValid
        }
        
        enum CodingKeys: String, CodingKey {
            case address, isValid = "isvalid"
        }
        
    }
    
}
