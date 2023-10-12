
import Combine

public class NeoTransaction {
    
    public static let HEADER_SIZE: Int = 25
    
    /// The NeoSwift instance of this transaction.
    public var neoSwift: NeoSwift?
    
    /// The version of this transaction.
    public let version: Byte
    
    /// The nonce of this transaction.
    public let nonce: Int
    
    /// The validity period of this transaction.
    public let validUntilBlock: Int
    
    /// The signers of this transaction.
    public let signers: [Signer]
    
    /// TThe sender is the account that pays for the transaction's fees.
    public let systemFee: Int
    
    /// The network fee of this transaction in GAS fractions.
    public let networkFee: Int
    
    /// The attributes of this transaction.
    public let attributes: [TransactionAttribute]
    
    /// The script of this transaction.
    public let script: Bytes
    
    /// The witnesses of this transaction.
    public private(set) var witnesses: [Witness]
    
    private var blockCountWhenSent: Int?
    
    public init(neoSwift: NeoSwift? = nil, version: Byte, nonce: Int, validUntilBlock: Int, signers: [Signer], systemFee: Int, networkFee: Int, attributes: [TransactionAttribute], script: Bytes, witnesses: [Witness], blockCountWhenSent: Int? = nil) {
        self.neoSwift = neoSwift
        self.version = version
        self.nonce = nonce
        self.validUntilBlock = validUntilBlock
        self.signers = signers
        self.systemFee = systemFee
        self.networkFee = networkFee
        self.attributes = attributes
        self.script = script
        self.witnesses = witnesses
        self.blockCountWhenSent = blockCountWhenSent
    }
    
    /// The sender of this transaction.
    ///
    /// The sender is the account that pays for the transaction's fees.
    public var sender: Hash160 {
        return (signers.first { $0.scopes.contains(.none) } ?? signers.first!).signerHash
    }
    
    public var txId: Hash256? {
        return try? getTxId()
    }
    
    /// - Returns: This transaction's uniquely identifying ID/hash
    private func getTxId() throws -> Hash256 {
        return try Hash256(toArrayWithoutWitnesses().sha256().reversed())
    }
    
    /// Adds a witness to this transaction.
    ///
    /// Note, that witnesses have to be added in the same order as signers were added.
    /// - Parameter witness: The transaction witness
    /// - Returns: self
    public func addWitness(_ witness: Witness) -> NeoTransaction {
        witnesses.append(witness)
        return self
    }
    
    /// Adds a witness to this transaction by signing it with the given account.
    ///
    /// Note, that witnesses have to be added in the same order as signers were added.
    /// - Parameter witness: The account to sign with
    /// - Returns: self
    public func addWitness(_ account: Account) async throws -> NeoTransaction {
        guard let keyPair = account.keyPair else {
            throw NeoSwiftError.illegalArgument("Provided account has no key pair.")
        }
        try await witnesses.append(.create(getHashData(), keyPair))
        return self
    }
    
    /// Adds a multi-sig witness to this transaction. Use this to add a witness of a multi-sig signer that is part of this transaction.
    ///
    /// The witness is constructed from the multi-sig account's `verificationScript` and the `signatures`.
    /// Obviously, the signatures should be derived from this transaction's hash data (see ``NeoTransaction/getHashData()``.
    ///
    /// Note, that witnesses have to be added in the same order as signers were added.
    /// - Parameters:
    ///   - verificationScript: The verification script of the multi-sig account
    ///   - pubKeySigMap: A map of participating public keys mapped to the signatures created with their corresponding private key
    /// - Returns: self
    public func addMultiSigWitness(_ verificationScript: VerificationScript, _ pubKeySigMap: [ECPublicKey : Sign.SignatureData]) throws -> NeoTransaction {
        let signatures = pubKeySigMap.keys.sorted().map { pubKeySigMap[$0]! }
        let multiSigWitness = try Witness.creatMultiSigWitness(signatures, verificationScript)
        return addWitness(multiSigWitness)
    }
    
