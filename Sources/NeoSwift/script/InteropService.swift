
import Foundation

public enum InteropService: String, CaseIterable {
    
    case systemCryptoCheckSig = "System.Crypto.CheckSig",
         systemCryptoCheckMultisig = "System.Crypto.CheckMultisig",
         systemContractCall = "System.Contract.Call",
         systemContractCallNative = "System.Contract.CallNative",
         systemContractGetCallFlags = "System.Contract.GetCallFlags",
         systemContractCreateStandardAccount = "System.Contract.CreateStandardAccount",
         systemContractCreateMultiSigAccount = "System.Contract.CreateMultisigAccount",
         systemContractNativeOnPersist = "System.Contract.NativeOnPersist",
         systemContractNativePostPersist = "System.Contract.NativePostPersist",
         systemIteratorNext = "System.Iterator.Next",
         systemIteratorValue = "System.Iterator.Value",
         systemRuntimePlatform = "System.Runtime.Platform",
         systemRuntimeGetTrigger = "System.Runtime.GetTrigger",
         systemRuntimeGetTime = "System.Runtime.GetTime",
         systemRuntimeGetScriptContainer = "System.Runtime.GetScriptContainer",
         systemRuntimeGetExecutingScriptHash = "System.Runtime.GetExecutingScriptHash",
         systemRuntimeGetCallingScriptHash = "System.Runtime.GetCallingScriptHash",
         systemRuntimeGetEntryScriptHash = "System.Runtime.GetEntryScriptHash",
         systemRuntimeCheckWitness = "System.Runtime.CheckWitness",
         systemRuntimeGetInvocationCounter = "System.Runtime.GetInvocationCounter",
         systemRuntimeLog = "System.Runtime.Log",
         systemRuntimeNotify = "System.Runtime.Notify",
         systemRuntimeGetNotifications = "System.Runtime.GetNotifications",
         systemRuntimeGasLeft = "System.Runtime.GasLeft",
         systemRuntimeBurnGas = "System.Runtime.BurnGas",
         systemRuntimeGetNetwork = "System.Runtime.GetNetwork",
         systemRuntimeGetRandom = "System.Runtime.GetRandom",
         systemStorageGetContext = "System.Storage.GetContext",
         systemStorageGetReadOnlyContext = "System.Storage.GetReadOnlyContext",
         systemStorageAsReadOnly = "System.Storage.AsReadOnly",
         systemStorageGet = "System.Storage.Get",
         systemStorageFind = "System.Storage.Find",
         systemStoragePut = "System.Storage.Put",
         systemStorageDelete = "System.Storage.Delete"
    
    var hash: String {
        return Bytes(rawValue.data(using: .ascii)!.sha256().prefix(4)).toHexString()
    }
    
    var price: Int {
        switch self {
        case .systemRuntimePlatform, .systemRuntimeGetTrigger, .systemRuntimeGetTime,
                .systemRuntimeGetScriptContainer, .systemRuntimeGetNetwork:
            return 1 << 3
        case .systemIteratorValue, .systemRuntimeGetExecutingScriptHash, .systemRuntimeGetCallingScriptHash,
                .systemRuntimeGetEntryScriptHash, .systemRuntimeGetInvocationCounter, .systemRuntimeGasLeft,
                .systemRuntimeBurnGas, .systemRuntimeGetRandom, .systemStorageGetContext,
                .systemStorageGetReadOnlyContext, .systemStorageAsReadOnly:
            return 1 << 4
        case .systemContractGetCallFlags, .systemRuntimeCheckWitness:
            return 1 << 10
        case .systemRuntimeGetNotifications:
            return 1 << 12
        case .systemCryptoCheckSig, .systemContractCall, .systemContractCreateStandardAccount,
                .systemIteratorNext, .systemRuntimeLog, .systemRuntimeNotify, .systemStorageGet,
                .systemStorageFind, .systemStoragePut, .systemStorageDelete:
            return 1 << 15
        default: return 0
        }
    }
    
}
