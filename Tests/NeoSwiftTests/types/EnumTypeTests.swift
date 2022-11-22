
import XCTest
@testable import NeoSwift

class EnumTypeTests: XCTestCase {
    
    public func testNeoVMStateType() {
        let type = NeoVMStateType.halt
        XCTAssertEqual(type.jsonvalue, "HALT")
        XCTAssertEqual(type.int, 1)
        XCTAssertEqual(NeoVMStateType.fromJsonValue("HALT"), type)
        XCTAssertEqual(NeoVMStateType.fromJsonValue(nil), NeoVMStateType.none)
        XCTAssertEqual(NeoVMStateType.fromJsonValue(""), NeoVMStateType.none)
        XCTAssertEqual(NeoVMStateType.fromIntValue(4), NeoVMStateType.break)
        XCTAssertEqual(NeoVMStateType.fromIntValue(nil), NeoVMStateType.none)
        XCTAssertEqual(NeoVMStateType.fromJsonValue("Invalid"), nil)
        XCTAssertEqual(NeoVMStateType.fromIntValue(12), nil)
    }
    
    public func testContractParameterType() {
        let type = ContractParamterType.string
        XCTAssertEqual(type.jsonvalue, "String")
        XCTAssertEqual(type.byte, 0x13)
        XCTAssertEqual(ContractParamterType.valueOf(0x13), type)
        XCTAssertEqual(ContractParamterType.valueOf(0xab), nil)
        XCTAssertEqual(ContractParamterType.fromJsonValue("String"), type)
        XCTAssertEqual(ContractParamterType.fromJsonValue("Invalid"), nil)
    }
    
}
