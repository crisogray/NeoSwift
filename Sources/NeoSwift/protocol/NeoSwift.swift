
import Combine
import Foundation

open class NeoSwift: Neo, NeoSwiftRx {
    
    public var config: NeoSwiftConfig
    
    public var nnsResolver: Hash160 { return config.nnsResolver}
    public var blockInterval: Int { return config.blockInterval }
    public var pollingInterval: Int { return config.pollingInterval }
    public var maxValidUntilBlockIncrement: Int { return config.maxValidUntilBlockIncrement }
    
    internal let neoSwiftService: NeoSwiftService
    private lazy var neoSwiftRx: JsonRpc2_0Rx = {
        return JsonRpc2_0Rx(neoSwift: self, executorService: .global(qos: .background))
    }()
    
    required public init(config: NeoSwiftConfig, neoSwiftService: NeoSwiftService) {
        self.config = config
        self.neoSwiftService = neoSwiftService
    }
    
    public static func build( _ neoSwiftService: NeoSwiftService, _ config: NeoSwiftConfig = .init()) -> Self {
        return Self.init(config: config, neoSwiftService: neoSwiftService)
    }
    
    public func allowTransmissionOnFault() {
        _ = config.allowTransmissionOnFault()
    }
    
    public func preventTransmissionOnFault() {
        _ = config.preventTransmissionOnFault()
    }
    
    public func setNNSResolver(_ nnsResolver: Hash160) {
        _ = config.setNNSResolver(nnsResolver)
    }
    
    public func getNetworkMagicNumberBytes() async throws -> Bytes {
        let magicInt = try await getNetworkMagicNumber() & 0xFFFFFFFF
        return UInt32(magicInt).bigEndianBytes
    }
    
    public func getNetworkMagicNumber() async throws -> Int {
        if config.networkMagic == nil {
            guard let magic = try await getVersion().send().getResult().protocol?.network else {
                throw "Unable to read Network Magic Number from Version"
            }
            _ = try config.setNetworkMagic(magic)
        }
        return config.networkMagic!
    }
    
    // MARK: Blockchain Methods
    
    public func getBestBlockHash() -> Request<NeoBlockHash, Hash256> {
        return .init(method: "getbestblockhash", params: [], neoSwiftService: neoSwiftService)
    }
    
    public func getBlockHash(_ blockIndex: Int) -> Request<NeoBlockHash, Hash256> {
        return .init(method: "getblockhash", params: [blockIndex], neoSwiftService: neoSwiftService)
    }
    
    public func getBlock(_ blockHash: Hash256, _ returnFullTransactionObjects: Bool) -> Request<NeoGetBlock, NeoBlock> {
        if returnFullTransactionObjects {
            return .init(method: "getblock", params: [blockHash.string, 1], neoSwiftService: neoSwiftService)
        } else {
            return getBlockHeader(blockHash)
        }
    }
    
    public func getRawBlock(_ blockHash: Hash256) -> Request<NeoGetRawBlock, String> {
        return .init(method: "getblock", params: [blockHash.string, 0], neoSwiftService: neoSwiftService)
    }
    
    public func getBlock(_ blockIndex: Int, _ returnFullTransactionObjects: Bool) -> Request<NeoGetBlock, NeoBlock> {
        if returnFullTransactionObjects {
            return .init(method: "getblock", params: [blockIndex, 1], neoSwiftService: neoSwiftService)
        } else {
            return getBlockHeader(blockIndex)
        }
    }
    
    public func getRawBlock(_ blockIndex: Int) -> Request<NeoGetRawBlock, String> {
        return .init(method: "getblock", params: [blockIndex, 0], neoSwiftService: neoSwiftService)
    }
    
    public func getBlockHeaderCount() -> Request<NeoBlockHeaderCount, Int> {
        return .init(method: "getblockheadercount", params: [], neoSwiftService: neoSwiftService)
    }
    
    public func getBlockCount() -> Request<NeoBlockCount, Int> {
        return .init(method: "getblockcount", params: [], neoSwiftService: neoSwiftService)
    }
    
