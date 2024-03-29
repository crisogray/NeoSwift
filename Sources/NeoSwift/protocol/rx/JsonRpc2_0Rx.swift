
import Foundation
import Combine

public class JsonRpc2_0Rx {
    
    private let neoSwift: NeoSwift
    private let executorService: DispatchQueue
    
    public init(neoSwift: NeoSwift, executorService: DispatchQueue) {
        self.neoSwift = neoSwift
        self.executorService = executorService
    }
    
    public func blockIndexPublisher(_ pollingInterval: Int) -> AnyPublisher<Int, Error> {
        return BlockIndexPolling().blockIndexPublisher(neoSwift, executorService, pollingInterval).eraseToAnyPublisher()
    }
    
    public func blockPublisher(_ fullTransactionObjects: Bool, _ pollingInterval: Int) -> AnyPublisher<NeoGetBlock, Error> {
        return blockIndexPublisher(pollingInterval).syncMap { index in
            return try await self.neoSwift.getBlock(index, fullTransactionObjects).send()
        }.eraseToAnyPublisher()
    }
    
    public func replayBlocksPublisher(_ startBlock: Int, _ endBlock: Int, _ fullTransactionObjects: Bool, _ ascending: Bool = true) -> AnyPublisher<NeoGetBlock, Error> {
        var blocks: [Int] = Array(startBlock...endBlock)
        if !ascending { blocks.reverse() }
        return blocks.publisher.setFailureType(to: Error.self).syncMap { block in
            return try await self.neoSwift.getBlock(block, fullTransactionObjects).send()
        }.eraseToAnyPublisher()
    }
    
    public func catchUpToLatestBlockPublisher(_ startBlock: Int, _ fullTransactionObjects: Bool, onCaughtUpPublisher: AnyPublisher<NeoGetBlock, Error>) -> AnyPublisher<NeoGetBlock, Error> {
        return latestBlockIndexPublisher().flatMap { latestBlock in
            if startBlock >= latestBlock {
                return onCaughtUpPublisher
            } else {
                return self.replayBlocksPublisher(startBlock, latestBlock, fullTransactionObjects)
                    .append(Deferred { [self] in return catchUpToLatestBlockPublisher(latestBlock + 1, fullTransactionObjects, onCaughtUpPublisher: onCaughtUpPublisher) })
                    .eraseToAnyPublisher()
            }
        }.eraseToAnyPublisher()
    }
    
    public func catchUpToLatestAndSubscribeToNewBlocksPublisher(_ startBlock: Int, _ fullTransactionObjects: Bool, _ pollingInterval: Int) -> AnyPublisher<NeoGetBlock, Error> {
        return catchUpToLatestBlockPublisher(startBlock, fullTransactionObjects, onCaughtUpPublisher: blockPublisher(fullTransactionObjects, pollingInterval))
    }
    
    public func latestBlockIndexPublisher() -> AnyPublisher<Int, Error> {
        return Just("").setFailureType(to: Error.self).syncMap { _ in
            return try await self.neoSwift.getBlockCount().send().getResult() - 1
        }.eraseToAnyPublisher()
    }
    
}
