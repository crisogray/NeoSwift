public struct NNSName {
    
    public let name: String
    
    var bytes: Bytes {
        return name.bytes
    }
    
    var isSecondLevelDomain: Bool {
        return NNSName.isValidNNSName(name, false)
    }
    
    public init(name: String) throws {
        guard NNSName.isValidNNSName(name, true) else {
            throw "'\(name)' is not a valid NNS name."
        }
        self.name = name
    }
    
    public static func isValidNNSName(_ name: String, _ allowMultipleFragments: Bool) -> Bool {
        guard name.count >= 3 && name.count <= 255 else { return false }
        let fragments = name.components(separatedBy: ".")
        guard fragments.count >= 2 && fragments.count <= 8 else { return false }
        if fragments.count > 2 && !allowMultipleFragments { return false }
        if fragments.contains(where: { !checkFragment($0, $0 == fragments.last) }) { return false }
        return true
    }
    
    public static func checkFragment(_ fragment: String, _ isRoot: Bool) -> Bool {
        let maxLength = isRoot ? 16 : 63
        guard !fragment.isEmpty && fragment.count <= maxLength else { return false }
        let c = fragment.first!
        if isRoot && !c.isLetter { return false }
        else if !isRoot && !(c.isLetter || c.isNumber) { return false }
        if fragment.count == 1 { return true }
        if fragment.dropLast(1).contains(where: { !($0.isLetter || $0.isNumber || $0 == "-") }) { return false }
        return fragment.last!.isLetter || fragment.last!.isNumber
    }
    
    public struct NNSRoot {
        
        public let root: String
        
        public init(root: String) throws {
            guard NNSRoot.isValidNNSRoot(root) else {
                throw "'\(root)' is not a valid NNS root."
            }
            self.root = root
        }
        
        public static func isValidNNSRoot(_ root: String) -> Bool {
            return NNSName.checkFragment(root, true)
        }
        
    }
    
    
}
