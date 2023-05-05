
public struct Iterator<T> {
    
    public let neoSwift: NeoSwift
    public let sessionId: String
    public let iteratorId: String
    public let mapper: (StackItem) -> T
    
    public init(neoSwift: NeoSwift, sessionId: String, iteratorId: String, mapper: @escaping (StackItem) -> T = { $0 as! T }) {
        self.neoSwift = neoSwift
        self.sessionId = sessionId
        self.iteratorId = iteratorId
        self.mapper = mapper
    }
    
    public func traverse(_ count: Int) async throws -> [T] {
        return try await neoSwift.traverseIterator(sessionId, iteratorId, count).send().getResult().map(mapper)
    }
    
    public func terminateSession() async throws {
        _ = try await neoSwift.terminateSession(sessionId).send()
    }
    
}
