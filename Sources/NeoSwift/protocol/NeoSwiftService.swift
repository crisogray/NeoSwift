
public protocol NeoSwiftService {
    func send<T: Response<U>, U>(_ request: Request<T, U>) async throws -> T
    func close()
}
