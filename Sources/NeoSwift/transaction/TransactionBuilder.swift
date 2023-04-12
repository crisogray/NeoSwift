
public class TransactionBuilder {
    
    public static let GAS_TOKEN_HASH = try! Hash160("d2a4cff31913016155e38e474a2c06d08be276cf")
    public static let BALANCE_OF_FUNCTION = "balanceOf"
    public static let DUMMY_PUB_KEY = "02ec143f00b88524caf36a0121c2de09eef0519ddbe1c710a00f0e2663201ee4c0"
    
    private let neoSwift: NeoSwift
    
    private var version: Byte
    private var nonce: Int
    private var validUntilBlock: Int? = nil
    public private(set) var signers: [Signer]
    private var additionalNetworkFee: Int
    private var additionalSystemFee: Int
    private var attributes: [TransactionAttribute]
    public private(set) var script: Bytes

    private var consumer: ((Int, Int) -> Void)? = nil
    private var supplier: (() -> Error)? = nil

    private var isHighPriority: Bool {
        return attributes.contains(where: { return $0 == .highPriority })
    }
    
    init(_ neoSwift: NeoSwift) {
        self.neoSwift = neoSwift
        nonce = Int.random(in: 0..<(2.toPowerOf(32)))
        version = NeoConstants.CURRENT_TX_VERSION
        script = []
        additionalNetworkFee = 0
        additionalSystemFee = 0
        signers = []
        attributes = []
    }
    
    public func version(_ version: Byte) -> TransactionBuilder {
        self.version = version
        return self
    }
    
    public func nonce(_ nonce: Int) throws -> TransactionBuilder {
        guard nonce >= 0 && nonce < 2.toPowerOf(32) else {
            throw "The value of the transaction nonce must be in the interval [0, 2^32]."
        }
        self.nonce = nonce
        return self
    }
    
    public func validUntilBlock(_ blockNr: Int) throws -> TransactionBuilder {
        guard blockNr >= 0 && blockNr < 2.toPowerOf(32) else {
            throw "The block number up to which this transaction can be included cannot be less than zero or more than 2^32."
        }
        self.validUntilBlock = blockNr
        return self
    }
    
    public func firstSigner(_ sender: Account) throws -> TransactionBuilder {
        return try firstSigner(sender.getScriptHash())
    }
    
    public func firstSigner(_ sender: Hash160) throws -> TransactionBuilder {
        guard !signers.contains(where: { $0.scopes.contains(.none) }) else {
            throw "This transaction contains a signer with fee-only witness scope that will cover the fees. Hence, the order of the signers does not affect the payment of the fees."
        }
        guard let s = signers.first(where: { $0.signerHash == sender }) else {
            throw "Could not find a signer with script hash \(sender.string). Make sure to add the signer before calling this method."
        }
        signers.remove(at: signers.firstIndex(of: s)!)
        signers.insert(s, at: 0)
        return self
    }
    
    public func signers(_ signers: Signer...) throws -> TransactionBuilder {
        return try self.signers(signers)
    }
    
    public func signers(_ signers: [Signer]) throws -> TransactionBuilder {
        guard Set(signers).count == signers.count else {
            throw "Cannot add multiple signers concerning the same account."
        }
        try throwIfMaxAttributesExceeded(signers.count, attributes.count)
        self.signers = signers
        return self
    }
    
    private func throwIfMaxAttributesExceeded(_ signerCount: Int, _ attributeCount: Int) throws {
        if signerCount + attributeCount > NeoConstants.MAX_TRANSACTION_ATTRIBUTES {
            throw "A transaction cannot have more than \(NeoConstants.MAX_TRANSACTION_ATTRIBUTES) attributes (including signers)."
        }
    }
    
    public func additionalNetworkFee(_ fee: Int) -> TransactionBuilder {
        additionalNetworkFee = fee
        return self
    }
    
    public func additionalSystemFee(_ fee: Int) -> TransactionBuilder {
        additionalSystemFee = fee
        return self
    }
    
    public func script(_ script: Bytes) -> TransactionBuilder {
        self.script = script
        return self
    }
    
    public func extendScript(_ script: Bytes) -> TransactionBuilder {
        self.script += script
        return self
    }
    
    public func attributes(_ attributes: TransactionAttribute...) throws {
        return try self.attributes(attributes)
    }
    
    public func attributes(_ attributes: [TransactionAttribute]) throws {
        try throwIfMaxAttributesExceeded(signers.count, self.attributes.count + attributes.count)
        attributes.forEach { attr in
            if attr != .highPriority || !isHighPriority {
                self.attributes.append(attr)
            }
        }
    }
    
}
