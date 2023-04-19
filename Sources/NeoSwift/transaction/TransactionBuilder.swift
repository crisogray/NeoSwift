
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
    public private(set) var script: Bytes?

    private var consumer: ((Int, Int) -> Void)? = nil
    private var feeError: Error? = nil

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
        self.script = (self.script ?? []) + script
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
    
    public func getUnsignedTransaction() async throws -> SerializableTransaction {
        guard let script = script, !script.isEmpty else {
            throw "Cannot build a transaction without a script."
        }
        if validUntilBlock == nil {
            let currentBlockCount = try await neoSwift.getBlockCount().send().getResult()
            try _ = validUntilBlock(currentBlockCount + neoSwift.maxValidUntilBlockIncrement)
        }
        guard !signers.isEmpty else {
            throw "Cannot create a transaction without signers. At least one signer with witness scope fee-only or higher is required."
        }
        if isHighPriority {
            let isAllowed = try await isAllowedForHighPriority()
            if !isAllowed {
                throw "This transaction does not have a committee member as signer. Only committee members can send transactions with high priority."
            }
        }
        
        let systemFee = try await getSystemFeeForScript() + additionalSystemFee
        let networkFee = try await calcNetworkFee() + additionalNetworkFee
        let fees = systemFee + networkFee
        
        let gasBalance = try await neoSwift.invokeFunction(Self.GAS_TOKEN_HASH, Self.BALANCE_OF_FUNCTION, [.hash160(signers[0].signerHash)], []).send().getResult().stack[0].integer!
        
        if let feeError = feeError, fees > gasBalance {
            throw feeError
        } else if let consumer = consumer, fees > gasBalance {
            consumer(fees, gasBalance)
        }
        
        return SerializableTransaction(neoSwift: neoSwift, version: version, nonce: nonce,
                                       validUntilBlock: validUntilBlock!, signers: signers,
                                       systemFee: systemFee, networkFee: networkFee,
                                       attributes: attributes, script: script, witnesses: [])
    }
    
    private func isAllowedForHighPriority() async throws -> Bool {
        let committee = try await neoSwift.getCommittee().send().getResult()
            .map { try ECPublicKey($0).getEncoded(compressed: true) }
            .map(Hash160.fromPublicKey)
        return signers.map(\.signerHash).contains(where: committee.contains)
            || signersContainMultiSigWithCommitteeMember(committee)
        
    }
    
    private func signersContainMultiSigWithCommitteeMember(_ committee: [Hash160]) -> Bool {
        for signer in signers {
            if let s = signer as? AccountSigner, s.account.isMultiSig,
               let script = s.account.verificationScript,
               let contains = try? script.getPublicKeys()
                .compactMap({ try? $0.getEncoded(compressed: true)})
                .compactMap(Hash160.fromPublicKey)
                .contains(where: committee.contains), contains {
                return true
            }
        }
        return false
    }
    
    private func getSystemFeeForScript() async throws -> Int {
        let response = try await neoSwift.invokeScript(script?.noPrefixHex ?? "", self.signers).send()
        let result = try response.getResult()
        guard !result.hasStateFault || neoSwift.config.allowsTransmissionOnFault else {
            throw "The vm exited due to the following exception: \(result.exception ?? "nil")"
        }
        return try Int(string: result.gasConsumed)
    }
    
    private func calcNetworkFee() async throws -> Int {
        let tx = SerializableTransaction(neoSwift: neoSwift, version: version, nonce: nonce,
                                         validUntilBlock: validUntilBlock!, signers: signers,
                                         systemFee: 0, networkFee: 0, attributes: attributes,
                                         script: script!, witnesses: [])
        var hasAtLeastOneSigningAccount = false
        for signer in signers {
            if let contractSigner = signer as? ContractSigner {
                _ = tx.addWitness(.createContractWitness(contractSigner.verifyParams))
            } else if let accountSigner = signer as? AccountSigner {
                let verificationScript = try createFakeVerificationScript(accountSigner.account)
                _ = tx.addWitness(.init([], verificationScript.script))
                hasAtLeastOneSigningAccount = true
            }
        }
        guard hasAtLeastOneSigningAccount else {
            throw "A transaction requires at least one signing account (i.e. an AccountSigner). None was provided."
        }
        return try await neoSwift.calculateNetworkFee(tx.toArray().noPrefixHex).send().getResult().networkFee
    }
    
    private func createFakeVerificationScript(_ account: Account) throws -> VerificationScript {
        if account.isMultiSig {
            return try VerificationScript((0..<account.getNrOfParticipants()).map { _ in try ECPublicKey(Self.DUMMY_PUB_KEY) },
                                          account.getSigningThreshold())
        }
        return try VerificationScript(ECPublicKey(Self.DUMMY_PUB_KEY))
    }
    
    public func callInvokeScript() async throws -> NeoInvokeScript {
        guard !signers.isEmpty else {
            throw "Cannot make an 'invokescript' call without the script being configured."
        }
        return try await neoSwift.invokeScript(script?.noPrefixHex ?? "", []).send()
    }
    
    public func sign() async throws -> SerializableTransaction {
        let transaction = try await getUnsignedTransaction()
        let txBytes = try await transaction.getHashData()
        try transaction.signers.forEach { signer in
            if let contractSigner = signer as? ContractSigner {
                _ = transaction.addWitness(.createContractWitness(contractSigner.verifyParams))
            } else if let accountSigner = signer as? AccountSigner {
                let acc = accountSigner.account
                guard !acc.isMultiSig else {
                    throw "Transactions with multi-sig signers cannot be signed automatically."
                }
                guard let keyPair = acc.keyPair else {
                    throw "Cannot create transaction signature because account \(acc.address) does not hold a private key."
                }
                _ = try transaction.addWitness(.create(txBytes, keyPair))
            }
        }
        return transaction
    }
    
    public func doIfSenderCannotCoverFees(_ consumer: @escaping (Int, Int) -> Void) throws -> TransactionBuilder {
        guard feeError == nil else {
            throw "Cannot handle a consumer for this case, since an exception will be thrown if the sender cannot cover the fees."
        }
        self.consumer = consumer
        return self
    }
    
    public func throwIfSenderCannotCoverFees(_ error: Error) throws -> TransactionBuilder {
        guard consumer == nil else {
            throw "Cannot handle a supplier for this case, since a consumer will be executed if the sender cannot cover the fees."
        }
        feeError = error
        return self
    }
    
}
