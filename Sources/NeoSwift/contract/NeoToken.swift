
public class NeoToken: FungibleToken {
    
    public static let NAME = "NeoToken"
    public static let SCRIPT_HASH = try! calcNativeContractHash(NAME)
    public static let DECIMALS = 0
    public static let SYMBOL = "NEO"
    public static let TOTAL_SUPPLY = 100_000_000
    
    private static let UNCLAIMED_GAS = "unclaimedGas"
    private static let REGISTER_CANDIDATE = "registerCandidate"
    private static let UNREGISTER_CANDIDATE = "unregisterCandidate"
    private static let VOTE = "vote"
    private static let GET_CANDIDATES = "getCandidates"
    private static let GET_ALL_CANDIDATES = "getAllCandidates"
    private static let GET_CANDIDATE_VOTES = "getCandidateVote"
    private static let GET_COMMITTEE = "getCommittee"
    private static let GET_NEXT_BLOCK_VALIDATORS = "getNextBlockValidators"
    private static let SET_GAS_PER_BLOCK = "setGasPerBlock"
    private static let GET_GAS_PER_BLOCK = "getGasPerBlock"
    private static let SET_REGISTER_PRICE = "setRegisterPrice"
    private static let GET_REGISTER_PRICE = "getRegisterPrice"
    private static let GET_ACCOUNT_STATE = "getAccountState"
    
    public init(_ neoSwift: NeoSwift) {
        super.init(scriptHash: NeoToken.SCRIPT_HASH, neoSwift: neoSwift)
    }
    
    public override func getName() async throws -> String? {
        return NeoToken.NAME
    }
    
    public override func getSymbol() async throws -> String {
        return NeoToken.SYMBOL
    }
    
    public override func getDecimals() async throws -> Int {
        return NeoToken.DECIMALS
    }
    
    public override func getTotalSupply() async throws -> Int {
        return NeoToken.TOTAL_SUPPLY
    }
        
    // MARK: Unclaimed Gas
    
    public func unclaimedGas(_ account: Account, _ blockHeight: Int) async throws -> Int {
        return try await unclaimedGas(account.getScriptHash(), blockHeight)
    }
    
    public func unclaimedGas(_ scriptHash: Hash160, _ blockHeight: Int) async throws -> Int {
        return try await callFunctionReturningInt(NeoToken.UNCLAIMED_GAS, [.hash160(scriptHash), .integer(blockHeight)])
    }
    
    // MARK: Candidate Registration
    
    public func registerCandidate(_ candidateKey: ECPublicKey) throws -> TransactionBuilder {
        return try invokeFunction(NeoToken.REGISTER_CANDIDATE, [.publicKey(candidateKey.getEncoded(compressed: true))])
    }
    
    public func unregisterCandidate(_ candidateKey: ECPublicKey) throws -> TransactionBuilder {
        return try invokeFunction(NeoToken.UNREGISTER_CANDIDATE, [.publicKey(candidateKey.getEncoded(compressed: true))])
    }
    
    // MARK: Committee and Candidates Information
    
    public func getCommittee() async throws -> [ECPublicKey] {
        return try await callFunctionReturningListOfPublicKeys(NeoToken.GET_COMMITTEE)
    }
    
    public func getCandidates() async throws -> [Candidate] {
        let arrayItem = try await callInvokeFunction(NeoToken.GET_CANDIDATES).getResult().getFirstStackItem()
        guard case .array = arrayItem else {
            throw ContractError.unexpectedReturnType(arrayItem.jsonValue, [StackItem.ARRAY_VALUE])
        }
        return try arrayItem.list!.map(candidateMapper)
    }
    
    public func isCandidate(_ publicKey: ECPublicKey) async throws -> Bool {
        return try await getCandidates().contains { $0.publicKey == publicKey }
    }
    
    public func getAllCandidatesIterator() async throws -> Iterator<Candidate> {
        return try await callFunctionReturningIterator(NeoToken.GET_ALL_CANDIDATES, mapper: candidateMapper)
    }
    
    private func candidateMapper(_ stackItem: StackItem) throws -> Candidate {
        let list = try stackItem.getList()
        return try .init(publicKey: .init(list[0].getByteArray()), votes: list[1].getInteger())
    }
    
