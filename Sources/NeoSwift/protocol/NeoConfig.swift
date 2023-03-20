
import Foundation

public enum NeoConfig {
    
    public static let DEFAULT_ADDRESS_VERSION: Byte = 0x35
    
    public static let requestCounter = Counter()
    
}

public class Counter {

    private var queue = DispatchQueue(label: "Atomic")
    private (set) var value: Int = 0

    func getAndIncrement() -> Int {
        let v = value
        queue.sync {
            value += 1
        }
        return v
    }
}

