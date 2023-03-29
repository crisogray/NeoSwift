
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
    
    public mutating func getNetworkMagicNumberBytes() async -> Bytes? {
        if config.networkMagic == nil {
            if let magic = try? await getVersion().send().version?.protocol?.network {
                do {
                    _ = try config.setNetworkMagic(magic)
                } catch { return nil }
            } else { return nil }
        }
        let magicInt = config.networkMagic! & 0xFFFFFFFF
        return Bytes(magicInt.bytes.prefix(4))
    }
    
    public mutating func getNetworkMagicNumber() async -> Int? {
        if config.networkMagic == nil {
            if let magic = try? await getVersion().send().version?.protocol?.network {
                do {
                    _ = try config.setNetworkMagic(magic)
                } catch { return nil }
            } else { return nil }
        }
        return config.networkMagic!
    }
    
    public var nnsResolver: Hash160 { return config.nnsResolver}
    public var blockInterval: Int { return config.blockInterval }
    public var pollingInterval: Int { return config.pollingInterval }
    public var maxValidUntilBlockIncrement: Int { return config.maxValidUntilBlockIncrement }
    
}
