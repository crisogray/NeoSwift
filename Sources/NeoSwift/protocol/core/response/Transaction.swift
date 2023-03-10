
public struct Transaction: Codable, Hashable {
    
    public let hash: Hash256
    public let size: Int
    public let version: Int
    public let nonce: Int
    public let sender: String
    public let sysFee: String
    public let netFee: String
    public let validUntilBlock: Int
    public let signers: [TransactionSigner]
    public let attributes: [TransactionAttribute]
    public let script: String
    public let witnesses: [NeoWitness]
    public let blockHash: Hash256?
    public let confirmations: Int?
    public let blockTime: Int?
    public let vmState: NeoVMStateType?
    
    init(hash: Hash256, size: Int, version: Int, nonce: Int, sender: String, sysFee: String, netFee: String, validUntilBlock: Int, signers: [TransactionSigner], attributes: [TransactionAttribute], script: String, witnesses: [NeoWitness], blockHash: Hash256? = nil, confirmations: Int? = nil, blockTime: Int? = nil, vmState: NeoVMStateType? = nil) {
        self.hash = hash
        self.size = size
        self.version = version
        self.nonce = nonce
        self.sender = sender
        self.sysFee = sysFee
        self.netFee = netFee
        self.validUntilBlock = validUntilBlock
        self.signers = signers
        self.attributes = attributes
        self.script = script
        self.witnesses = witnesses
        self.blockHash = blockHash
        self.confirmations = confirmations
        self.blockTime = blockTime
        self.vmState = vmState
    }
    
    private enum CodingKeys: String, CodingKey {
        case hash, size, version, nonce, sender, signers, attributes, script, witnesses, confirmations
        case sysFee = "sysfee"
        case netFee = "netfee"
        case validUntilBlock = "validuntilblock"
        case blockHash = "blockhash"
        case blockTime = "blocktime"
        case vmState = "vmstate"
    }
    
}
