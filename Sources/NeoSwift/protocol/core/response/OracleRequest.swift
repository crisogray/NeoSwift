
public struct OracleRequest: Codable, Hashable {
    
    let requestId: Int
    let originalTransactionHash: Hash256
    let gasForResponse: Int
    let url: String
    let filter: String
    let callbackContract: Hash160
    let callbackMethod: String
    let userData: String
    
    public init(requestId: Int, originalTransactionHash: Hash256, gasForResponse: Int, url: String, filter: String, callbackContract: Hash160, callbackMethod: String, userData: String) {
        self.requestId = requestId
        self.originalTransactionHash = originalTransactionHash
        self.gasForResponse = gasForResponse
        self.url = url
        self.filter = filter
        self.callbackContract = callbackContract
        self.callbackMethod = callbackMethod
        self.userData = userData
    }
    
    enum CodingKeys: String, CodingKey {
        case url, filter
        case requestId = "requestid"
        case originalTransactionHash = "originaltxid"
        case gasForResponse = "gasforresponse"
        case callbackContract = "callbackcontract"
        case callbackMethod = "callbackmethod"
        case userData = "userdata"
    }
}
