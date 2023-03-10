
import Foundation

public class ContractSigner: Signer {
    
    public let verifyParams: [ContractParameter]
    
    private init(_ contractHash: Hash160, _ scope: WitnessScope, _ verifyParams: [ContractParameter]) {
        self.verifyParams = verifyParams
        super.init(contractHash, scope)
    }
    
    public static func calledByEntry(_ contractHash: Hash160,  _ verifyParams: ContractParameter...) -> ContractSigner {
        return ContractSigner(contractHash, .calledByEntry, verifyParams)
    }
    
    public static func global(_ contractHash: Hash160,  _ verifyParams: ContractParameter...) -> ContractSigner {
        return ContractSigner(contractHash, .global, verifyParams)
    }
    
}