    public func getBlockHeader(_ blockHash: Hash256) -> Request<NeoGetBlock, NeoBlock> {
        return .init(method: "getblockheader", params: [blockHash.string, 1], neoSwiftService: neoSwiftService)
    }
    
    public func getBlockHeader(_ blockIndex: Int) -> Request<NeoGetBlock, NeoBlock> {
        return .init(method: "getblockheader", params: [blockIndex, 1], neoSwiftService: neoSwiftService)
    }
    
    public func getRawBlockHeader(_ blockHash: Hash256) -> Request<NeoGetRawBlock, String> {
        return .init(method: "getblockheader", params: [blockHash.string, 0], neoSwiftService: neoSwiftService)
    }
    
    public func getRawBlockHeader(_ blockIndex: Int) -> Request<NeoGetRawBlock, String> {
        return .init(method: "getblockheader", params: [blockIndex, 0], neoSwiftService: neoSwiftService)
    }
    
    public func getNativeContracts() -> Request<NeoGetNativeContracts, [NativeContractState]> {
        return .init(method: "getnativecontracts", params: [], neoSwiftService: neoSwiftService)
    }
    
    public func getContractState(_ contractHash: Hash160) -> Request<NeoGetContractState, ContractState> {
        return .init(method: "getcontractstate", params: [contractHash.string], neoSwiftService: neoSwiftService)
    }
    
    public func getNativeContractState(_ contractName: String) -> Request<NeoGetContractState, ContractState> {
        return .init(method: "getcontractstate", params: [contractName], neoSwiftService: neoSwiftService)
    }
    
    public func getMemPool() -> Request<NeoGetMemPool, NeoGetMemPool.MemPoolDetails> {
        return .init(method: "getrawmempool", params: [1], neoSwiftService: neoSwiftService)
    }
    
    public func getRawMemPool() -> Request<NeoGetRawMemPool, [Hash256]> {
        return .init(method: "getrawmempool", params: [], neoSwiftService: neoSwiftService)
    }
    
    public func getTransaction(_ txHash: Hash256) -> Request<NeoGetTransaction, Transaction> {
        return .init(method: "getrawtransaction", params: [txHash.string, 1], neoSwiftService: neoSwiftService)
    }
    
    public func getRawTransaction(_ txHash: Hash256) -> Request<NeoGetRawTransaction, String> {
        return .init(method: "getrawtransaction", params: [txHash.string, 0], neoSwiftService: neoSwiftService)
    }
    
    public func getStorage(_ contractHash: Hash160, _ keyHexString: String) -> Request<NeoGetStorage, String> {
        return .init(method: "getstorage", params: [contractHash.string, keyHexString.base64Encoded], neoSwiftService: neoSwiftService)
    }
    
    public func getTransactionHeight(_ txHash: Hash256) -> Request<NeoGetTransactionHeight, Int> {
        return .init(method: "gettransactionheight", params: [txHash.string], neoSwiftService: neoSwiftService)
    }
    
    public func getNextBlockValidators() -> Request<NeoGetNextBlockValidators, [NeoGetNextBlockValidators.Validator]> {
        return .init(method: "getnextblockvalidators", params: [], neoSwiftService: neoSwiftService)
    }
    
    public func getCommittee() -> Request<NeoGetCommittee, [String]> {
        return .init(method: "getcommittee", params: [], neoSwiftService: neoSwiftService)
    }
    
    // MARK: Node Methods
    
    public func getConnectionCount() -> Request<NeoConnectionCount, Int> {
        return .init(method: "getconnectioncount", params: [], neoSwiftService: neoSwiftService)
    }
    
    public func getPeers() -> Request<NeoGetPeers, NeoGetPeers.Peers> {
        return .init(method: "getpeers", params: [], neoSwiftService: neoSwiftService)
    }
    
    public func getVersion() -> Request<NeoGetVersion, NeoGetVersion.NeoVersion> {
        return .init(method: "getversion", params: [], neoSwiftService: neoSwiftService)
    }
    
