import Combine
import NeoSwift

public enum MockBlocks {
    
    public static func createBlock(_ i: Int, transaction: Hash256? = nil) -> NeoGetBlock {
        let txs: [Transaction] = transaction == nil ? [] : [createTx(transaction!)]
        return .init(.init(hash: .ZERO, size: 0, version: 0, prevBlockHash: .ZERO, merkleRootHash: .ZERO, time: 123456789, index: i,
                           primary: 0, nextConsensus: "nonce", witnesses: nil, transactions: txs, confirmations: 1, nextBlockHash: .ZERO))
    }
    
    public static func createTx(_ hash: Hash256) -> Transaction {
        return .init(hash: hash, size: 0, version: 0, nonce: 0, sender: "", sysFee: "", netFee: "", validUntilBlock: 0, signers: [], attributes: [], script: "", witnesses: [])
    }
    
}
