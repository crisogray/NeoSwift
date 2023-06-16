
public struct NeoBlock: Codable, Hashable {
    
    public let hash: Hash256
    public let size: Int
    public let version: Int
    public let prevBlockHash: Hash256
    public let merkleRootHash: Hash256
    public let time: Int
    public let index: Int
    public let primary: Int?
    public let nextConsensus: String
    public let witnesses: [NeoWitness]?
    public let transactions: [Transaction]?
    public let confirmations: Int
    public let nextBlockHash: Hash256?
    
    public init(hash: Hash256, size: Int, version: Int, prevBlockHash: Hash256, merkleRootHash: Hash256, time: Int, index: Int, primary: Int?, nextConsensus: String, witnesses: [NeoWitness]?, transactions: [Transaction]?, confirmations: Int, nextBlockHash: Hash256) {
        self.hash = hash
        self.size = size
        self.version = version
        self.prevBlockHash = prevBlockHash
        self.merkleRootHash = merkleRootHash
        self.time = time
        self.index = index
        self.primary = primary
        self.nextConsensus = nextConsensus
        self.witnesses = witnesses
        self.transactions = transactions
        self.confirmations = confirmations
        self.nextBlockHash = nextBlockHash
    }
    
    enum CodingKeys: String, CodingKey {
        case hash, size, version, time, index, primary, witnesses, confirmations
        case prevBlockHash = "previousblockhash"
        case merkleRootHash = "merkleroot"
        case nextConsensus = "nextconsensus"
        case transactions = "tx"
        case nextBlockHash = "nextblockhash"
    }
    
}