    public func sendRawTransaction(_ rawTransactionHex: String) -> Request<NeoSendRawTransaction, NeoSendRawTransaction.RawTransaction> {
        return .init(method: "sendrawtransaction", params: [rawTransactionHex.base64Encoded], neoSwiftService: neoSwiftService)
    }
    
    public func submitBlock(_ serializedBlockAsHex: String) -> Request<NeoSubmitBlock, Bool> {
        return .init(method: "submitblock", params: [serializedBlockAsHex], neoSwiftService: neoSwiftService)
    }
    
    // MARK: SmartContract Methods
    
    public func invokeFunction(_ contractHash: Hash160, _ functionName: String, _ signers: [Signer]) -> Request<NeoInvokeFunction, InvocationResult> {
        return invokeFunction(contractHash, functionName, [], signers)
    }
    
    public func invokeFunction(_ contractHash: Hash160, _ functionName: String, _ params: [ContractParameter], _ signers: [Signer]) -> Request<NeoInvokeFunction, InvocationResult> {
        let signers = signers.map(TransactionSigner.init)
        return .init(method: "invokefunction", params: [contractHash.string, functionName, params, signers], neoSwiftService: neoSwiftService)
    }
    
    public func invokeFunctionDiagnostics(_ contractHash: Hash160, _ functionName: String, _ signers: [Signer]) -> Request<NeoInvokeFunction, InvocationResult> {
        return invokeFunction(contractHash, functionName, [], signers)
    }
    
    public func invokeFunctionDiagnostics(_ contractHash: Hash160, _ functionName: String, _ params: [ContractParameter], _ signers: [Signer] = []) -> Request<NeoInvokeFunction, InvocationResult> {
        let signers = signers.map(TransactionSigner.init)
        return .init(method: "invokefunction", params: [contractHash.string, functionName, params, signers, true], neoSwiftService: neoSwiftService)
    }
    
    public func invokeScript(_ scriptHex: String, _ signers: [Signer] = []) -> Request<NeoInvokeScript, InvocationResult> {
        let signers = signers.map(TransactionSigner.init)
        return .init(method: "invokescript", params: [scriptHex.base64Encoded, signers], neoSwiftService: neoSwiftService)
    }
    
    public func invokeScriptDiagnostics(_ scriptHex: String, _ signers: [Signer] = []) -> Request<NeoInvokeScript, InvocationResult> {
        let signers = signers.map(TransactionSigner.init)
        return .init(method: "invokescript", params: [scriptHex.base64Encoded, signers, true], neoSwiftService: neoSwiftService)
    }
    
    public func traverseIterator(_ sessionId: String, _ iteratorId: String, _ count: Int) -> Request<NeoTraverseIterator, [StackItem]> {
        return .init(method: "traverseiterator", params: [sessionId, iteratorId, count], neoSwiftService: neoSwiftService)
    }
    
    public func terminateSession(_ sessionId: String) -> Request<NeoTerminateSession, Bool> {
        return .init(method: "terminatesession", params: [sessionId], neoSwiftService: neoSwiftService)
    }
    
    public func invokeContractVerify(_ contractHash: Hash160, _ methodParameters: [ContractParameter] = [], _ signers: [Signer] = []) -> Request<NeoInvokeContractVerify, InvocationResult> {
        let signers = signers.map(TransactionSigner.init)
        return .init(method: "invokecontractverify", params: [contractHash.string, methodParameters, signers], neoSwiftService: neoSwiftService)
    }
    
    public func getUnclaimedGas(_ scriptHash: Hash160) -> Request<NeoGetUnclaimedGas, NeoGetUnclaimedGas.GetUnclaimedGas> {
        return .init(method: "getunclaimedgas", params: [scriptHash.toAddress()], neoSwiftService: neoSwiftService)
    }
    
    // MARK: Utilities Methods
    
    public func listPlugins() -> Request<NeoListPlugins, [NeoListPlugins.Plugin]> {
        return .init(method: "listplugins", params: [], neoSwiftService: neoSwiftService)
    }
    
