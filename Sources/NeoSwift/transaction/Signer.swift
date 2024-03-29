
import Foundation

/// A signer of a transaction. It defines a scope in which the signer's signature is valid.
public class Signer {
    
    /// The script hash of the signer account.
    public let signerHash: Hash160
    
    /// The scopes in which the signer's signatures can be used. Multiple scopes can be combined.
    public private(set) var scopes: [WitnessScope]
    
    /// The contract hashes of the contracts that are allowed to use the witness.
    public private(set) var allowedContracts: [Hash160]
    
    /// The group hashes of contracts that are allowed to use the witness.
    public private(set) var allowedGroups: [ECPublicKey]
    
    /// The rules that the witness must meet.
    public private(set) var rules: [WitnessRule]
    
    internal init(_ signerHash: Hash160, _ scope: WitnessScope) {
        self.signerHash = signerHash
        scopes = [scope]
        allowedContracts = []
        allowedGroups = []
        rules = []
    }
    
    private init(_ signerHash: Hash160 ,_ scopes: [WitnessScope], _ allowedContracts: [Hash160], _ allowedGroups: [ECPublicKey], _ rules: [WitnessRule]) {
        self.signerHash = signerHash
        self.scopes = scopes
        self.allowedContracts = allowedContracts
        self.allowedGroups = allowedGroups
        self.rules = rules
    }
    
    /// Adds the given contracts to this signer's scope. These contracts are allowed to use the signers witness.
    /// - Parameter allowedContracts: The hashes of the allowed contracts
    /// - Returns: The signer (self)
    public func setAllowedContracts(_ allowedContracts: [Hash160]) throws -> Signer {
        if allowedContracts.isEmpty { return self }
        else if scopes.contains(.global) { throw TransactionError.signerConfiguration("Trying to set allowed contracts on a Signer with global scope.") }
        else if self.allowedContracts.count + allowedContracts.count > NeoConstants.MAX_SIGNER_SUBITEMS {
            throw TransactionError.signerConfiguration("Trying to set more than \(NeoConstants.MAX_SIGNER_SUBITEMS) allowed contracts on a signer.")
        }
        scopes = scopes.filter { $0 != .none }
        if !scopes.contains(.customContracts) { scopes.append(.customContracts) }
        self.allowedContracts.append(contentsOf: allowedContracts)
        return self
    }
    
    /// Adds the given contract groups to this signer's scope. The contracts in these groups are allowed to use the signers witness.
    /// - Parameter allowedContracts: The public keys of the allowed contracts
    /// - Returns: The signer (self)
    public func setAllowedGroups(_ allowedGroups: [ECPublicKey]) throws -> Signer {
        if allowedGroups.isEmpty { return self }
        else if scopes.contains(.global) { throw TransactionError.signerConfiguration("Trying to set allowed contract groups on a Signer with global scope.") }
        else if self.allowedGroups.count + allowedGroups.count > NeoConstants.MAX_SIGNER_SUBITEMS {
            throw TransactionError.signerConfiguration("Trying to set more than \(NeoConstants.MAX_SIGNER_SUBITEMS) allowed contract groups on a signer.")
        }
        scopes = scopes.filter { $0 != .none }
        if !scopes.contains(.customGroups) { scopes.append(.customGroups) }
        self.allowedGroups.append(contentsOf: allowedGroups)
        return self
    }
    
    /// Adds the given witness rules to this signer.
    /// - Parameter rules: The rules
    /// - Returns: The signer (self)
    public func setRules(_ rules: [WitnessRule]) throws -> Signer {
        if rules.isEmpty { return self }
        else if scopes.contains(.global) { throw TransactionError.signerConfiguration("Trying to set witness rules on a Signer with global scope.") }
        else if self.rules.count + rules.count > NeoConstants.MAX_SIGNER_SUBITEMS {
            throw TransactionError.signerConfiguration("Trying to set more than \(NeoConstants.MAX_SIGNER_SUBITEMS) allowed witness rules on a signer.")
        }
        try rules.forEach { r in try checkDepth(r.condition, WitnessCondition.MAX_NESTING_DEPTH) }
        scopes = scopes.filter { $0 != .none }
        if !scopes.contains(.witnessRules) { scopes.append(.witnessRules) }
        self.rules.append(contentsOf: rules)
        return self
    }
    
    private func checkDepth(_ condition: WitnessCondition, _ depth: Int) throws {
        guard depth >= 0 else {
            throw TransactionError.signerConfiguration("A maximum nesting depth of \(WitnessCondition.MAX_NESTING_DEPTH) is allowed for witness conditions.")
        }
        switch condition {
        case .and(let expressions), .or(let expressions): try expressions.forEach { try checkDepth($0, depth - 1) }
        default: break
        }
    }
    
}

extension Signer: Hashable {
    
    public static func == (lhs: Signer, rhs: Signer) -> Bool {
        return lhs.signerHash == rhs.signerHash
        && lhs.scopes == rhs.scopes
        && lhs.allowedContracts == rhs.allowedContracts
        && lhs.allowedGroups == rhs.allowedGroups
        && lhs.rules == rhs.rules
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(signerHash)
        hasher.combine(scopes)
        hasher.combine(allowedContracts)
        hasher.combine(allowedGroups)
        hasher.combine(rules)
    }
    
}

extension Signer: NeoSerializable {

    public var size: Int {
        var size = NeoConstants.HASH160_SIZE + 1
        if scopes.contains(.customContracts) { size += allowedContracts.varSize }
        if scopes.contains(.customGroups) { size += allowedGroups.varSize }
        if scopes.contains(.witnessRules) { size += rules.varSize }
        return size
    }
    
    public func serialize(_ writer: BinaryWriter) {
        writer.writeSerializableFixed(signerHash)
        writer.writeByte(WitnessScope.combineScopes(scopes))
        if scopes.contains(.customContracts) { writer.writeSerializableVariable(allowedContracts) }
        if scopes.contains(.customGroups) { writer.writeSerializableVariable(allowedGroups) }
        if scopes.contains(.witnessRules) { writer.writeSerializableVariable(rules) }
    }
    
    public static func deserialize(_ reader: BinaryReader) throws -> Self {
        let signerHash: Hash160 = try reader.readSerializable()
        let scopes = WitnessScope.extractCombinedScopes(reader.readByte())
        var allowedContracts: [Hash160] = []
        var allowedGroups: [ECPublicKey] = []
        var rules: [WitnessRule] = []
        let allowedScopes: [WitnessScope] = [.customContracts, .customGroups, .witnessRules]
        for scope in allowedScopes where scopes.contains(scope) {
            var count = 0, errorLabel = ""
            switch scope {
            case .customContracts:
                allowedContracts = reader.readSerializableList()
                count = allowedContracts.count
                errorLabel = "allowed contracts"
            case .customGroups:
                allowedGroups = reader.readSerializableList()
                count = allowedGroups.count
                errorLabel = "allowed contract groups"
            case .witnessRules:
                rules = reader.readSerializableList()
                count = rules.count
                errorLabel = "rules"
            default: break
            }
            guard count <= NeoConstants.MAX_SIGNER_SUBITEMS else {
                throw NeoSwiftError.deserialization("A signer's scope can only contain \(NeoConstants.MAX_SIGNER_SUBITEMS) \(errorLabel). The input data contained \(count).")
            }
        }
        return Signer(signerHash, scopes, allowedContracts, allowedGroups, rules) as! Self
    }
    
}
