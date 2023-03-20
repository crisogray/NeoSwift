import Combine
import Foundation

public protocol Neo {
    
    // MARK: Blockchain Methods
    
    func getBestBlockHash() -> Request<NeoBlockHash, Hash256>
    func getBlockHash(_ blockIndex: Int) -> Request<NeoBlockHash, Hash256>
    func getBlock(_ blockHash: Hash256, _ returnFullTransactionObjects: Bool) -> Request<NeoGetBlock, NeoBlock>
    func getBlock(_ blockIndex: Int, _ returnFullTransactionObjects: Bool) -> Request<NeoGetBlock, NeoBlock>
    func getRawBlock(_ blockHash: Hash256) -> Request<NeoGetRawBlock, String>
    func getRawBlock(_ blockIndex: Int) -> Request<NeoGetRawBlock, String>
    func getBlockHeaderCount() -> Request<NeoBlockHeaderCount, Int>
    func getBlockCount() -> Request<NeoBlockCount, Int>
    func getBlockHeader(_ blockHash: Hash256) -> Request<NeoGetBlock, NeoBlock>
    func getBlockHeader(_ blockIndex: Int) -> Request<NeoGetBlock, NeoBlock>
    func getRawBlockHeader(_ blockHash: Hash256) -> Request<NeoGetRawBlock, String>
    func getRawBlockHeader(_ blockIndex: Int) -> Request<NeoGetRawBlock, String>
    func getNativeContracts() -> Request<NeoGetNativeContracts, [NativeContractState]>
    func getContractState(_ contractHash: Hash160) -> Request<NeoGetContractState, ContractState>
    func getNativeContractState(_ contractName: String) -> Request<NeoGetContractState, ContractState>
    func getMemPool() -> Request<NeoGetMemPool, NeoGetMemPool.MemPoolDetails>
    func getRawMemPool() -> Request<NeoGetRawMemPool, [Hash256]>
    func getTransaction(_ txHash: Hash256) -> Request<NeoGetTransaction, Transaction>
    func getRawTransaction(_ txHash: Hash256) -> Request<NeoGetRawTransaction, String>
    func getStorage(_ contractHash: Hash160, _ keyHexString: String) -> Request<NeoGetStorage, String>
    func getTransactionHeight(_ txHash: Hash256) -> Request<NeoGetTransactionHeight, Int>
    func getNextBlockValidators() -> Request<NeoGetNextBlockValidators, [NeoGetNextBlockValidators.Validator]>
    func getCommittee() -> Request<NeoGetCommittee, [String]>
    
    // MARK: Node Methods
    
    func getConnectionCount() -> Request<NeoConnectionCount, Int>
    func getPeers() -> Request<NeoGetPeers, NeoGetPeers.Peers>
    func getVersion() -> Request<NeoGetVersion, NeoGetVersion.NeoVersion>
    func sendRawTransaction(_ rawTransactionHex: String) -> Request<NeoSendRawTransaction, NeoSendRawTransaction.RawTransaction>
    func submitBlock(_ serializedBlockAsHex: String) -> Request<NeoSubmitBlock, Bool>
    
    // MARK: SmartContract Methods
    
    func invokeFunction(_ contractHash: Hash160, _ functionName: String, _ signers: Signer...) -> Request<NeoInvokeFunction, InvocationResult>
    func invokeFunction(_ contractHash: Hash160, _ functionName: String, _ params: [ContractParameter], _ signers: Signer...) -> Request<NeoInvokeFunction, InvocationResult>
    func invokeFunctionDiagnostics(_ contractHash: Hash160, _ functionName: String, _ signers: Signer...) -> Request<NeoInvokeFunction, InvocationResult>
    func invokeFunctionDiagnostics(_ contractHash: Hash160, _ functionName: String, _ params: [ContractParameter], _ signers: Signer...) -> Request<NeoInvokeFunction, InvocationResult>
    func invokeScript(_ scriptHex: String, _ signers: Signer...) -> Request<NeoInvokeScript, InvocationResult>
    func invokeScriptDiagnostics(_ scriptHex: String, _ signers: Signer...) -> Request<NeoInvokeScript, InvocationResult>
    func traverseIterator(_ sessionId: String, _ iteratorId: String, _ count: Int) -> Request<NeoTraverseIterator, [StackItem]>
    func termiateSession(_ sessionId: String) -> Request<NeoTerminateSession, Bool>
    func invokeContractVerify(_ contractHash: Hash160, _ methodParameters: [ContractParameter], _ signers: Signer...) -> Request<NeoInvokeContractVerify, InvocationResult>
    func getUnclaimedGas(_ scriptHash: Hash160) -> Request<NeoGetUnclaimedGas, NeoGetUnclaimedGas.GetUnclaimedGas>
    
    // MARK: Utilities Methods
    
    func listPlugins() -> Request<NeoListPlugins, [NeoListPlugins.Plugin]>
    func validateAddress(_ address: String) -> Request<NeoValidateAddress, NeoValidateAddress.Result>
    
