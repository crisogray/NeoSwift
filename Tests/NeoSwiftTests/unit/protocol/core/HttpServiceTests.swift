
import XCTest
@testable import NeoSwift

class HttpServiceTests: XCTestCase {
    
    var httpService = HttpService()
    
    func testAddHeader() {
        let headerName = "customized_header0"
        let headerValue = "customized_value0"
        httpService.addHeader(headerName, headerValue)
        XCTAssertEqual(httpService.headers[headerName], headerValue)
    }
    
    func testAddHeaders() {
        let headerName1 = "customized_header1"
        let headerValue1 = "customized_value1"
        
        let headerName2 = "customized_header2"
        let headerValue2 = "customized_value2"
    
        let headersToAdd = [headerName1 : headerValue1, headerName2 : headerValue2]
        
        httpService.addHeaders(headersToAdd)
        
        XCTAssertEqual(httpService.headers[headerName1], headerValue1)
        XCTAssertEqual(httpService.headers[headerName2], headerValue2)
    }
    
}
