
import XCTest
@testable import NeoSwift

class ScryptParamsTests: XCTestCase {

    private let params = ScryptParams(7, 8, 9)
    
    func testSerialize() {
        let data = try! JSONEncoder().encode(params)
        XCTAssertEqual("{\"n\":7,\"r\":8,\"p\":9}", String(data: data, encoding: .utf8))
    }
    
    func testDeserialize() {
        let strings = [
            "{\"n\":7,\"r\":8,\"p\":9}",
            "{\"n\":7,\"blockSize\":8,\"p\":9}",
            "{\"n\":7,\"blockSize\":8,\"parallel\":9}",
            "{\"n\":7,\"r\":8,\"parallel\":9}",
            "{\"n\":7,\"blocksize\":8,\"p\":9}",
            "{\"n\":7,\"blocksize\":8,\"parallel\":9}",
            "{\"cost\":7,\"r\":8,\"p\":9}",
            "{\"cost\":7,\"r\":8,\"parallel\":9}",
            "{\"cost\":7,\"blockSize\":8,\"p\":9}",
            "{\"cost\":7,\"blockSize\":8,\"parallel\":9}",
            "{\"cost\":7,\"blocksize\":8,\"p\":9}",
            "{\"cost\":7,\"blocksize\":8,\"parallel\":9}",
        ]
        for string in strings {
            guard let data = string.data(using: .utf8),
                  let s = try? JSONDecoder().decode(ScryptParams.self, from: data) else {
                XCTFail()
                return
            }
            XCTAssertEqual(params, s)
        }
    }
    
    
}