    public func validateAddress(_ address: String) -> Request<NeoValidateAddress, NeoValidateAddress.Result> {
        return .init(method: "validateaddress", params: [address], neoSwiftService: neoSwiftService)
    }
    
    // MARK: Wallet Methods
    
    public func closeWallet() -> Request<NeoCloseWallet, Bool> {
        return .init(method: "closewallet", params: [], neoSwiftService: neoSwiftService)
    }
    
    public func dumpPrivKey(_ scriptHash: Hash160) -> Request<NeoDumpPrivKey, String> {
        return .init(method: "dumpprivkey", params: [scriptHash.toAddress()], neoSwiftService: neoSwiftService)
    }
    
    public func getWalletBalance(_ tokenHash: Hash160) -> Request<NeoGetWalletBalance, NeoGetWalletBalance.Balance> {
        return .init(method: "getwalletbalance", params: [tokenHash.string], neoSwiftService: neoSwiftService)
    }
    
    public func getNewAddress() -> Request<NeoGetNewAddress, String> {
        return .init(method: "getnewaddress", params: [], neoSwiftService: neoSwiftService)
    }
    
    public func getWalletUnclaimedGas() -> Request<NeoGetWalletUnclaimedGas, String> {
        return .init(method: "getwalletunclaimedgas", params: [], neoSwiftService: neoSwiftService)
    }
    
    public func importPrivKey(_ privateKeyInWIF: String) -> Request<NeoImportPrivKey, NeoAddress> {
        return .init(method: "importprivkey", params: [privateKeyInWIF], neoSwiftService: neoSwiftService)
    }
    
    public func calculateNetworkFee(_ transactionHex: String) -> Request<NeoCalculateNetworkFee, NeoNetworkFee> {
        return .init(method: "calculatenetworkfee", params: [transactionHex.base64Encoded], neoSwiftService: neoSwiftService)
    }
    
    public func listAddress() -> Request<NeoListAddress, [NeoAddress]> {
        return .init(method: "listaddress", params: [], neoSwiftService: neoSwiftService)
    }
    
    public func openWallet(_ walletPath: String, _ password: String) -> Request<NeoOpenWallet, Bool> {
        return .init(method: "openwallet", params: [walletPath, password], neoSwiftService: neoSwiftService)
    }
    
    public func sendFrom(_ tokenHash: Hash160, _ from: Hash160, _ to: Hash160, _ amount: Int) -> Request<NeoSendFrom, Transaction> {
        return .init(method: "sendfrom", params: [tokenHash.string, from.toAddress(), to.toAddress(), amount], neoSwiftService: neoSwiftService)
    }
    
    public func sendFrom(_ from: Hash160, _ txSendToken: TransactionSendToken) throws -> Request<NeoSendFrom, Transaction> {
        return try sendFrom(txSendToken.token, from, Hash160.fromAddress(txSendToken.address), txSendToken.value)
    }
    
    public func sendMany(_ txSendTokens: [TransactionSendToken]) -> Request<NeoSendMany, Transaction> {
        return .init(method: "sendmany", params: [txSendTokens], neoSwiftService: neoSwiftService)
    }
    
    public func sendMany(_ from: Hash160, _ txSendTokens: [TransactionSendToken]) -> Request<NeoSendMany, Transaction> {
        return .init(method: "sendmany", params: [from.toAddress(), txSendTokens], neoSwiftService: neoSwiftService)
    }
    
    public func sendToAddress(_ tokenHash: Hash160, _ to: Hash160, _ amount: Int) -> Request<NeoSendToAddress, Transaction> {
        return .init(method: "sendtoaddress", params: [tokenHash.string, to.toAddress(), amount], neoSwiftService: neoSwiftService)
    }
    
    public func sendToAddress(_ txSendToken: TransactionSendToken) throws -> Request<NeoSendToAddress, Transaction> {
        return try sendToAddress(txSendToken.token, Hash160.fromAddress(txSendToken.address), txSendToken.value)
    }
    
    // MARK: ApplicationLogs
    
    public func getApplicationLog(_ txHash: Hash256) -> Request<NeoGetApplicationLog, NeoApplicationLog> {
        return .init(method: "getapplicationlog", params: [txHash.string], neoSwiftService: neoSwiftService)
    }
    
