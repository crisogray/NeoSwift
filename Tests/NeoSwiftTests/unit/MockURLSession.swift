
import Foundation

class MockURLSession: URLSession {
    
    private let data: Data?
    private let response: URLResponse?
    
    init(configuration: URLSessionConfiguration = .default, data: Data?, response: URLResponse?) {
        self.data = data
        self.response = response
        super.init(configuration: configuration)
    }
    
    func data(from request: URLRequest) async throws -> (Data?, URLResponse?) {
        return (data, response)
    }
    
}
