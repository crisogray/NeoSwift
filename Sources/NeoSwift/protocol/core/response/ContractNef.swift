
public struct ContractNef: Codable, Hashable {
    
    public let magic: Int
    public let compiler: String
    public let source: String?
    @SingleValueOrNilArray public private(set) var tokens: [ContractMethodToken]
    public let script: String
    public let checksum: Int
    
}
