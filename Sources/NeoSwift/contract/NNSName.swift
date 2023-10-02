
/// Represents a NeoNameService domain name
public struct NNSName {
    
    /// The name
    public let name: String
    
    /// The UTF-8 encoded name.
    var bytes: Bytes {
        return name.bytes
    }
    
    /// If the name is a second-level domain or not
    var isSecondLevelDomain: Bool {
        return NNSName.isValidNNSName(name, false)
    }
    
    /// Creates a NNS name and checks its validity.
    /// - Parameter name: The domain name
    public init(_ name: String) throws {
        guard NNSName.isValidNNSName(name, true) else {
            throw ContractError.invalidNeoName(name)
        }
        self.name = name
    }
    
    internal static func isValidNNSName(_ name: String, _ allowMultipleFragments: Bool) -> Bool {
        guard name.count >= 3 && name.count <= 255 else { return false }
        let fragments = name.components(separatedBy: ".")
        guard fragments.count >= 2 && fragments.count <= 8 else { return false }
        if fragments.count > 2 && !allowMultipleFragments { return false }
        if fragments.contains(where: { !checkFragment($0, $0 == fragments.last) }) { return false }
        return true
    }
    
    private static func checkFragment(_ fragment: String, _ isRoot: Bool) -> Bool {
        let maxLength = isRoot ? 16 : 63
        guard !fragment.isEmpty && fragment.count <= maxLength else { return false }
        let c = fragment.first!
        if isRoot && !c.isLetter { return false }
        else if !isRoot && !(c.isLetter || c.isNumber) { return false }
        if fragment.count == 1 { return true }
        if fragment.dropLast(1).contains(where: { !($0.isLetter || $0.isNumber || $0 == "-") }) { return false }
        return fragment.last!.isLetter || fragment.last!.isNumber
    }
    
    /// Represents a NeoNameService root
    public struct NNSRoot {
        
        /// The root
        public let root: String
        
        /// Creates a NNS root and checks its validity.
        /// - Parameter root: The root
        public init(_ root: String) throws {
            guard NNSRoot.isValidNNSRoot(root) else {
                throw ContractError.invalidNeoNameServiceRoot(root)
            }
            self.root = root
        }
        
        private static func isValidNNSRoot(_ root: String) -> Bool {
            return NNSName.checkFragment(root, true)
        }
        
    }
    
}
