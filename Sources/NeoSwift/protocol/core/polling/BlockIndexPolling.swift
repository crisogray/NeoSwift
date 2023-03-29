
import Combine
import Foundation

public actor BlockIndexActor {
    
    var blockIndex: Int = -1
    
    func setIndex(_ index: Int) {
        blockIndex = index
    }
    
}

public struct BlockIndexPolling {
    
    var currentBlockIndex = BlockIndexActor()
    
    public func run(_ neoSwift: NeoSwift, _ executor: DispatchQueue, _ pollingInterval: Int) -> AnyPublisher<Int, Error> {
        let timer = Timer.publish(every: Double(pollingInterval) / 1000, on: .main, in: .default)
            .setFailureType(to: Error.self)
            .receive(on: executor)
            .asyncMap { t -> [Int] in
                var latestBlockIndex = try await neoSwift.getBlockCount().send().getResult()
                latestBlockIndex -= 1
                if await latestBlockIndex > currentBlockIndex.blockIndex {
                    return await Array((currentBlockIndex.blockIndex + 1)...latestBlockIndex)
                }
                return []
            }.flatMap(\.publisher)
        return timer.eraseToAnyPublisher()
    }
    
}


extension Publisher {
    func asyncMap<T>(
        _ transform: @escaping (Output) async throws -> T
    ) -> Publishers.FlatMap<Future<T, Error>, Self> {
        flatMap { value in
            Future { promise in
                Task {
                    do {
                        let output = try await transform(value)
                        promise(.success(output))
                    } catch {
                        promise(.failure(error))
                    }
                }
            }
        }
    }
}
