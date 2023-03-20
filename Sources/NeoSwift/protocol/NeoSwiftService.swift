import Combine

public protocol NeoSwiftService {
    
    func send<T: Response<U>, U>(_ request: Request<T, U>) throws -> T

    func sendAsync<T: Response<U>, U>(_ request: Request<T, U>, _ callback: @escaping (T?, Error?) -> Void)

    func subscribe<T: Response<U>, U: Notification>(_ request: Request<T, U>, _ unsubscribeMethod: String,
                                                                _ handler: @escaping (U, Error) -> Void)

    @available(iOS 13.0, *)
    func sendAsync<T: Response<U>, U>(_ request: Request<T, U>) -> Future<T, Error>

    @available(iOS 13.0, *)
    func subscribe<T: Notification>(_ request: Request<Response<T>, T>, _ unsubscribeMethod: String) -> AnyPublisher<T, Error>

}
