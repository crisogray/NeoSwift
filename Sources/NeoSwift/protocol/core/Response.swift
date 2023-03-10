
import Foundation

public class Response<T: Codable>: Codable {
    
    @StringDecode public private(set) var id: Int
    public let jsonrpc: String
    public let result: T?
    public let error: Error?
    public let rawResponse: String?
    
    public var hasError: Bool {
        return error != nil
    }
    
    public struct Error: Codable, Hashable {
        
        public let code: Int
        public let message: String
        public let data: String?
        
        init(code: Int, message: String, data: String? = nil) {
            self.code = code
            self.message = message
            self.data = data
        }
        
        public init(from decoder: Decoder) throws {
            let container: KeyedDecodingContainer<Response<T>.Error.CodingKeys> = try decoder.container(keyedBy: Response<T>.Error.CodingKeys.self)
            self.code = try container.decode(Int.self, forKey: Response<T>.Error.CodingKeys.code)
            self.message = try container.decode(String.self, forKey: Response<T>.Error.CodingKeys.message)
            if let data = try? container.decodeIfPresent([String : AnyHashable].self, forKey: Response<T>.Error.CodingKeys.data),
               let json = try? JSONEncoder().encode(data), let string = String(data: json, encoding: .utf8) {
                self.data = string
            } else { self.data = nil }
        }

    }
    
}
