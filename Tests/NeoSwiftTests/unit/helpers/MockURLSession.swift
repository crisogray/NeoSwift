
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
    
    private var i = 0
    private var dataIs: [String: Int] = [:]
    private var data: [Data]? = nil
    private var dataMap: [String: [Data]]? = nil
    private var error: Error? = nil
    
    private var requestInterceptor: ((URLRequest) -> Void)?
    
    public func data(_ dataMap: [String : Data]) -> MockURLSession {
        if self.dataMap != nil { dataMap.forEach { self.dataMap![$0] = [$1] } }
        else { self.dataMap = dataMap.mapValues { [$0] } }
        return self
    }
    
    public func data(_ dataMap: [String : [Data]], hardReset: Bool = false) -> MockURLSession {
        if self.dataMap != nil && !hardReset { dataMap.forEach { self.dataMap![$0] = $1 } }
        else { self.dataMap = dataMap }
        return self
    }
    
    public func data(_ data: Data...) -> MockURLSession {
        if self.data == nil { self.data = data }
        else { self.data!.append(contentsOf: data) }
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
        if let dataMap = dataMap {
            let requestBody = String(data: request.httpBody!, encoding: .utf8)!
            let method = requestBody.components(separatedBy: "method\":\"")[1].components(separatedBy: "\"")[0]
            let i = dataIs[method] ?? 0
            let data = i >= dataMap[method]!.count ? dataMap[method]![0] : dataMap[method]![i]
            dataIs[method] = i + 1
            return (data, nil)
        }
        if let error = error {
            throw error
        }
        let d = data?[i] ?? data?[0] ?? defaultData
        i += 1
        return (d, nil)
    }
    
}
