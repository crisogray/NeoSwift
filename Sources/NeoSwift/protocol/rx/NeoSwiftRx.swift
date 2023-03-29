import Combine

public protocol NeoSwiftRx {
    
    func blockPublisher(_ fullTransactionObjects: Bool) -> AnyPublisher<NeoGetBlock, Error>
    func replayBlocksPublisher(_ startBlock: Int, _ endBlock: Int, _ fullTransactionObjects: Bool) -> AnyPublisher<NeoGetBlock, Error>
    func replayBlocksPublisher(_ startBlock: Int, _ endBlock: Int, _ fullTransactionObjects: Bool, _ ascending: Bool) -> AnyPublisher<NeoGetBlock, Error>
    func catchUpToLatestBlockPublisher(_ startBlock: Int, _ fullTransactionObjects: Bool) -> AnyPublisher<NeoGetBlock, Error>
    func catchUpToLatestAndSubscribeToNewBlocksPublisher(_ startBlock: Int, _ fullTransactionObjects: Bool) -> AnyPublisher<NeoGetBlock, Error>
    func subscribeToNewBlocksPublisher(_ fullTransactionObjects: Bool) -> AnyPublisher<NeoGetBlock, Error>
    
}
