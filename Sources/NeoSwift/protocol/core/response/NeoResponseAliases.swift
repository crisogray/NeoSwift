
public class NeoBlockCount: Response<Int> { public var blockCount: Int? { return result } }

public class NeoBlockHash: Response<Hash256> { public var blockHash: Hash256? { return result } }

public typealias NeoBlockHeaderCount = NeoConnectionCount

public class NeoCalculateNetworkFee: Response<NeoNetworkFee> { public var networkFee: NeoNetworkFee? { return result } }

public class NeoCloseWallet: Response<Bool> { public var closeWallet: Bool? { return result } }

public class NeoConnectionCount: Response<Int> { public var count: Int? { return result } }

public class NeoDumpPrivKey: Response<String> { public var dumpPrivKey: String? { return result } }

public class NeoExpressCreateCheckpoint: Response<String> { public var filename: String? { return result } }

public class NeoExpressCreateOracleResponseTx: Response<String> { public var oracleResponseTx: String? { return result } }

public class NeoExpressGetContractStorage: Response<[ContractStorageEntry]> { public var contractStorage: [ContractStorageEntry]? { return result } }

public class NeoExpressGetNep17Contracts: Response<[Nep17Contract]> { public var nep17Contracts: [Nep17Contract]? { return result } }

public class NeoExpressGetPopulatedBlocks: Response<PopulatedBlocks> { public var populatedBlocks: PopulatedBlocks? { return result } }

public class NeoExpressListContracts: Response<[ExpressContractState]> { public var contracts: [ExpressContractState]? { return result } }

public class NeoExpressListOracleRequests: Response<[OracleRequest]> { public var oracleRequests: [OracleRequest]? { return result } }

public class NeoExpressShutdown: Response<ExpressShutdown> { public var expressShutdown: ExpressShutdown? { return result } }

public class NeoGetApplicationLog: Response<NeoApplicationLog> { public var applicationLog: NeoApplicationLog? { return result } }

public class NeoGetBlock: Response<NeoBlock> { public var block: NeoBlock? { return result } }

public class NeoGetCommittee: Response<[String]> { public var committee: [String]? { return result } }

public class NeoGetContractState: Response<ContractState> { public var contractState: ContractState? { return result } }

public class NeoGetNativeContracts: Response<[NativeContractState]> { public var nativeContracts: [NativeContractState]? { return result } }

public class NeoGetNep11Properties: Response<[String : String]> { public var properties: [String : String]? { return result } }

public class NeoGetNewAddress: Response<String> { public var address: String? { return result } }

public class NeoGetProof: Response<String> { public var proof: String? { return result } }

public class NeoGetRawBlock: Response<String> { public var rawBlock: String? { return result } }

public class NeoGetRawMemPool: Response<[Hash256]> { public var addresses: [Hash256]? { return result } }

public class NeoGetRawTransaction: Response<String> { public var rawTransaction: String? { return result } }

public class NeoGetState: Response<String> { public var state: String? { return result } }

public class NeoGetStorage: Response<String> { public var storage: String? { return result } }

public class NeoGetTransaction: Response<Transaction> { public var transaction: Transaction? { return result } }

public class NeoGetWalletHeight: Response<Int> { public var height: Int? { return result } }

public typealias NeoGetTransactionHeight = NeoGetWalletHeight

public class NeoGetWalletUnclaimedGas: Response<String> { public var walletUnclaimedGas: String? { return result } }

public class NeoImportPrivKey: Response<NeoAddress> { public var address: NeoAddress? { return result } }

public class NeoInvoke: Response<InvocationResult> { public var invocationResult: InvocationResult? { return result } }

public typealias NeoInvokeContractVerify = NeoInvoke
public typealias NeoInvokeFunction = NeoInvoke
public typealias NeoInvokeScript = NeoInvoke

public class NeoListAddress: Response<[NeoAddress]> { public var addresses: [NeoAddress]? { return result } }

public class NeoOpenWallet: Response<Bool> { public var openWallet: Bool? { return result } }

public class NeoSendFrom: Response<Transaction> { public var sendFrom: Transaction? { return result } }

public class NeoSendMany: Response<Transaction> { public var sendMany: Transaction? { return result } }

public class NeoSendToAddress: Response<Transaction> { public var sendToAddress: Transaction? { return result } }

public class NeoSubmitBlock: Response<Bool> { public var submitBlock: Bool? { return result } }

public class NeoTerminateSession: Response<Bool> { public var terminateSession: Bool? { return result } }

public class NeoTraverseIterator: Response<[StackItem]> { public var traverseIterator: [StackItem]? { return result } }

public class NeoVerifyProof: Response<String> { public var verifyProof: String? { return result } }
