
import Foundation

public class HttpService: Service {
    
    public static let JSON_MEDIA_TYPE = "application/json; charset=utf-8"
    public static let DEFAULT_URL = URL(string: "http://localhost:10333/")!
    
    public let url: URL
    public let includeRawResponses: Bool
    public private(set) var headers = [String: String]()

    private var urlRequester: URLRequester
    
    public init(url: URL = HttpService.DEFAULT_URL, urlSession: URLRequester = URLSession.shared, includeRawResponses: Bool = false) {
        self.url = url
        self.urlRequester = urlSession
        self.includeRawResponses = includeRawResponses
    }
    
    public func performIO(_ payload: Data) async throws -> Data {
        var request = URLRequest(url: url)
        request.addValue(HttpService.JSON_MEDIA_TYPE, forHTTPHeaderField: "Content-Type")
        headers.forEach { request.addValue($1, forHTTPHeaderField: $0) }
        request.httpMethod = "POST"
        request.httpBody = payload
        do {
            let (data, _) = try await urlRequester.data(from: request)
            return data
        } catch let error as URLError {
            throw ProtocolError.clientConnection("Invalid response received: \(error.errorCode); \(error.localizedDescription)")
        } catch { throw error }
    }
    
    public func addHeader(_ key: String, _ value: String) {
        headers[key] = value
    }
    
    public func addHeaders(_ headersToAdd: [String : String]) {
        headersToAdd.forEach { headers[$0] = $1 }
    }
    
    public func setURLSession(_ urlSession: URLSession) {
        self.urlRequester = urlSession
    }
    
    public func close() { }
}

public protocol URLRequester {
    func data(from request: URLRequest) async throws -> (Data, URLResponse?)
}
