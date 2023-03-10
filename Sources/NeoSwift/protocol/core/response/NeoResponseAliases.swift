
public class NeoBlockCount: Response<Int> { var blockCount: Int? { return result } }

public class NeoBlockHash: Response<Hash256> { var blockHash: Hash256? { return result } }

typealias NeoBlockHeaderCount = NeoConnectionCount

public class NeoCalculateNetworkFee: Response<NeoNetworkFee> { var networkFee: NeoNetworkFee? { return result } }

public class NeoCloseWallet: Response<Bool> { var closeWallet: Bool? { return result } }

public class NeoConnectionCount: Response<Int> { var count: Int? { return result } }

public class NeoDumpPrivKey: Response<String> { var dumpPrivKey: String? { return result } }

public class NeoExpressCreateCheckpoint: Response<String> { var filename: String? { return result } }

public class NeoExpressCreateOracleResponseTx: Response<String> { var oracleResponseTx: String? { return result } }

public class NeoExpressGetContractStorage: Response<[ContractStorageEntry]> { var contractStorage: [ContractStorageEntry]? { return result } }

public class NeoExpressGetNep17Contracts: Response<[Nep17Contract]> { var nep17Contracts: [Nep17Contract]? { return result } }

public class NeoExpressGetPopulatedBlocks: Response<PopulatedBlocks> { var populatedBlocks: PopulatedBlocks? { return result } }

public class NeoExpressListContracts: Response<[ExpressContractState]> { var contracts: [ExpressContractState]? { return result } }

public class NeoExpressListOracleRequests: Response<[OracleRequest]> { var oracleRequests: [OracleRequest]? { return result } }

public class NeoExpressShutdown: Response<ExpressShutdown> { var expressShutdown: ExpressShutdown? { return result } }

public class NeoGetApplicationLog: Response<NeoApplicationLog> { var applicationLog: NeoApplicationLog? { return result } }

public class NeoGetBlock: Response<NeoBlock> { var block: NeoBlock? { return result } }

public class NeoGetCommittee: Response<[String]> { var committee: [String]? { return result } }

public class NeoGetContractState: Response<ContractState> { var contractState: ContractState? { return result } }

public class NeoGetNativeContracts: Response<[NativeContractState]> { var nativeContracts: [NativeContractState]? { return result } }

public class NeoGetNep11Properties: Response<[String : String]> { var properties: [String : String]? { return result } }

public class NeoGetNewAddress: Response<String> { var address: String? { return result } }

public class NeoGetProof: Response<String> { var proof: String? { return result } }

public class NeoGetRawBlock: Response<String> { var rawBlock: String? { return result } }

public class NeoGetRawMemPool: Response<[Hash256]> { var addresses: [Hash256]? { return result } }

public class NeoGetRawTransaction: Response<String> { var rawTransaction: String? { return result } }

public class NeoGetState: Response<String> { var state: String? { return result } }

public class NeoGetStorage: Response<String> { var storage: String? { return result } }

public class NeoGetTransaction: Response<Transaction> { var transaction: Transaction? { return result } }

public class NeoGetWalletHeight: Response<Int> { var height: Int? { return result } }

typealias NeoGetTransactionHeight = NeoGetWalletHeight

public class NeoGetWalletUnclaimedGas: Response<String> { var walletUnclaimedGas: String? { return result } }

public class NeoImportPrivKey: Response<NeoAddress> { var address: NeoAddress? { return result } }

public class NeoInvoke: Response<InvocationResult> { var invocationResult: InvocationResult? { return result } }

typealias NeoInvokeContractVerify = NeoInvoke
typealias NeoInvokeFunction = NeoInvoke
typealias NeoInvokeScript = NeoInvoke

public class NeoListAddress: Response<[NeoAddress]> { var addresses: [NeoAddress]? { return result } }

public class NeoOpenWallet: Response<Bool> { var openWallet: Bool? { return result } }

public class NeoSendFrom: Response<Transaction> { var sendFrom: Transaction? { return result } }

public class NeoSendMany: Response<Transaction> { var sendMany: Transaction? { return result } }

public class NeoSendToAddress: Response<Transaction> { var sendToAddress: Transaction? { return result } }

public class NeoSubmitBlock: Response<Bool> { var submitBlock: Bool? { return result } }

public class NeoTerminateSession: Response<Bool> { var terminateSession: Bool? { return result } }

public class NeoTraverseIterator: Response<[StackItem]> { var traverseIterator: [StackItem]? { return result } }

public class NeoVerifyProof: Response<String> { var verifyProof: String? { return result } }
