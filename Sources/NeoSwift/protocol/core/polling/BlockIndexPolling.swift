
import Combine
import Foundation

public actor BlockIndexActor {
    
    var blockIndex: Int? = nil
    
    func setIndex(_ index: Int) {
        blockIndex = index
    }
    
}

public struct BlockIndexPolling {
    
    var currentBlockIndex = BlockIndexActor()
    
    public func blockIndexPublisher(_ neoSwift: NeoSwift, _ executor: DispatchQueue, _ pollingInterval: Int) -> AnyPublisher<Int, Error> {
        return Timer.publish(every: Double(pollingInterval) / 1000, on: .current, in: .default)
            .autoconnect()
            .setFailureType(to: Error.self)
            .syncMap { _ -> [Int]? in
                let latestBlockIndex = try await neoSwift.getBlockCount().send().getResult() - 1
                if await currentBlockIndex.blockIndex == nil {
                    await currentBlockIndex.setIndex(latestBlockIndex)
                }
                if await latestBlockIndex > currentBlockIndex.blockIndex! {
                    let currIndex = await currentBlockIndex.blockIndex!
                    await currentBlockIndex.setIndex(latestBlockIndex )
                    return Array((currIndex + 1)...latestBlockIndex)
                }
                return nil
            }.compactMap { $0 }.flatMap(\.publisher).eraseToAnyPublisher()
    }
    
}


extension Publisher {
    func syncMap<T>(
        _ transform: @escaping (Output) async throws -> T
    ) -> Publishers.FlatMap<Future<T, Error>, Self> {
        flatMap { value in
            let semaphore = DispatchSemaphore(value: 0)
            let future = Future<T, Error>({ promise in
                Task {
                    do {
                        let output = try await transform(value)
                        promise(.success(output))
                        semaphore.signal()
                    } catch {
                        promise(.failure(error))
                        semaphore.signal()
                    }
                }
            })
            semaphore.wait()
            return future
        }
    }
}