    public func getCandidateVotes(_ pubKey: ECPublicKey) async throws -> Int {
        return try await callFunctionReturningInt(NeoToken.GET_CANDIDATE_VOTES, [.publicKey(pubKey)])
    }
    
    public func getNextBlockValidators() async throws -> [ECPublicKey] {
        return try await callFunctionReturningListOfPublicKeys(NeoToken.GET_NEXT_BLOCK_VALIDATORS)
    }
    
    private func callFunctionReturningListOfPublicKeys(_ function: String) async throws -> [ECPublicKey] {
        let arrayItem = try await callInvokeFunction(function).getResult().getFirstStackItem()
        guard case .array = arrayItem else {
            throw ContractError.unexpectedReturnType(arrayItem.jsonValue, [StackItem.ARRAY_VALUE])
        }
        return try arrayItem.getList().map(extractPublicKey)
    }
    
    private func extractPublicKey(_ keyItem: StackItem) throws -> ECPublicKey {
        guard case .byteString = keyItem else {
            throw ContractError.unexpectedReturnType(keyItem.jsonValue, [StackItem.BYTE_STRING_VALUE])
        }
        do {
            return try .init(keyItem.getByteArray())
        } catch {
            throw ContractError.unexpectedReturnType("Byte array return type did not contain public key in expected format.")
        }
    }
    
    // MARK: Voting
    
    public func vote(_ voter: Account, _ candidate: ECPublicKey?) async throws -> TransactionBuilder {
        return try await vote(voter.getScriptHash(), candidate)
    }
    
    public func vote(_ voter: Hash160, _ candidate: ECPublicKey?) async throws -> TransactionBuilder {
        guard let candidate = candidate else {
            return try invokeFunction(NeoToken.VOTE, [.hash160(voter), .any(nil)])
        }
        return try invokeFunction(NeoToken.VOTE, [.hash160(voter), .publicKey(candidate.getEncoded(compressed: true))])
    }
    
    public func cancelVote(_ voter: Account) async throws -> TransactionBuilder {
        return try await cancelVote(voter.getScriptHash())
    }
    
    public func cancelVote(_ voter: Hash160) async throws -> TransactionBuilder {
        return try await vote(voter, nil)
    }
    
    public func buildVoteScript(_ voter: Hash160, _ candidate: ECPublicKey?) throws -> Bytes {
        guard let candidate = candidate else {
            return try buildInvokeFunctionScript(NeoToken.VOTE, [.hash160(voter), .any(nil)])
        }
        return try buildInvokeFunctionScript(NeoToken.VOTE, [.hash160(voter), .publicKey(candidate.getEncoded(compressed: true))])
    }
    
    // MARK: Network Settings
    
    public func getGasPerBlock() async throws -> Int {
        return try await callFunctionReturningInt(NeoToken.GET_GAS_PER_BLOCK)
    }
    
    public func setGasPerBlock(_ gasPerBlock: Int) throws -> TransactionBuilder {
        return try invokeFunction(NeoToken.SET_GAS_PER_BLOCK, [.integer(gasPerBlock)])
    }
    
    public func getRegisterPrice() async throws -> Int {
        return try await callFunctionReturningInt(NeoToken.GET_REGISTER_PRICE)
    }
    
    public func setRegisterPrice(_ registerPrice: Int) throws -> TransactionBuilder {
        return try invokeFunction(NeoToken.SET_REGISTER_PRICE, [.integer(registerPrice)])
    }
    
    public func getAccountState(_ account: Hash160) async throws -> NeoAccountState {
        guard let result = try await callInvokeFunction(NeoToken.GET_ACCOUNT_STATE, [.hash160(account)])
            .getResult().stack.first else {
            throw NeoSwiftError.illegalState("Account State stack was empty.")
        }
        if case .any = result { return .withNoBalance() }
        guard let state = result.list, state.count >= 3,
              let balance = state[0].integer,
              let updateHeight = state[1].integer else {
            throw NeoSwiftError.illegalState("Account State stack was malformed.")
        }
        let publicKeyItem = state[2]
        if case .any = publicKeyItem { return .withNoVote(balance, updateHeight) }
        return try .init(balance: balance, balanceHeight: updateHeight, publicKeyString: .init(publicKeyItem.getHexString()))
    }
    
    public struct Candidate: Hashable {
        
        public let publicKey: ECPublicKey
        public let votes: Int
        
    }
    
}
