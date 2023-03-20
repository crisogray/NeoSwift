
public protocol NeoExpress {
    
    func expressGetPopulatedBlocks() -> Request<NeoExpressGetPopulatedBlocks, PopulatedBlocks>
    func expressGetNep17Contracts() -> Request<NeoExpressGetNep17Contracts, [Nep17Contract]>
    func expressGetContractStorage(_ contractHash: Hash160) -> Request<NeoExpressGetContractStorage, [ContractStorageEntry]>
    func expressListContracts() -> Request<NeoExpressListContracts, [ExpressContractState]>
    func expressCreateCheckpoint(_ filename: String) -> Request<NeoExpressCreateCheckpoint, String>
    func expressListOracleRequests() -> Request<NeoExpressListOracleRequests, [OracleRequest]>
    func expressCreateOracleResponseTx(_ oracleResponse: TransactionAttribute) -> Request<NeoExpressCreateOracleResponseTx, String>
    func expressShutdown() -> Request<NeoExpressShutdown, ExpressShutdown>
    
}
