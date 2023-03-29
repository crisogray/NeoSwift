
import Foundation

protocol Service: NeoSwiftService {
    
    var includeRawResponses: Bool { get }
    func performIO(_ payload: Data) async throws -> Data?
    
}

extension Service {
    
    public func send<T, U>(_ request: Request<T, U>) async throws -> T where T : Response<U>, U : Decodable, U : Encodable {
        let payload = try JSONEncoder().encode(request)
        let decoder = includeRawResponses ? RawResponseJSONDecoder() : JSONDecoder()
        if let result = try? await performIO(payload),
           let t = try? decoder.decode(T.self, from: result) {
            return t
        }
        throw "Error Sending Request"
    }
    
}