    /// Adds a multi-sig witness to this transaction. Use this to add a witness of a multi-sig signer that is part of this transaction.
    ///
    /// The witness is constructed from the multi-sig account's `verificationScript` and by signing this transaction with the given accounts.
    ///
    /// Note, that witnesses have to be added in the same order as signers were added.
    /// - Parameters:
    ///   - verificationScript: The verification script of the multi-sig account
    ///   - accounts: The accounts to use for signing. They need to hold decrypted private keys
    /// - Returns: self
    public func addMultiSigWitness(_ verificationScript: VerificationScript, _ accounts: Account...) async throws -> NeoTransaction {
        let hashData = try await getHashData()
        let signatures = accounts
            .compactMap(\.keyPair)
            .sorted { $0.publicKey < $1.publicKey }
            .compactMap { try? Sign.signMessage(hashData, $0) }
        let witness = try Witness.creatMultiSigWitness(signatures, verificationScript)
        return addWitness(witness)
    }
    
    /// Sends this invocation transaction to the Neo node via the `sendrawtransaction` RPC.
    /// - Returns: The Neo node's response
    public func send() async throws -> NeoSendRawTransaction {
        guard signers.count == witnesses.count else {
            throw TransactionError.transactionConfiguration("The transaction does not have the same number of signers and witnesses. For every signer there has to be one witness, even if that witness is empty.")
        }
        guard size <= NeoConstants.MAX_TRANSACTION_SIZE else {
            throw TransactionError.transactionConfiguration("The transaction exceeds the maximum transaction size. The maximum size is \(NeoConstants.MAX_TRANSACTION_SIZE) bytes while the transaction has size \(size).")
        }
        let hex = toArray().noPrefixHex
        try throwIfNeoSwiftNil()
        blockCountWhenSent = try await neoSwift!.getBlockCount().send().getResult()
        return try await neoSwift!.sendRawTransaction(hex).send()
    }
    
    /// Creates a publisher that emits the block number containing this transaction as soon as it has been integrated in one.
    /// The publisher completes right after emitting the block number.
    ///
    /// The publisher starts tracking the blocks from the point at which the transaction has been sent.
    /// - Returns: The publisher
    public func track() async throws -> AnyPublisher<Int, Error> {
        guard let blockCountWhenSent = blockCountWhenSent else {
            throw NeoSwiftError.illegalState("Cannot subscribe before transaction has been sent.")
        }
        try throwIfNeoSwiftNil()
        let predicate = { (getBlock: NeoGetBlock) -> Bool in
            if let contains = getBlock.block?.transactions?.contains(where: { $0.hash == self.txId }) { return !contains }
            return true
        }
        return neoSwift!.catchUpToLatestAndSubscribeToNewBlocksPublisher(blockCountWhenSent, true)
            .prefix(while: predicate)
            .tryMap { try! $0.getResult().index }
            .eraseToAnyPublisher()
    }
    
    /// Gets the application log of this transaction.
    ///
    /// The application log is not cached locally. Every time this method is called, requests are sent to the Neo node.
    ///
    /// If the application log could not be fetched, `nil` is returned.
    /// - Returns: The applicaion log
    public func getApplicationLog() async throws -> NeoApplicationLog {
        guard blockCountWhenSent != nil else {
            throw NeoSwiftError.illegalState("Cannot get the application log before transaction has been sent.")
        }
        try throwIfNeoSwiftNil()
        return try await neoSwift!.getApplicationLog(getTxId()).send().getResult()
    }
    
    public func throwIfNeoSwiftNil() throws {
        guard neoSwift != nil else {
            throw NeoSwiftError.illegalState("NeoTransaction has not been assigned NeoSwift instance.")
        }
    }
    
}

extension NeoTransaction: NeoSerializable {
    
    public var size: Int {
        NeoTransaction.HEADER_SIZE
        + signers.varSize
        + attributes.varSize
        + script.varSize
        + witnesses.varSize
    }
    
    /// Gets this transaction's data in the format used to produce the transaction's hash. E.g., for producing the transaction ID or a transaction signature.
    ///
    /// The returned value depends on the magic number of the used Neo network, which is retrieved from the Neo node via the `getversion` RPC method if not already available locally.
    /// - Returns: The transaction data ready for hashing
    public func getHashData() async throws -> Bytes {
        try throwIfNeoSwiftNil()
        return try await neoSwift!.getNetworkMagicNumberBytes() + toArrayWithoutWitnesses().sha256()
    }
    
