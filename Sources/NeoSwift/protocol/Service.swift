
import Foundation

public protocol Service: NeoSwiftService {
    var includeRawResponses: Bool { get }
    func performIO(_ payload: Data) async throws -> Data
}

public extension Service {
    
    func send<T, U>(_ request: Request<T, U>) async throws -> T where T : Response<U>, U : Decodable, U : Encodable {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .withoutEscapingSlashes
        let payload = try encoder.encode(request)
        let decoder = includeRawResponses ? RawResponseJSONDecoder() : JSONDecoder()
        let result = try await performIO(payload)
        return try decoder.decode(T.self, from: result)
    }
    
}
