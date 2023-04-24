
import Combine
import XCTest
@testable import NeoSwift

class JsonRpc2_0RxTests: XCTestCase {
    
    var neoSwift: NeoSwift!
    var mockUrlSession: MockURLSession!
    
    var cancellables: Set<AnyCancellable> = []
    
    override func setUp() {
        super.setUp()
        mockUrlSession = MockURLSession()
        neoSwift = NeoSwift.build(HttpService(urlSession: mockUrlSession), .init(pollingInterval: 1000))
    }
    
    public func testReplayBlocksObservable() {
        let neoGetBlocks = [MockBlocks.createBlock(0), MockBlocks.createBlock(1), MockBlocks.createBlock(2)]
        neoGetBlocks.map { encode($0) }.forEach { _ = mockUrlSession.data($0) }
        
        let publisher = neoSwift.replayBlocksPublisher(0, 2, false)
        let expectation = XCTestExpectation()
        var results: [NeoGetBlock] = []
        
        publisher.sink { completion in
            switch completion {
            case .finished: expectation.fulfill()
            case .failure(let error): XCTFail(error.localizedDescription)
            }
        } receiveValue: { results.append($0) }.store(in: &cancellables)
        
        _ = XCTWaiter.wait(for: [expectation], timeout: 5)

        XCTAssertEqual(results.map(\.block), neoGetBlocks.map(\.block!))
    }
    
    public func testReplayBlocksDescendingObservable() {
        let neoGetBlocks = [MockBlocks.createBlock(2), MockBlocks.createBlock(1), MockBlocks.createBlock(0)]
        neoGetBlocks.map { encode($0) }.forEach { _ = mockUrlSession.data($0) }
        
        let publisher = neoSwift.replayBlocksPublisher(0, 2, false, false)
        let expectation = XCTestExpectation()
        var results: [NeoGetBlock] = []
        
        publisher.sink { completion in
            switch completion {
            case .finished: expectation.fulfill()
            case .failure(let error): XCTFail(error.localizedDescription)
            }
        } receiveValue: { results.append($0) }.store(in: &cancellables)
        
        _ = XCTWaiter.wait(for: [expectation], timeout: 5)

        XCTAssertEqual(results.map(\.block), neoGetBlocks.map(\.block!))
    }
    
    public func testCatchUpToLatestAndSubscribeToNewBlockObservable() {
        let neoGetBlocks = [MockBlocks.createBlock(0), MockBlocks.createBlock(1), MockBlocks.createBlock(2), MockBlocks.createBlock(3),
                            MockBlocks.createBlock(4), MockBlocks.createBlock(5), MockBlocks.createBlock(6)]
        
        var blockCount = NeoBlockCount(4)
        _ = mockUrlSession.data(["getblockcount": [encode(blockCount)], "getblockheader": neoGetBlocks.map { encode($0) }])
        
        let publisher = neoSwift.catchUpToLatestAndSubscribeToNewBlocksPublisher(0, false)
        let expectation = XCTestExpectation()
        var results: [NeoGetBlock] = []
        
        let cancellable = publisher.sink { completion in
            switch completion {
            case .finished: expectation.fulfill()
            case .failure(let error): XCTFail(error.localizedDescription)
            }
        } receiveValue: { results.append($0) }
        
        cancellable.store(in: &cancellables)
        
        DispatchQueue.global().async {
            (4..<7).forEach { _ in
                Thread.sleep(forTimeInterval: 2)
                blockCount = NeoBlockCount(blockCount.blockCount! + 1)
                _ = self.mockUrlSession.data(["getblockcount": [self.encode(blockCount)]])
            }
        }
        
        _ = XCTWaiter.wait(for: [expectation], timeout: 10)
        
        XCTAssertEqual(results.count, neoGetBlocks.count)
        XCTAssertEqual(results.map(\.block!), neoGetBlocks.map(\.block!))
    }
    
    public func testSubscribeToNewBlockObservable() {
        let neoGetBlocks = [MockBlocks.createBlock(0), MockBlocks.createBlock(1), MockBlocks.createBlock(2), MockBlocks.createBlock(3)]
        
        var blockCount = NeoBlockCount(0)
        _ = mockUrlSession.data(["getblockcount": [encode(blockCount)], "getblockheader": neoGetBlocks.map { encode($0) }])
        
        let publisher = neoSwift.subscribeToNewBlocksPublisher(false)
        let expectation = XCTestExpectation()
        var results: [NeoGetBlock] = []
        
        let cancellable = publisher.sink { completion in
            switch completion {
            case .finished: expectation.fulfill()
            case .failure(let error): XCTFail(error.localizedDescription)
            }
        } receiveValue: { results.append($0) }
        
        cancellable.store(in: &cancellables)
        
        DispatchQueue.global().async {
            (0..<4).forEach { _ in
                Thread.sleep(forTimeInterval: 2)
                blockCount = NeoBlockCount(blockCount.blockCount! + 1)
                _ = self.mockUrlSession.data(["getblockcount": [self.encode(blockCount)]])
            }
        }
        
        _ = XCTWaiter.wait(for: [expectation], timeout: 10)
        
        XCTAssertEqual(results.count, neoGetBlocks.count)
        XCTAssertEqual(results.map(\.block!), neoGetBlocks.map(\.block!))
    }
    
    public func encode<T: Response<U>, U: Codable>(_ t: T) -> Data {
        return try! JSONEncoder().encode(t)
    }
    
}
    
