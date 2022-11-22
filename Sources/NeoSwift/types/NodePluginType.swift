
import Foundation


public enum NodePluginType: String {

    case applicationLogs = "ApplicationLogs",
        coreMetrics = "CoreMetrics",
        importBlocks = "ImportBlocks",
        levelDbStore = "LevelDBStore",
        rocksDbStore = "RocksDBStore",
        rpcNep17Tracker = "RpcNep17Tracker",
        rpcSecurity = "RpcSecurity",
        rpcServerPlugin = "RpcServerPlugin",
        rpcSystemAssetTracker = "RpcSystemAssetTrackerPlugin",
        simplePolicy = "SimplePolicyPlugin",
        statesDumper = "StatesDumper",
        systemLog = "SystemLog"

}