    // MARK: TokenTracker NEP-17
    
    public func getNep17Balances(_ scriptHash: Hash160) -> Request<NeoGetNep17Balances, NeoGetNep17Balances.Nep17Balances> {
        return .init(method: "getnep17balances", params: [scriptHash.toAddress()], neoSwiftService: neoSwiftService)
    }
    
    public func getNep17Transfers(_ scriptHash: Hash160) -> Request<NeoGetNep17Transfers, NeoGetNep17Transfers.Nep17Transfers> {
        return .init(method: "getnep17transfers", params: [scriptHash.toAddress()], neoSwiftService: neoSwiftService)
    }
    
    public func getNep17Transfers(_ scriptHash: Hash160, _ from: Date) -> Request<NeoGetNep17Transfers, NeoGetNep17Transfers.Nep17Transfers> {
        return .init(method: "getnep17transfers", params: [scriptHash.toAddress(), from.millisecondsSince1970], neoSwiftService: neoSwiftService)
    }
    
    public func getNep17Transfers(_ scriptHash: Hash160, _ from: Date, _ to: Date) -> Request<NeoGetNep17Transfers, NeoGetNep17Transfers.Nep17Transfers> {
        return .init(method: "getnep17transfers", params: [scriptHash.toAddress(), from.millisecondsSince1970, to.millisecondsSince1970], neoSwiftService: neoSwiftService)
    }
    
    // MARK: TokenTracker NEP-11
    
    public func getNep11Balances(_ scriptHash: Hash160) -> Request<NeoGetNep11Balances, NeoGetNep11Balances.Nep11Balances> {
        return .init(method: "getnep11balances", params: [scriptHash.toAddress()], neoSwiftService: neoSwiftService)
    }
    
    public func getNep11Transfers(_ scriptHash: Hash160) -> Request<NeoGetNep11Transfers, NeoGetNep11Transfers.Nep11Transfers> {
        return .init(method: "getnep11transfers", params: [scriptHash.toAddress()], neoSwiftService: neoSwiftService)
    }
    
    public func getNep11Transfers(_ scriptHash: Hash160, _ from: Date) -> Request<NeoGetNep11Transfers, NeoGetNep11Transfers.Nep11Transfers> {
        return .init(method: "getnep11transfers", params: [scriptHash.toAddress(), from.millisecondsSince1970], neoSwiftService: neoSwiftService)
    }
    
    public func getNep11Transfers(_ scriptHash: Hash160, _ from: Date, _ to: Date) -> Request<NeoGetNep11Transfers, NeoGetNep11Transfers.Nep11Transfers> {
        return .init(method: "getnep11transfers", params: [scriptHash.toAddress(), from.millisecondsSince1970, to.millisecondsSince1970], neoSwiftService: neoSwiftService)
    }
    
    public func getNep11Properties(_ scriptHash: Hash160, _ tokenId: String) -> Request<NeoGetNep11Properties, [String : String]> {
        return .init(method: "getnep11properties", params: [scriptHash.toAddress(), tokenId], neoSwiftService: neoSwiftService)
    }
    
    // MARK: StateService
    
    public func getStateRoot(_ blockIndex: Int) -> Request<NeoGetStateRoot, NeoGetStateRoot.StateRoot> {
        return .init(method: "getstateroot", params: [blockIndex], neoSwiftService: neoSwiftService)
    }
    
    public func getProof(_ rootHash: Hash256, _ contractHash: Hash160, _ storageKeyHex: String) -> Request<NeoGetProof, String> {
        return .init(method: "getproof", params: [rootHash.string, contractHash.string, storageKeyHex.base64Encoded], neoSwiftService: neoSwiftService)
    }
    
    public func verifyProof(_ rootHash: Hash256, _ proofDataHex: String) -> Request<NeoVerifyProof, String> {
        return .init(method: "verifyproof", params: [rootHash.string, proofDataHex.base64Encoded], neoSwiftService: neoSwiftService)
    }
    