    private func serializeWithoutWitnesses(_ writer: BinaryWriter) {
        writer.writeByte(version)
        writer.writeUInt32(UInt32(nonce))
        writer.writeInt64(Int64(systemFee))
        writer.writeInt64(Int64(networkFee))
        writer.writeUInt32(UInt32(validUntilBlock))
        writer.writeSerializableVariable(signers)
        writer.writeSerializableVariable(attributes)
        writer.writeVarBytes(script)
    }
    
    /// Serializes this transaction to a raw byte array without any witnesses.
    ///
    /// In this form, the transaction byte array can be used for example to create a signature.
    /// - Returns: The serialized transaction
    public func toArrayWithoutWitnesses() -> Bytes {
        let writer = BinaryWriter()
        serializeWithoutWitnesses(writer)
        return writer.toArray()
    }
    

    public func serialize(_ writer: BinaryWriter) {
        serializeWithoutWitnesses(writer)
        writer.writeSerializableVariable(witnesses)
    }

    public static func deserialize(_ reader: BinaryReader) throws -> Self {
        let version = reader.readByte(), nonce = Int(reader.readUInt32())
        let systemFee = Int(reader.readInt64()), networkFee = Int(reader.readInt64())
        let validUntilBlock = Int(reader.readUInt32())
        let signers: [Signer] = reader.readSerializableList()
        let attributes = try readTransactionAttributes(reader, signers.count)
        let script = try reader.readVarBytes()
        var witnesses: [Witness] = []
        if reader.available > 0 { witnesses = reader.readSerializableList() }
        return NeoTransaction(version: version, nonce: nonce,
                     validUntilBlock: validUntilBlock,
                     signers: signers, systemFee: systemFee,
                     networkFee: networkFee, attributes: attributes,
                     script: script, witnesses: witnesses) as! Self
    }
    
    private static func readTransactionAttributes(_ reader: BinaryReader, _ signerSize: Int) throws -> [TransactionAttribute] {
        let nrOfAttributes = reader.readVarInt()
        guard nrOfAttributes + signerSize <= NeoConstants.MAX_TRANSACTION_ATTRIBUTES else {
            throw NeoSwiftError.deserialization("A transaction can hold at most \(NeoConstants.MAX_TRANSACTION_ATTRIBUTES) attributes (including signers). Input data had \(signerSize) attributes.")
        }
        return try (0..<nrOfAttributes).map { _ in try TransactionAttribute.deserialize(reader) }
    }
    
    /// Produces a JSON object that can be used in neo-cli for further signing and relaying of this transaction.
    /// - Returns: `neo-cli` compatible json of this transaction
    public func toContractParametersContext() async throws -> ContractParametersContext {
        let hash = try getTxId().string
        let data = toArrayWithoutWitnesses().base64Encoded
        try throwIfNeoSwiftNil()
        let network = try await neoSwift!.getNetworkMagicNumber()
        
        let items: [String: ContractParametersContext.ContextItem] = try signers.map { signer in
            guard let accountSigner = signer as? AccountSigner else {
                throw NeoSwiftError.unsupportedOperation("Cannot handle contract signers")
            }
            guard let verificationScript = accountSigner.account.verificationScript else {
                throw NeoSwiftError.illegalState("Account on AccountSigner has no verification script")
            }
            var params: [ContractParameter] = []
            if let invocationScript = witnesses.first(where: { $0.verificationScript == verificationScript })?.invocationScript {
                params = invocationScript.getSignatures().map { ContractParameter(type: .signature, value: $0.concatenated) }
            }
            if params.isEmpty {
                params = try (1...verificationScript.getSigningThreshold()).map { _ in ContractParameter(type: .signature) }
            }
            var pubKeyToSignature: [String: String] = [:]
            if verificationScript.isSingleSigScript(), let value = params.first?.value {
                let pubKey = try verificationScript.getPublicKeys()[0].getEncodedCompressedHex()
                pubKeyToSignature[pubKey] = (value as! Bytes).base64Encoded
            }
            let script = verificationScript.script.base64Encoded
            return ContractParametersContext.ContextItem(script: script, parameters: params, signatures: pubKeyToSignature)
        }.reduce(into: .init(), { dict, contextItem in
            let hash = try Hash160.fromScript(contextItem.script.base64Decoded).string
            dict["0x\(hash)"] = contextItem
        })
        return .init(hash: hash, data: data, items: items, network: network)
    }
    
}
