
import Foundation

public class NeoSwiftConfig {

    public static let DEFAULT_BLOCK_TIME: Int = 15_000
    public static let DEFAULT_ADDRESS_VERSION: Byte = 0x35
    public static let MAX_VALID_UNTIL_BLOCK_INCREMENT_BASE: Int = 86_400_000
    public static let MAINNET_NNS_CONTRACT_HASH = try! Hash160("0x50ac1c37690cc2cfc594472833cf57505d5f46de")
    public static let REQUEST_COUNTER = Counter()
    
    /// The configured address version.
    ///
    /// The address version is used in the creation of Neo addresses from script hashes. It defaults to ``DEFAULT_ADDRESS_VERSION``
    ///
    /// This property is static because it is necessary in code that can be used independent of a connected Neo node.
    private static var addressVersion = DEFAULT_ADDRESS_VERSION
    
    /// The configured network magic number.
    ///
    /// The magic number is an ingredient, e.g., when generating the hash of a transaction.
    ///
    /// The default value is null. Only once ``NeoSwift/NeoSwift/getNetworkMagicNumber()`` or ``NeoSwift/NeoSwift/getNetworkMagicNumberBytes()``  is called for the first time the value is set.
    /// This is because the magic number is fetched directly from the neo-node.
    public private(set) var networkMagic: Int? = nil
    
    /// The block interval in milliseconds.
    public private(set) var blockInterval: Int = DEFAULT_BLOCK_TIME
    
    /// The maximum time in milliseconds that can pass from the construction of a transaction until it gets included in a block. A transaction becomes invalid after this time increment is surpassed.
    public private(set) var maxValidUntilBlockIncrement: Int = MAX_VALID_UNTIL_BLOCK_INCREMENT_BASE / DEFAULT_BLOCK_TIME
    
    /// The interval in milliseconds in which ``NeoSwift/NeoSwift`` polls the neo-node for new block information when observing the blockchain.
    public private(set) var pollingInterval: Int = DEFAULT_BLOCK_TIME
    
    /// The dispatch queue used for polling new blocks from the Neo node.
    public private(set) var scheduledDispatchQueue: DispatchQueue
    
    /// `true` if transmission is allowed when the provided script leads to a ``NeoVMStateType/fault``. Otherwise `false`.
    public private(set) var allowsTransmissionOnFault: Bool = false
    
    /// The NeoNameService resolver script hash
    public private(set) var nnsResolver = MAINNET_NNS_CONTRACT_HASH
            
    /// Constructs a configuration instance
    public init(
        networkMagic: Int? = nil,
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
        self.scheduledDispatchQueue = scheduledExecutorService
        self.allowsTransmissionOnFault = allowsTransmissionOnFault
        self.nnsResolver = nnsResolver
    }
    
    /// Sets the interval in milliseconds in which ``NeoSwift/NeoSwift`` should poll the neo-node for new block information when observing the blockchain.
    /// - Parameter pollingInterval: The polling interval in milliseconds
    /// - Returns: The config (self)
    public func setPollingInterval(_ pollingInterval: Int) -> NeoSwiftConfig {
        self.pollingInterval = pollingInterval
        return self
    }
    
    /// Sets the dispatch queue used for polling new blocks from the Neo node.
    /// - Parameter dispatchQueue: The dispatch queue
    /// - Returns: The config (self)
    public func setScheduledDispatchQueue(_ dispatchQueue: DispatchQueue) -> NeoSwiftConfig {
        self.scheduledDispatchQueue = dispatchQueue
        return self
    }
    
    /// Sets the address version.
    ///
    /// This should match the configuration of the neo-node you connect to.
    /// - Parameter addressVersion: The address version
    public static func setAddressVersion(_ addressVersion: Byte) {
        NeoSwiftConfig.addressVersion = addressVersion
    }
    
    /// Sets the network magic number.
    ///
    /// The magic number is an ingredient, e.g., when generating the hash of a transaction. This should match the configuration of the neo-node you connect to.
    /// - Parameter magic: The network's magic number
    /// - Returns: The config (self)
    public func setNetworkMagic(_ magic: Int) throws -> NeoSwiftConfig {
        guard magic <= 0xFFFFFFFF && magic >= 0 else {
            throw NeoSwiftError.illegalArgument("The network magic number must fit into a 32-bit unsigned integer, i.e., it must be positive and not greater than 0xFFFFFFFF.")
        }
        self.networkMagic = magic
        return self
    }
    
    /// Sets the interval in milliseconds in which blocks are produced.
    ///
    /// This should match the block time of the blockchain network you connect to.
    /// - Parameter blockInterval: The block interval in milliseconds.
    /// - Returns: The config (self)
    public func setBlockInterval(_ blockInterval: Int) -> NeoSwiftConfig {
        self.blockInterval = blockInterval
        return self
    }
    
    /// Sets the maximum time in milliseconds that can pass from the construction of a transaction until it gets included in a block. A transaction becomes invalid after this time increment is surpassed.
    ///
    /// This should match the configuration of the neo-node you connect to.
    /// - Parameter maxValidUntilBlockIncrement: The maximum valid until block time increment
    /// - Returns: The config (self)
    public func setMaxValidUntilBlockIncrement(_ maxValidUntilBlockIncrement: Int) -> NeoSwiftConfig {
        self.maxValidUntilBlockIncrement = maxValidUntilBlockIncrement
        return self
    }
    
    /// Sets the NeoNameService resolver script hash.
    /// - Parameter nnsResolver: The NeoNameService script hash
    /// - Returns: The config (self)
    public func setNNSResolver(_ nnsResolver: Hash160) -> NeoSwiftConfig {
        self.nnsResolver = nnsResolver
        return self
    }
    
    /// Allow the transmission of scripts that lead to a ``NeoVMStateType/fault``
    /// - Returns: The config (self)
    public func allowTransmissionOnFault() -> NeoSwiftConfig {
        self.allowsTransmissionOnFault = true
        return self
    }
    
    /// Prevent the transmission of scripts that lead to a ``NeoVMStateType/fault``
    /// - Returns: The config (self)
    public func preventTransmissionOnFault() -> NeoSwiftConfig {
        self.allowsTransmissionOnFault = false
        return self
    }
    
}

public class Counter {

    private var queue = DispatchQueue(label: "Atomic")
    private(set) var value: Int = 1

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

