
import NeoSwift
import Foundation
import Combine

public class MockNeoSwift: NeoSwift {
    
    public var overrideCatchUpToLatestAndSubscribeToNewBlocksPublisher = false
    
    public override func catchUpToLatestAndSubscribeToNewBlocksPublisher(_ startBlock: Int, _ fullTransactionObjects: Bool) -> AnyPublisher<NeoGetBlock, Error> {
        if overrideCatchUpToLatestAndSubscribeToNewBlocksPublisher {
            return [createBlock(1000), createBlock(1001), createBlock(1002)].publisher.setFailureType(to: Error.self).eraseToAnyPublisher()
        } else { return super.catchUpToLatestBlockPublisher(startBlock, fullTransactionObjects) }
    }
    
    public func createBlock(_ i: Int, transaction: Hash256? = nil) -> NeoGetBlock {
        let txs: [Transaction] = transaction == nil ? [] : [createTx(transaction!)]
        return .init(.init(hash: .ZERO, size: 0, version: 0, prevBlockHash: .ZERO, merkleRootHash: .ZERO, time: 123456789, index: i,
                           primary: 0, nextConsensus: "nonce", witnesses: nil, transactions: txs, confirmations: 1, nextBlockHash: .ZERO))
    }
    
    private func createTx(_ hash: Hash256) -> Transaction {
        return .init(hash: hash, size: 0, version: 0, nonce: 0, sender: "", sysFee: "", netFee: "", validUntilBlock: 0, signers: [], attributes: [], script: "", witnesses: [])
    }
    
}
