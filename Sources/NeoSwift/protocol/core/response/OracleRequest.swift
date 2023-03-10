
public struct OracleRequest: Codable, Hashable {
    
    let requestId: Int
    let originalTransactionHash: Hash256
    let gasForResponse: Int
    let url: String
    let filter: String
    let callbackContract: Hash160
    let callbackMethod: String
    let userData: String
    
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
