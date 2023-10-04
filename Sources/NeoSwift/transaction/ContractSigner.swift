
import Foundation

/// This signer represents a smart contract instead of a normal account.
/// You can use this in transactions that require the verification of a smart contract, e.g., if you want to withdraw tokens from a contract you own.
///
/// Using such a signer will make Neo call the `verify()` method of the corresponding contract.
///
/// Make sure to provide the necessary contract parameters if the contract's `verify()` method expects any.
public class ContractSigner: Signer {
    
    /// The parameters that are consumed by this contract signer's the `verify()` method.
    public let verifyParams: [ContractParameter]
    
    private init(_ contractHash: Hash160, _ scope: WitnessScope, _ verifyParams: [ContractParameter]) {
        self.verifyParams = verifyParams
        super.init(contractHash, scope)
    }
    
    /// Creates a signer for the given contract with a scope ``WitnessScope/calledByEntry`` that only allows the entry point contract to use this signer's witness.
    /// - Parameters:
    ///   - contractHash: The script hash of the contract
    ///   - verifyParams: The parameters to pass to the `verify()` method of the contract
    /// - Returns: The signer
    public static func calledByEntry(_ contractHash: Hash160,  _ verifyParams: ContractParameter...) -> ContractSigner {
        return ContractSigner(contractHash, .calledByEntry, verifyParams)
    }
    
    /// Creates a signer for the given account with global witness scope ``WitnessScope/global``.
    /// - Parameters:
    ///   - contractHash: The script hash of the contract
    ///   - verifyParams: The parameters to pass to the `verify()` method of the contract
    /// - Returns: The signer
    public static func global(_ contractHash: Hash160,  _ verifyParams: ContractParameter...) -> ContractSigner {
        return ContractSigner(contractHash, .global, verifyParams)
    }
    
}
