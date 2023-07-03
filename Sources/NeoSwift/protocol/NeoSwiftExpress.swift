
public class NeoSwiftExpress: NeoSwift, NeoExpress {
    
    public func expressGetPopulatedBlocks() -> Request<NeoExpressGetPopulatedBlocks, PopulatedBlocks> {
        return .init(method: "expressgetpopulatedblocks", params: [], neoSwiftService: neoSwiftService)
    }
    
    public func expressGetNep17Contracts() -> Request<NeoExpressGetNep17Contracts, [Nep17Contract]> {
        return .init(method: "expressgetnep17contracts", params: [], neoSwiftService: neoSwiftService)
    }
    
    public func expressGetContractStorage(_ contractHash: Hash160) -> Request<NeoExpressGetContractStorage, [ContractStorageEntry]> {
        return .init(method: "expressgetcontractstorage", params: [contractHash.string], neoSwiftService: neoSwiftService)
    }
    
    public func expressListContracts() -> Request<NeoExpressListContracts, [ExpressContractState]> {
        return .init(method: "expresslistcontracts", params: [], neoSwiftService: neoSwiftService)
    }
    
    public func expressCreateCheckpoint(_ filename: String) -> Request<NeoExpressCreateCheckpoint, String> {
        return .init(method: "expresscreatecheckpoint", params: [filename], neoSwiftService: neoSwiftService)
    }
    
    public func expressListOracleRequests() -> Request<NeoExpressListOracleRequests, [OracleRequest]> {
        return .init(method: "expresslistoraclerequests", params: [], neoSwiftService: neoSwiftService)
    }
    
    public func expressCreateOracleResponseTx(_ oracleResponse: TransactionAttribute) -> Request<NeoExpressCreateOracleResponseTx, String> {
        return .init(method: "expresscreateoracleresponsetx", params: [oracleResponse], neoSwiftService: neoSwiftService)
    }
    
    public func expressShutdown() -> Request<NeoExpressShutdown, ExpressShutdown> {
        return .init(method: "expressshutdown", params: [], neoSwiftService: neoSwiftService)
    }
    
    
}
