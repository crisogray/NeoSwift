
import Foundation

public class ScryptParams: Codable, Hashable {
    
    public static let N_STANDARD: Int = 1 << 14
    public static let R_STANDARD: Int = 8
    public static let P_STANDARD: Int = 8
    public static let DEFAULT: ScryptParams = .init(N_STANDARD, R_STANDARD, P_STANDARD)
    
    public let n: Int
    public let r: Int
    public let p: Int
    
    public init(_ n: Int, _ r: Int, _ p: Int) {
        self.n = n
        self.r = r
        self.p = p
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: EssentialCodingKeys.self)
        try container.encode(n, forKey: .n)
        try container.encode(r, forKey: .r)
        try container.encode(p, forKey: .p)
    }
    
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        guard let n: Int = (try? values.decode(Int.self, forKey: .n)) ??
                (try? values.decode(Int.self, forKey: .cost)) else {
            throw "No 'n' found in ScryptParams JSON"
        }
        guard let r: Int = (try? values.decode(Int.self, forKey: .r)) ??
                (try? values.decode(Int.self, forKey: .blockSize)) ??
                (try? values.decode(Int.self, forKey: ._blockSize)) else {
            throw "No 'r' found in ScryptParams JSON"
        }
        guard let p: Int = (try? values.decode(Int.self, forKey: .p)) ??
                (try? values.decode(Int.self, forKey: .parallel)) else {
            throw "No 'p' found in ScryptParams JSON"
        }
        self.n = n
        self.r = r
        self.p = p
    }
    
    private enum CodingKeys: String, CodingKey {
        case n, cost
        case r, blockSize, _blockSize = "blocksize"
        case p, parallel
    }
    
    private enum EssentialCodingKeys: String, CodingKey {
        case n, r, p
    }
    
    public static func == (lhs: ScryptParams, rhs: ScryptParams) -> Bool {
        return lhs.n == rhs.n && lhs.r == rhs.r && lhs.p == rhs.p
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(n)
        hasher.combine(r)
        hasher.combine(p)
    }
    
}
