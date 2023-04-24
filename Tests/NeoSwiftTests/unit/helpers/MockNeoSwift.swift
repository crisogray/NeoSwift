
import Combine
import Foundation
@testable import NeoSwift

public class MockNeoSwift: NeoSwift {
    
    public var overrideCatchUpToLatestAndSubscribeToNewBlocksPublisher = false
    
    public override func catchUpToLatestAndSubscribeToNewBlocksPublisher(_ startBlock: Int, _ fullTransactionObjects: Bool) -> AnyPublisher<NeoGetBlock, Error> {
        if overrideCatchUpToLatestAndSubscribeToNewBlocksPublisher {
            return [MockBlocks.createBlock(1000), MockBlocks.createBlock(1001), MockBlocks.createBlock(1002)]
                .publisher.setFailureType(to: Error.self).eraseToAnyPublisher()
        } else { return super.catchUpToLatestBlockPublisher(startBlock, fullTransactionObjects) }
    }
    
}
