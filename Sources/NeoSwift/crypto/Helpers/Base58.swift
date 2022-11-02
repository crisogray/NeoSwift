
// IMPORTED AND MODIFIED FROM https://github.com/keefertaylor/Base58Swift (MIT)
// Copyright Keefer Taylor, 2019.

import BigInt
import CryptoSwift
import Foundation

/// A static utility class which provides Base58 encoding and decoding functionality.
public enum Base58 {
    /// Length of checksum appended to Base58Check encoded strings.
    private static let checksumLength = 4
    
    private static let alphabet = Bytes("123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz".utf8)
    private static let zero = BInt(0)
    private static let radix = BInt(alphabet.count)
    
    /// Encode the given bytes into a Base58Check encoded string.
    /// - Parameter bytes: The bytes to encode.
    /// - Returns: A base58check encoded string representing the given bytes, or nil if encoding failed.
    public static func base58CheckEncode(_ bytes: Bytes) -> String {
        let checksum = calculateChecksum(bytes)
        let checksummedBytes = bytes + checksum
        return Base58.encode(checksummedBytes)
    }
    
    /// Decode the given Base58Check encoded string to bytes.
    /// - Parameter input: A base58check encoded input string to decode.
    /// - Returns: Bytes representing the decoded input, or nil if decoding failed.
    public static func base58CheckDecode(_ input: String) -> Bytes? {
        guard let decodedChecksummedBytes = decode(input) else {
            return nil
        }
        
        let decodedChecksum = decodedChecksummedBytes.suffix(checksumLength)
        let decodedBytes = decodedChecksummedBytes.prefix(upTo: decodedChecksummedBytes.count - checksumLength)
        let calculatedChecksum = calculateChecksum(Bytes(decodedBytes))
        
        guard decodedChecksum.elementsEqual(calculatedChecksum, by: { $0 == $1 }) else {
            return nil
        }
        return Array(decodedBytes)
    }
    
    /// Encode the given bytes to a Base58 encoded string.
    /// - Parameter bytes: The bytes to encode.
    /// - Returns: A base58 encoded string representing the given bytes, or nil if encoding failed.
    public static func encode(_ bytes: Bytes) -> String {
        guard !bytes.isEmpty else {
            return ""
        }
        
        var answer: Bytes = []
        var integerBytes = bytes.bInt
        
        while integerBytes > 0 {
            let (quotient, remainder) = integerBytes.quotientAndRemainder(dividingBy: radix)
            answer.insert(alphabet[Int(remainder.asInt()!)], at: 0)
            integerBytes = quotient
        }
        
        let prefix = Array(bytes.prefix { $0 == 0 }).map { _ in alphabet[0] }
        answer.insert(contentsOf: prefix, at: 0)
        
        // swiftlint:disable force_unwrapping
        // Force unwrap as the given alphabet will always decode to UTF8.
        return String(bytes: answer, encoding: String.Encoding.utf8)!
        // swiftlint:enable force_unwrapping
    }
    
    /// Decode the given base58 encoded string to bytes.
    /// - Parameter input: The base58 encoded input string to decode.
    /// - Returns: Bytes representing the decoded input, or nil if decoding failed.
    public static func decode(_ input: String) -> Bytes? {
        guard !input.isEmpty else {
            return []
        }
        
        var answer = zero
        var i = BInt(1)
        let byteString = Bytes(input.utf8)
        
        for char in byteString.reversed() {
            guard let alphabetIndex = alphabet.firstIndex(of: char) else {
                return nil
            }
            answer += (i * BInt(alphabetIndex))
            i *= radix
        }
        
        let bytes = answer.asMagnitudeBytes()
        return Array(byteString.prefix { i in i == alphabet[0] }) + bytes
    }
    
    /// Calculate a checksum for a given input by hashing twice and then taking the first four bytes.
    /// - Parameter input: The input bytes.
    /// - Returns: A byte array representing the checksum of the input bytes.
    private static func calculateChecksum(_ input: Bytes) -> Bytes {
        let doubleHashedData = input.hash256()
        let doubleHashedArray = Array(doubleHashedData)
        return Array(doubleHashedArray.prefix(checksumLength))
    }
    
}
