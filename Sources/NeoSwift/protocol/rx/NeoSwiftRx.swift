import Combine

/// The Combine JSON-RPC client event API.
public protocol NeoSwiftRx {
    
    /// Create a  publisher that emits newly created blocks on the blockchain.
    /// - Parameter fullTransactionObjects: If true, provides transactions embedded in blocks, otherwise transaction hashes
    /// - Returns: A publisher that emits all new blocks as they are added to the blockchain
    func blockPublisher(_ fullTransactionObjects: Bool) -> AnyPublisher<NeoGetBlock, Error>
    
    /// Create a publisher that emits all blocks from the blockchain contained within the requested range.
    /// - Parameters:
    ///   - startBlock: The block number to commence with
    ///   - endBlock: The block number to finish with
    ///   - fullTransactionObjects: If true, provides transactions embedded in blocks, otherwise transaction hashes
    /// - Returns: A publisher to emit these blocks
    func replayBlocksPublisher(_ startBlock: Int, _ endBlock: Int, _ fullTransactionObjects: Bool) -> AnyPublisher<NeoGetBlock, Error>
    
    /// Create a publisher that emits all blocks from the blockchain contained within the requested range.
    /// - Parameters:
    ///   - startBlock: The block number to commence with
    ///   - endBlock: The block number to finish with
    ///   - fullTransactionObjects: If true, provides transactions embedded in blocks, otherwise transaction hashes
    ///   - ascending: If true, emits blocks in ascending order between range, otherwise, in descending order
    /// - Returns: A publisher to emit these blocks
    func replayBlocksPublisher(_ startBlock: Int, _ endBlock: Int, _ fullTransactionObjects: Bool, _ ascending: Bool) -> AnyPublisher<NeoGetBlock, Error>
    
    /// Create a publisher that emits all transactions from the blockchain starting with a provided block number.
    /// Once it has replayed up to the most current block, the publisher completes.
    /// - Parameters:
    ///   - startBlock: The block number to commence with
    ///   - fullTransactionObjects: If true, provides transactions embedded in blocks, otherwise transaction hashes
    /// - Returns: A publisher to emit all requested blocks
    func catchUpToLatestBlockPublisher(_ startBlock: Int, _ fullTransactionObjects: Bool) -> AnyPublisher<NeoGetBlock, Error>
    
    /// Creates a publisher that emits all blocks from the requested block number to the most current.
    /// Once it has emitted the most current block, it starts emitting new blocks as they are created.
    /// - Parameters:
    ///   - startBlock: The block number to commence with
    ///   - fullTransactionObjects: If true, provides transactions embedded in blocks, otherwise transaction hashes
    /// - Returns: A publisher to emit all requested blocks and future
    func catchUpToLatestAndSubscribeToNewBlocksPublisher(_ startBlock: Int, _ fullTransactionObjects: Bool) -> AnyPublisher<NeoGetBlock, Error>
    
    /// Creates a publisher that emits new blocks as they are created on the blockchain (starting from the latest block).
    ///   - fullTransactionObjects: If true, provides transactions embedded in blocks, otherwise transaction hashes
    /// - Returns: A publisher to emit all future blocks
    func subscribeToNewBlocksPublisher(_ fullTransactionObjects: Bool) -> AnyPublisher<NeoGetBlock, Error>
    
}