    // MARK: Wallet Counts
    
    func closeWallet() -> Request<NeoCloseWallet, Bool>
    func openWallet(_ walletPath: String, _ password: String) -> Request<NeoOpenWallet, Bool>
    func dumpPrivKey(_ scriptHash: Hash160) -> Request<NeoDumpPrivKey, String>
    func getWalletBalance(_ tokenHash: Hash160) -> Request<NeoGetWalletBalance, NeoGetWalletBalance.Balance>
    func getNewAddress() -> Request<NeoGetNewAddress, String>
    func getWalletUnclaimedGas() -> Request<NeoGetWalletUnclaimedGas, String>
    func importPrivKey(_ privateKeyInWIF: String) -> Request<NeoImportPrivKey, NeoAddress>
    func calculateNetworkFee(_ transactionHex: String) -> Request<NeoCalculateNetworkFee, NeoNetworkFee>
    func listAddress() -> Request<NeoListAddress, [NeoAddress]>
    func sendFrom(_ tokenHash: Hash160, _ from: Hash160, _ to: Hash160, _ amount: Int) -> Request<NeoSendFrom, Transaction>
    func sendFrom(_ from: Hash160, _ txSendToken: TransactionSendToken) -> Request<NeoSendFrom, Transaction>
    func sendMany(_ txSendTokens: [TransactionSendToken]) -> Request<NeoSendMany, Transaction>
    func sendMany(_ from: Hash160, _ txSendTokens: [TransactionSendToken]) -> Request<NeoSendMany, Transaction>
    func sendToAddress(_ tokenHash: Hash160, _ to: Hash160, _ amount: Int) -> Request<NeoSendToAddress, Transaction>
    func sendToAddress(_ txSendToken: TransactionSendToken) -> Request<NeoSendToAddress, Transaction>
    
    // MARK: TokenTracker
    
    func getNep17Balances(_ scriptHash: Hash160) -> Request<NeoGetNep17Balances, NeoGetNep17Balances.Nep17Balances>
    func getNep17Transfers(_ scriptHash: Hash160) -> Request<NeoGetNep17Transfers, NeoGetNep17Transfers.Nep17Transfers>
    func getNep17Transfers(_ scriptHash: Hash160, _ from: Date) -> Request<NeoGetNep17Transfers, NeoGetNep17Transfers.Nep17Transfers>
    func getNep17Transfers(_ scriptHash: Hash160, _ from: Date, _ to: Date) -> Request<NeoGetNep17Transfers, NeoGetNep17Transfers.Nep17Transfers>
    func getNep11Balances(_ scriptHash: Hash160) -> Request<NeoGetNep11Balances, NeoGetNep11Balances.Nep11Balances>
    func getNep11Transfers(_ scriptHash: Hash160) -> Request<NeoGetNep11Transfers, NeoGetNep11Transfers.Nep11Transfers>
    func getNep11Transfers(_ scriptHash: Hash160, _ from: Date) -> Request<NeoGetNep11Transfers, NeoGetNep11Transfers.Nep11Transfers>
    func getNep11Transfers(_ scriptHash: Hash160, _ from: Date, _ to: Date) -> Request<NeoGetNep11Transfers, NeoGetNep11Transfers.Nep11Transfers>
    func getNep11Properties(_ scriptHash: Hash160, _ tokenId: String) -> Request<NeoGetNep11Properties, [String : String]>
    
    // MARK: ApplicationLogs
    
    func getApplicationLog(_ blockIndex: Int) -> Request<NeoGetApplicationLog, NeoApplicationLog>
    
    // MARK: StateService
    
    func getStateRoot(_ blockIndex: Int) -> Request<NeoGetStateRoot, NeoGetStateRoot.StateRoot>
    func getProof(_ rootHash: Hash256, _ contractHash: Hash160, _ storageKeyHex: String) -> Request<NeoGetProof, String>
    func verifyProof(_ rootHash: Hash256, _ proofDataHex: String) -> Request<NeoVerifyProof, String>
    func getStateHeight() -> Request<NeoGetStateHeight, NeoGetStateHeight.StateHeight>
    func getState(_ rootHash: Hash256, _ contractHash: Hash160, _ keyHex: String) -> Request<NeoGetState, String>
    func findStates(_ rootHash: Hash256, _ contractHash: Hash160, _ keyPrefixHex: String, _ startKeyHex: String, _ countFindResultItems: Int) -> Request<NeoFindStates, NeoFindStates.States>
    func findStates(_ rootHash: Hash256, _ contractHash: Hash160, _ keyPrefixHex: String, _ startKeyHex: String) -> Request<NeoFindStates, NeoFindStates.States>
    func findStates(_ rootHash: Hash256, _ contractHash: Hash160, _ keyPrefixHex: String, _ countFindResultItems: Int) -> Request<NeoFindStates, NeoFindStates.States>
    func findStates(_ rootHash: Hash256, _ contractHash: Hash160, _ keyPrefixHex: String) -> Request<NeoFindStates, NeoFindStates.States>

}
