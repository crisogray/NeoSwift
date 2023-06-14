
import Foundation

public class NeoSwiftConfig {

    public static let DEFAULT_BLOCK_TIME: Int = 15_000
    public static let DEFAULT_ADDRESS_VERSION: Byte = 0x35
    public static let MAX_VALID_UNTIL_BLOCK_INCREMENT_BASE: Int = 86_400_000
    
    private static var addressVersion = DEFAULT_ADDRESS_VERSION;
    
    public private(set) var networkMagic: Int? = nil
    public private(set) var blockInterval: Int = DEFAULT_BLOCK_TIME
    public private(set) var maxValidUntilBlockIncrement: Int = MAX_VALID_UNTIL_BLOCK_INCREMENT_BASE / DEFAULT_BLOCK_TIME
    public private(set) var pollingInterval: Int = DEFAULT_BLOCK_TIME
    public private(set) var scheduledExecutorService: DispatchQueue
    public private(set) var allowsTransmissionOnFault: Bool = false
    
    public static let MAINNET_NNS_CONTRACT_HASH = try! Hash160("0x50ac1c37690cc2cfc594472833cf57505d5f46de")
    public static let REQUEST_COUNTER = Counter()
    
    public private(set) var nnsResolver = MAINNET_NNS_CONTRACT_HASH
        
    public init(networkMagic: Int? = nil,
                blockInterval: Int = DEFAULT_BLOCK_TIME,
                maxValidUntilBlockIncrement: Int = MAX_VALID_UNTIL_BLOCK_INCREMENT_BASE / DEFAULT_BLOCK_TIME,
                pollingInterval: Int = DEFAULT_BLOCK_TIME,
                scheduledExecutorService: DispatchQueue = .global(qos: .background),
                allowsTransmissionOnFault: Bool = false,
                nnsResolver: Hash160 = MAINNET_NNS_CONTRACT_HASH
    ) {
        self.networkMagic = networkMagic
        self.blockInterval = blockInterval
        self.maxValidUntilBlockIncrement = maxValidUntilBlockIncrement
        self.pollingInterval = pollingInterval
        self.scheduledExecutorService = scheduledExecutorService
        self.allowsTransmissionOnFault = allowsTransmissionOnFault
        self.nnsResolver = nnsResolver
    }
    
    public func setPollingInterval(_ pollingInterval: Int) -> NeoSwiftConfig {
        self.pollingInterval = pollingInterval
        return self
    }
    
    public func setScheduledExecutorService(_ executorService: DispatchQueue) -> NeoSwiftConfig {
        self.scheduledExecutorService = executorService
        return self
    }
    
    public static func setAddressVersion(_ addressVersion: Byte) {
        NeoSwiftConfig.addressVersion = addressVersion
    }
    
    public func setNetworkMagic(_ magic: Int) throws -> NeoSwiftConfig {
        guard magic <= 0xFFFFFFFF && magic >= 0 else {
            throw NeoSwiftError.illegalArgument("The network magic number must fit into a 32-bit unsigned integer, i.e., it must be positive and not greater than 0xFFFFFFFF.")
        }
        self.networkMagic = magic
        return self
    }
    
    public func setBlockInterval(_ blockInterval: Int) -> NeoSwiftConfig {
        self.blockInterval = blockInterval
        return self
    }
    
    public func setMaxValidUntilBlockIncrement(_ maxValidUntilBlockIncrement: Int) -> NeoSwiftConfig {
        self.maxValidUntilBlockIncrement = maxValidUntilBlockIncrement
        return self
    }
    
    public func setNNSResolver(_ nnsResolver: Hash160) -> NeoSwiftConfig {
        self.nnsResolver = nnsResolver
        return self
    }
    
    
    public func allowTransmissionOnFault() -> NeoSwiftConfig {
        self.allowsTransmissionOnFault = true
        return self
    }
    
    public func preventTransmissionOnFault() -> NeoSwiftConfig {
        self.allowsTransmissionOnFault = false
        return self
    }
    
}

public class Counter {

    private var queue = DispatchQueue(label: "Atomic")
    private (set) var value: Int = 1

    func getAndIncrement() -> Int {
        let v = value
        queue.sync { value += 1 }
        return v
    }
    
    func set(_ i: Int) {
        queue.sync { value = i }
    }
    
    func reset() {
        queue.sync { value = 1 }
    }
    
}

