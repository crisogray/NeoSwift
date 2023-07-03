
public struct ContractNef: Codable, Hashable {
    
    public let magic: Int
    public let compiler: String
    public let source: String?
    @SingleValueOrNilArray public private(set) var tokens: [ContractMethodToken]
    public let script: String
    public let checksum: Int
    
    public init(magic: Int, compiler: String, source: String?, tokens: [ContractMethodToken], script: String, checksum: Int) {
        self.magic = magic
        self.compiler = compiler
        self.source = source
        self.tokens = tokens
        self.script = script
        self.checksum = checksum
    }
    
}
