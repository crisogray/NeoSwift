
import Foundation
import NeoSwift

class MockURLSession: URLRequester {
    
    let defaultData = """
{
    "jsonrpc": "2.0",
    "id": 1,
    "error": {
        "code": -32602,
        "message": "Invalid address length, expected 40 got 64 bytes",
        "data": null
    }
}
""".data(using: .utf8)!
    
    private var data: Data? = nil
    private var error: Error? = nil
    
    private var requestInterceptor: ((URLRequest) -> Void)?
    
    public func data(_ data: Data) -> MockURLSession {
        self.data = data
        return self
    }
    
    public func error(_ error: Error) -> MockURLSession {
        self.error = error
        return self
    }
    
    public func requestInterceptor(_ requestInterceptor: @escaping (URLRequest) -> Void) -> MockURLSession {
        self.requestInterceptor = requestInterceptor
        return self
    }
    
    public func data(from request: URLRequest) async throws -> (Data, URLResponse?) {
        if let requestInterceptor = requestInterceptor {
            requestInterceptor(request)
        }
        if let error = error {
            throw error
        }
        return (data ?? defaultData, nil)
    }
    
}
