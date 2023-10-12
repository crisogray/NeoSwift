
/// Used to build a ``NeoTransaction``. When signing the `TransactionBuilder`, a transaction is created that can be sent to the Neo node.
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
    
    public init(_ neoSwift: NeoSwift) {
        self.neoSwift = neoSwift
        nonce = Int.random(in: 0..<(2.toPowerOf(32)))
        version = NeoConstants.CURRENT_TX_VERSION
        script = []
        additionalNetworkFee = 0
        additionalSystemFee = 0
        signers = []
        attributes = []
    }
    
    /// Sets the version for this transaction.
    ///
    /// It is set to ``NeoConstants/CURRENT_TX_VERSION`` by default.
    /// - Parameter version: The transaction version number
    /// - Returns: This transaction builder (self)
    public func version(_ version: Byte) -> TransactionBuilder {
        self.version = version
        return self
    }
    
    /// Sets the nonce (number used once) for this transaction. The nonce is a number from 0 to 2^32.
    ///
    /// It is set to a random value by default.
    /// - Parameter nonce: The transaction nonce
    /// - Returns: This transaction builder (self)
    public func nonce(_ nonce: Int) throws -> TransactionBuilder {
        guard nonce >= 0 && nonce < 2.toPowerOf(32) else {
            throw TransactionError.transactionConfiguration("The value of the transaction nonce must be in the interval [0, 2^32].")
        }
        self.nonce = nonce
        return self
    }
    
    /// Sets the number of the block up to which this transaction can be included.
    /// If that block number is reached in the network and this transaction is not yet included in a block, it becomes invalid.
    ///
    /// By default, it is set to the maximum, which is the current chain height plus ``NeoSwiftConfig/maxValidUntilBlockIncrement``.
    /// - Parameter blockNr: The block number
    /// - Returns: This transaction builder (self)
    public func validUntilBlock(_ blockNr: Int) throws -> TransactionBuilder {
        guard blockNr >= 0 && blockNr < 2.toPowerOf(32) else {
            throw TransactionError.transactionConfiguration("The block number up to which this transaction can be included cannot be less than zero or more than 2^32.")
        }
        self.validUntilBlock = blockNr
        return self
    }
    
    /// Sets the signer belonging to the given `sender` account to the first index of the list of signers for this transaction.
    /// The first signer covers the fees for the transaction if there is no signer present with fee-only witness scope (see ``WitnessScope/none``).
    /// - Parameter sender: The account of the signer to be set to the first index
    /// - Returns: This transaction builder (self)
    public func firstSigner(_ sender: Account) throws -> TransactionBuilder {
        return try firstSigner(sender.getScriptHash())
    }
    
    /// Sets the signer with script hash `sender` to the first index of the list of signers for this transaction.
    /// The first signer covers the fees for the transaction if there is no signer present with fee-only witness scope (see ``WitnessScope/none``).
    /// - Parameter sender: The script hash of the signer to be set to the first index
    /// - Returns: This transaction builder (self)
    public func firstSigner(_ sender: Hash160) throws -> TransactionBuilder {
        guard !signers.contains(where: { $0.scopes.contains(.none) }) else {
            throw NeoSwiftError.illegalState("This transaction contains a signer with fee-only witness scope that will cover the fees. Hence, the order of the signers does not affect the payment of the fees.")
        }
        guard let s = signers.first(where: { $0.signerHash == sender }) else {
            throw NeoSwiftError.illegalState("Could not find a signer with script hash \(sender.string). Make sure to add the signer before calling this method.")
        }
        signers.remove(at: signers.firstIndex(of: s)!)
        signers.insert(s, at: 0)
        return self
    }
    
    /// Sets the signers of this transaction. If the list of signers already contains signers, they are replaced.
    ///
    /// If one of the signers has the fee-only witness scope (see ``WitnessScope/none``), this account is used to cover the transaction fees.
    /// Otherwise, the first signer is used as the sender of this transaction, meaning that it is used to cover the transaction fees.
    /// - Parameter signers: The signers for this transaction
    /// - Returns: This transaction builder (self)
    public func signers(_ signers: Signer...) throws -> TransactionBuilder {
        return try self.signers(signers)
    }
    
    /// Sets the signers of this transaction. If the list of signers already contains signers, they are replaced.
    ///
    /// If one of the signers has the fee-only witness scope (see ``WitnessScope/none``), this account is used to cover the transaction fees.
    /// Otherwise, the first signer is used as the sender of this transaction, meaning that it is used to cover the transaction fees.
    /// - Parameter signers: The signers for this transaction
    /// - Returns: This transaction builder (self)
    public func signers(_ signers: [Signer]) throws -> TransactionBuilder {
        let hashes = signers.map(\.signerHash)
        guard Set(hashes).count == hashes.count else {
            throw TransactionError.transactionConfiguration("Cannot add multiple signers concerning the same account.")
        }
        try throwIfMaxAttributesExceeded(signers.count, attributes.count)
        self.signers = signers
        return self
    }
    
    private func throwIfMaxAttributesExceeded(_ signerCount: Int, _ attributeCount: Int) throws {
        if signerCount + attributeCount > NeoConstants.MAX_TRANSACTION_ATTRIBUTES {
            throw TransactionError.transactionConfiguration("A transaction cannot have more than \(NeoConstants.MAX_TRANSACTION_ATTRIBUTES) attributes (including signers).")
        }
    }
    
    /// Configures the transaction with an additional network fee.
    ///
    /// The basic network fee required to send this transaction is added automatically.
    /// - Parameter fee: The additional network fee in fractions of GAS
    /// - Returns: This transaction builder (self)
    public func additionalNetworkFee(_ fee: Int) -> TransactionBuilder {
        additionalNetworkFee = fee
        return self
    }
    
    /// Configures the transaction with an additional system fee.
    ///
    /// The basic system fee required to send this transaction is added automatically.
    ///
    /// Use this, if you expect the transaction to consume more GAS because of chain state changes happening between creating the transaction and actually sending it.
    /// - Parameter fee: The additional system fee in fractions of GAS
    /// - Returns: This transaction builder (self)
    public func additionalSystemFee(_ fee: Int) -> TransactionBuilder {
        additionalSystemFee = fee
        return self
    }
    
    /// Sets the script for this transaction. It defines the actions that this transaction will perform on the blockchain.
    /// - Parameter script: The contract script
    /// - Returns: This transaction builder (self)
    public func script(_ script: Bytes) -> TransactionBuilder {
        self.script = script
        return self
    }
    
    /// Concatenates the existing script and the provided script, i.e. the provided script is appended to the existing script.
    ///
    /// This method may be used to create an advanced transaction that contains multiple invocations.
    /// - Parameter script: The contract script
    /// - Returns: This transaction builder (self)
    public func extendScript(_ script: Bytes) -> TransactionBuilder {
        self.script = (self.script ?? []) + script
        return self
    }
    
    /// Adds the given attributes to this transaction.
    ///
    /// The maximum number of attributes on a transaction is given in ``NeoConstants/MAX_TRANSACTION_ATTRIBUTES``.
    /// - Parameter attributes: The attributes
    /// - Returns: This transaction builder (self)
    public func attributes(_ attributes: TransactionAttribute...) throws -> TransactionBuilder {
        return try self.attributes(attributes)
    }
    
    /// Adds the given attributes to this transaction.
    ///
    /// The maximum number of attributes on a transaction is given in ``NeoConstants/MAX_TRANSACTION_ATTRIBUTES``.
    /// - Parameter attributes: The attributes
    /// - Returns: This transaction builder (self)
    public func attributes(_ attributes: [TransactionAttribute]) throws -> TransactionBuilder {
        try throwIfMaxAttributesExceeded(signers.count, self.attributes.count + attributes.count)
        attributes.forEach { attr in
            if attr != .highPriority || !isHighPriority {
                self.attributes.append(attr)
            }
        }
        return self
    }
    
    /// Builds the transaction without signing it.
    /// - Returns: The unsigned transaction
    public func getUnsignedTransaction() async throws -> NeoTransaction {
        guard let script = script, !script.isEmpty else {
            throw TransactionError.transactionConfiguration("Cannot build a transaction without a script.")
        }
        if validUntilBlock == nil {
            let currentBlockCount = try await neoSwift.getBlockCount().send().getResult()
            try _ = validUntilBlock(currentBlockCount + neoSwift.maxValidUntilBlockIncrement - 1)
        }
        guard !signers.isEmpty else {
            throw NeoSwiftError.illegalState("Cannot create a transaction without signers. At least one signer with witness scope fee-only or higher is required.")
        }
        if isHighPriority {
            let isAllowed = try await isAllowedForHighPriority()
            if !isAllowed {
                throw NeoSwiftError.illegalState("This transaction does not have a committee member as signer. Only committee members can send transactions with high priority.")
            }
        }
        
        let systemFee = try await getSystemFeeForScript() + additionalSystemFee
        let networkFee = try await calcNetworkFee() + additionalNetworkFee
        let fees = systemFee + networkFee
        
        
        if let feeError = feeError, try await !canSendCoverFees(fees) {
            throw feeError
        } else if let consumer = consumer {
            let gasBalance = try await getSenderGasBalance()
            if fees > gasBalance { consumer(fees, gasBalance) }
        }
        
        return NeoTransaction(neoSwift: neoSwift, version: version, nonce: nonce,
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
            throw TransactionError.transactionConfiguration("The vm exited due to the following exception: \(result.exception ?? "nil")")
        }
        return try Int(string: result.gasConsumed)
    }
    
    private func calcNetworkFee() async throws -> Int {
        let tx = NeoTransaction(neoSwift: neoSwift, version: version, nonce: nonce,
                                         validUntilBlock: validUntilBlock!, signers: signers,
                                         systemFee: 0, networkFee: 0, attributes: attributes,
                                         script: script!, witnesses: [])
        var hasAtLeastOneSigningAccount = false
        for signer in signers {
            if let contractSigner = signer as? ContractSigner {
                _ = try tx.addWitness(.createContractWitness(contractSigner.verifyParams))
            } else if let accountSigner = signer as? AccountSigner {
                let verificationScript = try createFakeVerificationScript(accountSigner.account)
                _ = tx.addWitness(.init([], verificationScript.script))
                hasAtLeastOneSigningAccount = true
            }
        }
        guard hasAtLeastOneSigningAccount else {
            throw TransactionError.transactionConfiguration("A transaction requires at least one signing account (i.e. an AccountSigner). None was provided.")
        }
        return try await neoSwift.calculateNetworkFee(tx.toArray().noPrefixHex).send().getResult().networkFee
    }
    
    private func getSenderGasBalance() async throws -> Int {
        return try await neoSwift.invokeFunction(Self.GAS_TOKEN_HASH, Self.BALANCE_OF_FUNCTION, [.hash160(signers[0].signerHash)], []).send().getResult().stack[0].integer!
    }
    
    private func canSendCoverFees(_ fees: Int) async throws -> Bool {
        return try await getSenderGasBalance() >= fees
    }
    
    private func createFakeVerificationScript(_ account: Account) throws -> VerificationScript {
        if account.isMultiSig {
            return try VerificationScript((0..<account.getNrOfParticipants()).map { _ in try ECPublicKey(Self.DUMMY_PUB_KEY) },
                                          account.getSigningThreshold())
        }
        return try VerificationScript(ECPublicKey(Self.DUMMY_PUB_KEY))
    }
    
    /// Makes an `invokescript` call to the Neo node with the transaction in its current configuration. No changes are made to the blockchain state.
    ///
    /// Make sure to add all necessary signers to the builder before making this call. They are required for a successful `invokescript` call.
    /// - Returns: The call's response
    public func callInvokeScript() async throws -> NeoInvokeScript {
        guard let script = script, !script.isEmpty else {
            throw TransactionError.transactionConfiguration("Cannot make an 'invokescript' call without the script being configured.")
        }
        return try await neoSwift.invokeScript(script.noPrefixHex, signers).send()
    }
    
    /// Builds the transaction, creates signatures for every signer and adds them to the transaction as witnesses.
    ///
    /// For each signer of the transaction, a corresponding account with an EC key pair must exist in the wallet set on this transaction builder.
    /// - Returns: The signed transaction
    public func sign() async throws -> NeoTransaction {
        let transaction = try await getUnsignedTransaction()
        let txBytes = try await transaction.getHashData()
        try transaction.signers.forEach { signer in
            if let contractSigner = signer as? ContractSigner {
                _ = try transaction.addWitness(.createContractWitness(contractSigner.verifyParams))
            } else if let accountSigner = signer as? AccountSigner {
                let acc = accountSigner.account
                guard !acc.isMultiSig else {
                    throw NeoSwiftError.illegalState("Transactions with multi-sig signers cannot be signed automatically.")
                }
                guard let keyPair = acc.keyPair else {
                    throw TransactionError.transactionConfiguration("Cannot create transaction signature because account \(acc.address) does not hold a private key.")
                }
                _ = try transaction.addWitness(.create(txBytes, keyPair))
            }
        }
        return transaction
    }
    
    /// Checks if the sender account of this transaction can cover the network and system fees.
    /// If not, executes the given consumer supplying it with the required fee and the sender's GAS balance.
    ///
    /// The check and potential execution of the consumer is only performed when the transaction is built, i.e., when calling ``TransactionBuilder/sign()`` or ``TransactionBuilder/getUnsignedTransaction()``.
    /// - Parameter consumer: The consumer
    /// - Returns: This transaction builder (self)
    public func doIfSenderCannotCoverFees(_ consumer: @escaping (Int, Int) -> Void) throws -> TransactionBuilder {
        guard feeError == nil else {
            throw NeoSwiftError.illegalState("Cannot handle a consumer for this case, since an exception will be thrown if the sender cannot cover the fees.")
        }
        self.consumer = consumer
        return self
    }
    
    /// Checks if the sender account of this transaction can cover the network and system fees.
    /// If not, otherwise throw an error created by the provided supplier.
    ///
    /// The check and potential throwing of the exception is only performed when the transaction is built, i.e., when calling ``TransactionBuilder/sign()`` or ``TransactionBuilder/getUnsignedTransaction()``.
    /// - Parameter error: The error to throw
    /// - Returns: This transaction builder (self)
    public func throwIfSenderCannotCoverFees(_ error: Error) throws -> TransactionBuilder {
        guard consumer == nil else {
            throw NeoSwiftError.illegalState("Cannot handle a supplier for this case, since a consumer will be executed if the sender cannot cover the fees.")
        }
        feeError = error
        return self
    }
    
}
