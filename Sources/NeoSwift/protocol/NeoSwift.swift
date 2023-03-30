
public protocol NeoSwift: Neo, NeoSwiftRx {
    
    var config: NeoSwiftConfig { get set }
    func shutdown()
    
}

extension NeoSwift {
    
    public static func build(_ config: NeoSwiftConfig, _ neoSwiftService: NeoSwiftService) -> NeoSwift {
        return JsonRpc2_0NeoSwift(config: config, neoSwiftService: neoSwiftService)
    }
    
    public mutating func allowTransmissionOnFault() {
        _ = config.allowTransmissionOnFault()
    }
    
    public mutating func preventTransmissionOnFault() {
        _ = config.preventTransmissionOnFault()
    }
    
    public mutating func setNNSResolver(_ nnsResolver: Hash160) {
        _ = config.setNNSResolver(nnsResolver)
    }
    
    public mutating func getNetworkMagicNumberBytes() async throws -> Bytes {
        if config.networkMagic == nil {
            guard let magic = try await getVersion().send().getResult().protocol?.network else {
                throw "Unable to read Network Magic Number from Version"
            }
            _ = try config.setNetworkMagic(magic)
        }
        let magicInt = config.networkMagic! & 0xFFFFFFFF
        return Bytes(magicInt.bytes.prefix(4))
    }
    
    public mutating func getNetworkMagicNumber() async throws -> Int? {
        if config.networkMagic == nil {
            guard let magic = try await getVersion().send().getResult().protocol?.network else {
                throw "Unable to read Network Magic Number from Version"
            }
            _ = try config.setNetworkMagic(magic)
        }
        return config.networkMagic!
    }
    
    public var nnsResolver: Hash160 { return config.nnsResolver}
    public var blockInterval: Int { return config.blockInterval }
    public var pollingInterval: Int { return config.pollingInterval }
    public var maxValidUntilBlockIncrement: Int { return config.maxValidUntilBlockIncrement }
    
}
