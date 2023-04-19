
import Combine

public class SerializableTransaction {
    
    public static let HEADER_SIZE: Int = 25

    public var neoSwift: NeoSwift?

    public let version: Byte
    public let nonce: Int
    public let validUntilBlock: Int
    public let signers: [Signer]
    public let systemFee: Int
    public let networkFee: Int
    public let attributes: [TransactionAttribute]
    public let script: Bytes
    public private(set) var witnesses: [Witness]
    private var blockCountWhenSent: Int?
    
    init(neoSwift: NeoSwift? = nil, version: Byte, nonce: Int, validUntilBlock: Int, signers: [Signer], systemFee: Int, networkFee: Int, attributes: [TransactionAttribute], script: Bytes, witnesses: [Witness], blockCountWhenSent: Int? = nil) {
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
    
    public var sender: Hash160 {
        return (signers.first { $0.scopes.contains(.none) } ?? signers.first!).signerHash
    }
    
    public var txId: Hash256? {
        return try? getTxId()
    }
    
    private func getTxId() throws -> Hash256 {
        return try Hash256(toArrayWithoutWitnesses().sha256().reversed())
    }
    
    public func addWitness(_ witness: Witness) -> SerializableTransaction {
        witnesses.append(witness)
        return self
    }
    
    public func addMultiSigWitness(_ verificationScript: VerificationScript, _ pubKeySigMap: [ECPublicKey : Sign.SignatureData]) throws -> SerializableTransaction {
        let signatures = pubKeySigMap.keys.sorted().map { pubKeySigMap[$0]! }
        let multiSigWitness = try Witness.creatMultiSigWitness(signatures, verificationScript)
        return addWitness(multiSigWitness)
    }
    
    public func addMultiSigWitness(_ verificationScript: VerificationScript, _ accounts: Account...) async throws -> SerializableTransaction {
        let hashData = try await getHashData()
        let signatures = accounts
            .compactMap(\.keyPair)
            .sorted { $0.publicKey < $1.publicKey }
            .compactMap { try? Sign.signMessage(hashData, $0) }
        let witness = try Witness.creatMultiSigWitness(signatures, verificationScript)
        return addWitness(witness)
    }
    
    public func send() async throws -> NeoSendRawTransaction {
        guard signers.count == witnesses.count else {
            throw "The transaction does not have the same number of signers and witnesses. For every signer there has to be one witness, even if that witness is empty."
        }
        guard size <= NeoConstants.MAX_TRANSACTION_SIZE else {
            throw "The transaction exceeds the maximum transaction size. The maximum size is \(NeoConstants.MAX_TRANSACTION_SIZE) bytes while the transaction has size \(size)."
        }
        let hex = toArray().noPrefixHex
        try throwIfNeoSwiftNil()
        blockCountWhenSent = try await neoSwift!.getBlockCount().send().getResult()
        return try await neoSwift!.sendRawTransaction(hex).send()
    }
    
    public func track() async throws -> AnyPublisher<Int, Error> {
        guard let blockCountWhenSent = blockCountWhenSent else {
            throw "Cannot subscribe before transaction has been sent."
        }
        try throwIfNeoSwiftNil()
        let predicate = { (getBlock: NeoGetBlock) -> Bool in
            if let contains = getBlock.block?.transactions?.contains(where: { $0.hash == self.txId }) { return !contains }
            return true
        }
        let inversePredicate = { (getBlock: NeoGetBlock) -> Bool in return !predicate(getBlock) }
        return neoSwift!.catchUpToLatestAndSubscribeToNewBlocksPublisher(blockCountWhenSent, true)
            .prefix(while: predicate)
            .filter(inversePredicate)
            .tryMap { try $0.getResult().index }
            .eraseToAnyPublisher()
    }
    
    public func getApplicationLog() async throws -> NeoApplicationLog {
        guard blockCountWhenSent != nil else {
            throw "Cannot get the application log before transaction has been sent."
        }
        try throwIfNeoSwiftNil()
        return try await neoSwift!.getApplicationLog(getTxId()).send().getResult()
    }
    
    public func throwIfNeoSwiftNil() throws {
        guard neoSwift != nil else {
            throw "SerializableTransaction has not been assigned NeoSwift instance."
        }
    }
    
}

extension SerializableTransaction: NeoSerializable {
    
    public var size: Int {
        SerializableTransaction.HEADER_SIZE
        + signers.varSize
        + attributes.varSize
        + script.varSize
        + witnesses.varSize
    }
    
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
        return SerializableTransaction(version: version, nonce: nonce,
                     validUntilBlock: validUntilBlock,
                     signers: signers, systemFee: systemFee,
                     networkFee: networkFee, attributes: attributes,
                     script: script, witnesses: witnesses) as! Self
    }
    
    private static func readTransactionAttributes(_ reader: BinaryReader, _ signerSize: Int) throws -> [TransactionAttribute] {
        let nrOfAttributes = reader.readVarInt()
        guard nrOfAttributes + signerSize <= NeoConstants.MAX_TRANSACTION_ATTRIBUTES else {
            throw "A transaction can hold at most \(NeoConstants.MAX_TRANSACTION_ATTRIBUTES) attributes (including signers). Input data had \(signerSize) attributes."
        }
        return try (0..<nrOfAttributes).map { _ in try TransactionAttribute.deserialize(reader) }
    }
    
    public func toContractParametersContext() async throws -> ContractParametersContext {
        let hash = try getTxId().string
        let data = toArrayWithoutWitnesses().base64Encoded
        try throwIfNeoSwiftNil()
        let network = try await neoSwift!.getNetworkMagicNumber()
        
        let items: [String: ContractParametersContext.ContextItem] = try signers.map { signer in
            guard let accountSigner = signer as? AccountSigner else {
                throw "Cannot handle contract signers"
            }
            guard let verificationScript = accountSigner.account.verificationScript else {
                throw "Account on AccountSigner has no verification script"
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
