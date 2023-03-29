// IMPORTED FROM: https://github.com/keefertaylor/Base58Swift/blob/master/Base58SwiftTests/Base58Tests.swift

import XCTest
@testable import NeoSwift

class Base58SwiftTests: XCTestCase {
    /// Tuples of arbitrary strings that are mapped to valid Base58 encodings.
    private let validStringDecodedToEncodedTuples = [
        ("", ""),
        (" ", "Z"),
        ("-", "n"),
        ("0", "q"),
        ("1", "r"),
        ("-1", "4SU"),
        ("11", "4k8"),
        ("abc", "ZiCa"),
        ("1234598760", "3mJr7AoUXx2Wqd"),
        ("abcdefghijklmnopqrstuvwxyz", "3yxU3u1igY8WkgtjK92fbJQCd4BZiiT1v25f"),
        ("00000000000000000000000000000000000000000000000000000000000000",
         "3sN2THZeE9Eh9eYrwkvZqNstbHGvrxSAM7gXUXvyFQP8XvQLUqNCS27icwUeDT7ckHm4FUHM2mTVh1vbLmk7y")
    ]
    
    /// Tuples of invalid strings.
    private let invalidStrings = [
        "0",
        "O",
        "I",
        "l",
        "3mJr0",
        "O3yxU",
        "3sNI",
        "4kl8",
        "0OIl",
        "!@#$%^&*()-_=+~`"
    ]
    
    public func testBase58EncodingForValidStrings() {
        for (decoded, encoded) in validStringDecodedToEncodedTuples {
            let bytes = decoded.bytes
            let result = bytes.base58Encoded
            XCTAssertEqual(result, encoded)
        }
    }
    
    public func testBase58DecodingForValidStrings() {
        for (decoded, encoded) in validStringDecodedToEncodedTuples {
            guard let bytes = encoded.base58Decoded else {
                XCTFail()
                return
            }
            let result = String(bytes: bytes, encoding: .utf8)
            XCTAssertEqual(result, decoded)
        }
    }
    
    public func testBase58DecodingForInvalidStrings() {
        for invalidString in invalidStrings {
            let result = invalidString.base58Decoded
            XCTAssertNil(result)
        }
    }
    
    public func testBase58CheckEncoding() {
        let inputData: Bytes = [
            6, 161, 159, 136, 34, 110, 33, 238, 14, 79, 14, 218, 133, 13, 109, 40, 194, 236, 153, 44, 61, 157, 254
        ]
        let expectedOutput = "tz1Y3qqTg9HdrzZGbEjiCPmwuZ7fWVxpPtRw"
        let actualOutput = inputData.base58CheckEncoded
        XCTAssertEqual(actualOutput, expectedOutput)
    }
    
    public func testBase58CheckDecoding() {
        let inputString = "tz1Y3qqTg9HdrzZGbEjiCPmwuZ7fWVxpPtRw"
        let expectedOutputData: Bytes = [
            6, 161, 159, 136, 34, 110, 33, 238, 14, 79, 14, 218, 133, 13, 109, 40, 194, 236, 153, 44, 61, 157, 254
        ]
        
        guard let actualOutput = inputString.base58CheckDecoded else {
            XCTFail()
            return
        }
        XCTAssertEqual(actualOutput, expectedOutputData)
    }
    
    public func testBase58CheckDecodingWithInvalidCharacters() {
        XCTAssertNil("0oO1lL".base58CheckDecoded)
    }
    
    public func testBase58CheckDecodingWithInvalidChecksum() {
        XCTAssertNil("tz1Y3qqTg9HdrzZGbEjiCPmwuZ7fWVxpPtrW".base58CheckDecoded)
    }
}