    public func getStateHeight() -> Request<NeoGetStateHeight, NeoGetStateHeight.StateHeight> {
        return .init(method: "getstateheight", params: [], neoSwiftService: neoSwiftService)
    }
    
    public func getState(_ rootHash: Hash256, _ contractHash: Hash160, _ keyHex: String) -> Request<NeoGetState, String> {
        return .init(method: "getstate", params: [rootHash.string, contractHash.string, keyHex.base64Encoded], neoSwiftService: neoSwiftService)
    }
    
    public func findStates(_ rootHash: Hash256, _ contractHash: Hash160, _ keyPrefixHex: String, _ startKeyHex: String?, _ countFindResultItems: Int?) -> Request<NeoFindStates, NeoFindStates.States> {
        var parameters: [AnyHashable] = [rootHash.string, contractHash.string, keyPrefixHex.base64Encoded]
        if let startKeyHex = startKeyHex {
            parameters.append(startKeyHex.base64Encoded)
        }
        if let countFindResultItems = countFindResultItems {
            if startKeyHex == nil { parameters.append("") }
            parameters.append(countFindResultItems)
        }
        return .init(method: "findstates", params: parameters, neoSwiftService: neoSwiftService)
    }
    
    public func findStates(_ rootHash: Hash256, _ contractHash: Hash160, _ keyPrefixHex: String, _ startKeyHex: String?) -> Request<NeoFindStates, NeoFindStates.States> {
        findStates(rootHash, contractHash, keyPrefixHex, startKeyHex, nil)
    }
    
    public func findStates(_ rootHash: Hash256, _ contractHash: Hash160, _ keyPrefixHex: String, _ countFindResultItems: Int?) -> Request<NeoFindStates, NeoFindStates.States> {
        findStates(rootHash, contractHash, keyPrefixHex, nil, countFindResultItems)
    }
    
    public func findStates(_ rootHash: Hash256, _ contractHash: Hash160, _ keyPrefixHex: String) -> Request<NeoFindStates, NeoFindStates.States> {
        findStates(rootHash, contractHash, keyPrefixHex, nil, nil)
    }
 
    public func shutdown() { }
    
    // MARK: NeoSwiftRx
    
    public func blockPublisher(_ fullTransactionObjects: Bool) -> AnyPublisher<NeoGetBlock, Error> {
        return neoSwiftRx.blockPublisher(fullTransactionObjects, config.pollingInterval)
    }
    
    public func replayBlocksPublisher(_ startBlock: Int, _ endBlock: Int, _ fullTransactionObjects: Bool) -> AnyPublisher<NeoGetBlock, Error> {
        return neoSwiftRx.replayBlocksPublisher(startBlock, endBlock, fullTransactionObjects, true)
    }
    
    public func replayBlocksPublisher(_ startBlock: Int, _ endBlock: Int, _ fullTransactionObjects: Bool, _ ascending: Bool) -> AnyPublisher<NeoGetBlock, Error> {
        return neoSwiftRx.replayBlocksPublisher(startBlock, endBlock, fullTransactionObjects, ascending)
    }
    
    public func catchUpToLatestBlockPublisher(_ startBlock: Int, _ fullTransactionObjects: Bool) -> AnyPublisher<NeoGetBlock, Error> {
        return neoSwiftRx.catchUpToLatestBlockPublisher(startBlock, fullTransactionObjects, onCaughtUpPublisher: .init(Empty()))
    }
    
    open func catchUpToLatestAndSubscribeToNewBlocksPublisher(_ startBlock: Int, _ fullTransactionObjects: Bool) -> AnyPublisher<NeoGetBlock, Error> {
        return neoSwiftRx.catchUpToLatestAndSubscribeToNewBlocksPublisher(startBlock, fullTransactionObjects, config.pollingInterval)
    }
    
    public func subscribeToNewBlocksPublisher(_ fullTransactionObjects: Bool) -> AnyPublisher<NeoGetBlock, Error> {
        return neoSwiftRx.blockPublisher(fullTransactionObjects, config.pollingInterval)
    }
        
}

