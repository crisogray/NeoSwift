
public protocol NeoSwiftService {
    
    /// Performs an asynchronous JSON-RPC request.
    /// - Parameter request: The request to perform
    /// - Returns: The deserialized JSON-RPC response
    func send<T: Response<U>, U>(_ request: Request<T, U>) async throws -> T
    
}
