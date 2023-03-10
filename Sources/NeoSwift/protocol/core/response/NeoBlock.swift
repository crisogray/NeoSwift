
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
    public let nextBlockHash: Hash256
    
    enum CodingKeys: String, CodingKey {
        case hash, size, version, time, index, primary, witnesses, confirmations
        case prevBlockHash = "previousblockhash"
        case merkleRootHash = "merkleroot"
        case nextConsensus = "nextconsensus"
        case transactions = "tx"
        case nextBlockHash = "nextblockhash"
    }
    
}

