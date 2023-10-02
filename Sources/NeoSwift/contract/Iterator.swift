
/// This class represents an iterator for stack items of the type
/// - Parameter T: The type of the iterator items
public struct Iterator<T> {
    
    public let neoSwift: NeoSwift
    public let sessionId: String
    public let iteratorId: String
    public let mapper: (StackItem) throws -> T
    
    /// Initializes an iterator.
    ///
    /// Traversing this iterator returns a list of the ``StackItem``s in the iterator.
    /// - Parameters:
    ///   - neoSwift: The ``NeoSwift`` instance
    ///   - sessionId: The session id
    ///   - iteratorId: The iterator id
    ///   - mapper: The mapper function to apply on the iterator items
    public init(neoSwift: NeoSwift, sessionId: String, iteratorId: String, mapper: @escaping (StackItem) throws -> T = { $0 as! T }) {
        self.neoSwift = neoSwift
        self.sessionId = sessionId
        self.iteratorId = iteratorId
        self.mapper = mapper
    }
    
    /// Sends a request to traverse this iterator and returns a maximum of `count` items per request.
    ///
    /// Whenever this method is called, the next `count` items of the iterator are returned.
    /// If there are no more items in the iterator, an empty list will be returned.
    /// The maximum `count` value that can be used for traversing an iterator depends on the configuration of the Neo node.
    /// Make sure, it's less than or equal to the Neo node's configured value.
    /// Otherwise, traversing this iterator will fail.
    /// - Parameter count: The number of items per traverse request
    /// - Returns: The list of the next `count` items of this iterator
    public func traverse(_ count: Int) async throws -> [T] {
        return try await neoSwift.traverseIterator(sessionId, iteratorId, count).send().getResult().map(mapper)
    }
    
    /// Terminates the session on the Neo node.
    public func terminateSession() async throws {
        _ = try await neoSwift.terminateSession(sessionId).send()
    }
    
}
