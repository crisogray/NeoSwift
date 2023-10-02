
/// Represents the NeoToken native contract and provides methods to invoke its functions.
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
    
    /// Constructs a new `NeoToken` that uses the given ``NeoSwift/NeoSwift`` instance for invocations.
    /// - Parameter neoSwift: The ``NeoSwift/NeoSwift`` instance to use for invocations
    public init(_ neoSwift: NeoSwift) {
        super.init(scriptHash: NeoToken.SCRIPT_HASH, neoSwift: neoSwift)
    }
    
    /// Returns the name of the NEO token.
    ///
    /// Doesn't require a call to the Neo node.
    /// - Returns: The name
    public override func getName() async throws -> String? {
        return NeoToken.NAME
    }
    
    /// Returns the symbol of the NEO token.
    ///
    /// Doesn't require a call to the Neo node.
    /// - Returns: The symbol
    public override func getSymbol() async throws -> String {
        return NeoToken.SYMBOL
    }
    
    /// Returns the total supply of the NEO token.
    ///
    /// Doesn't require a call to the Neo node.
    /// - Returns: The total supply
    public override func getTotalSupply() async throws -> Int {
        return NeoToken.TOTAL_SUPPLY
    }
    
    /// Returns the number of decimals of the NEO token.
    ///
    /// Doesn't require a call to the Neo node.
    /// - Returns: The number of decimals
    public override func getDecimals() async throws -> Int {
        return NeoToken.DECIMALS
    }
        
    // MARK: Unclaimed Gas
    
    /// Gets the amount of unclaimed GAS at the given height for the given account.
    /// - Parameters:
    ///   - account: The account
    ///   - blockHeight: The block height
    /// - Returns: The amount of unclaimed GAS
    public func unclaimedGas(_ account: Account, _ blockHeight: Int) async throws -> Int {
        return try await unclaimedGas(account.getScriptHash(), blockHeight)
    }
    
    /// Gets the amount of unclaimed GAS at the given height for the given account.
    /// - Parameters:
    ///   - account: The account's script hash
    ///   - blockHeight: The block height
    /// - Returns: The amount of unclaimed GAS
    public func unclaimedGas(_ scriptHash: Hash160, _ blockHeight: Int) async throws -> Int {
        return try await callFunctionReturningInt(NeoToken.UNCLAIMED_GAS, [.hash160(scriptHash), .integer(blockHeight)])
    }
    
    // MARK: Candidate Registration
    
    /// Creates a transaction script for registering a candidate with the given public key and initializes a  ``TransactionBuilder`` based on this script.
    ///
    /// Note that the transaction has to be signed with the account corresponding to the public key.
    /// - Parameter candidateKey: The public key to register as a candidate
    /// - Returns: A transaction builder
    public func registerCandidate(_ candidateKey: ECPublicKey) throws -> TransactionBuilder {
        return try invokeFunction(NeoToken.REGISTER_CANDIDATE, [.publicKey(candidateKey.getEncoded(compressed: true))])
    }
    
    /// Creates a transaction script for unregistering a candidate with the given public key and initializes a  ``TransactionBuilder`` based on this script.
    /// - Parameter candidateKey: The public key to unregister as a candidate
    /// - Returns: A transaction builder
    public func unregisterCandidate(_ candidateKey: ECPublicKey) throws -> TransactionBuilder {
        return try invokeFunction(NeoToken.UNREGISTER_CANDIDATE, [.publicKey(candidateKey.getEncoded(compressed: true))])
    }
    
    // MARK: Committee and Candidates Information
    
    /// Gets the public keys of the current committee members.
    /// - Returns: The committee members' public keys
    public func getCommittee() async throws -> [ECPublicKey] {
        return try await callFunctionReturningListOfPublicKeys(NeoToken.GET_COMMITTEE)
    }
    
    /// Gets the public keys of the registered candidates and their corresponding vote count.
    ///
    /// Note that this method returns at max 256 candidates. Use ``NeoToken/getAllCandidatesIterator()`` to traverse through all candidates if there are more than 256.
    /// - Returns: The candidates
    public func getCandidates() async throws -> [Candidate] {
        let arrayItem = try await callInvokeFunction(NeoToken.GET_CANDIDATES).getResult().getFirstStackItem()
        guard case .array = arrayItem else {
            throw ContractError.unexpectedReturnType(arrayItem.jsonValue, [StackItem.ARRAY_VALUE])
        }
        return try arrayItem.list!.map(candidateMapper)
    }
    
    /// Checks if there is a candidate with the provided public key.
    ///
    /// Note that this only checks the first 256 candidates. Use ``NeoToken/getAllCandidatesIterator()`` to traverse through all candidates if there are more than 256.
    /// - Parameter publicKey: The candidate's public key
    /// - Returns: `true` if the public key belongs to a candidate. Otherwise `false`
    public func isCandidate(_ publicKey: ECPublicKey) async throws -> Bool {
        return try await getCandidates().contains { $0.publicKey == publicKey }
    }
    
    /// Gets an iterator of all registered candidates.
    ///
    /// Use the method ``Iterator/traverse(_:)`` to traverse the iterator and retrieve all candidates.
    /// - Returns: An iterator of all registered candidates
    public func getAllCandidatesIterator() async throws -> Iterator<Candidate> {
        return try await callFunctionReturningIterator(NeoToken.GET_ALL_CANDIDATES, mapper: candidateMapper)
    }
    
    private func candidateMapper(_ stackItem: StackItem) throws -> Candidate {
        let list = try stackItem.getList()
        return try .init(publicKey: .init(list[0].getByteArray()), votes: list[1].getInteger())
    }
    
    /// Gets the votes for a specific candidate.
    /// - Parameter pubKey: The candidate's public key
    /// - Returns: The candidate's votes, or -1 if it was not found
    public func getCandidateVotes(_ pubKey: ECPublicKey) async throws -> Int {
        return try await callFunctionReturningInt(NeoToken.GET_CANDIDATE_VOTES, [.publicKey(pubKey)])
    }
    
    /// Gets the public keys of the next block's validators.
    /// - Returns: The validators' public keys
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
    
    /// Creates a transaction script to vote for the given candidate and initializes a ``TransactionBuilder`` based on this script.
    /// - Parameters:
    ///   - voter: Tthe account that casts the vote
    ///   - candidate: The candidate to vote for. If null, then the current vote of the voter is withdrawn (see ``NeoToken/cancelVote(_:)-97svv``
    /// - Returns: A transaction builder
    public func vote(_ voter: Account, _ candidate: ECPublicKey?) async throws -> TransactionBuilder {
        return try await vote(voter.getScriptHash(), candidate)
    }
    
    /// Creates a transaction script to vote for the given candidate and initializes a ``TransactionBuilder`` based on this script.
    /// - Parameters:
    ///   - voter: Tthe account script hash that casts the vote
    ///   - candidate: The candidate to vote for. If null, then the current vote of the voter is withdrawn (see ``NeoToken/cancelVote(_:)-97svv``
    /// - Returns: A transaction builder
    public func vote(_ voter: Hash160, _ candidate: ECPublicKey?) async throws -> TransactionBuilder {
        guard let candidate = candidate else {
            return try invokeFunction(NeoToken.VOTE, [.hash160(voter), .any(nil)])
        }
        return try invokeFunction(NeoToken.VOTE, [.hash160(voter), .publicKey(candidate.getEncoded(compressed: true))])
    }
    
    /// Creates a transaction script to cancel the vote of `voter` and initializes a ``TransactionBuilder`` based on the script.
    /// - Parameter voter: The account for which to cancel the vote
    /// - Returns: A transaction builder
    public func cancelVote(_ voter: Account) async throws -> TransactionBuilder {
        return try await cancelVote(voter.getScriptHash())
    }
    
    /// Creates a transaction script to cancel the vote of `voter` and initializes a ``TransactionBuilder`` based on the script.
    /// - Parameter voter: The account script hash for which to cancel the vote
    /// - Returns: A transaction builder
    public func cancelVote(_ voter: Hash160) async throws -> TransactionBuilder {
        return try await vote(voter, nil)
    }
    
    /// Builds a script to vote for a candidate.
    /// - Parameters:
    ///   - voter: The account that casts the vote
    ///   - candidate: The candidate to vote for. If null, then the current vote of the voter is withdrawn (see ``NeoToken/cancelVote(_:)-9mruz``)
    /// - Returns: The script
    public func buildVoteScript(_ voter: Hash160, _ candidate: ECPublicKey?) throws -> Bytes {
        guard let candidate = candidate else {
            return try buildInvokeFunctionScript(NeoToken.VOTE, [.hash160(voter), .any(nil)])
        }
        return try buildInvokeFunctionScript(NeoToken.VOTE, [.hash160(voter), .publicKey(candidate.getEncoded(compressed: true))])
    }
    
    // MARK: Network Settings
    
    /// Gets the number of GAS generated in each block.
    /// - Returns: The max GAS amount per block
    public func getGasPerBlock() async throws -> Int {
        return try await callFunctionReturningInt(NeoToken.GET_GAS_PER_BLOCK)
    }
    
    /// Creates a transaction script to set the number of GAS generated in each block and initializes a ``TransactionBuilder`` based on this script.
    ///
    /// This contract invocation can only be successful if it is signed by the network committee.
    /// - Parameter gasPerBlock: The maximum amount of GAS in one block
    /// - Returns: The transaction builder
    public func setGasPerBlock(_ gasPerBlock: Int) throws -> TransactionBuilder {
        return try invokeFunction(NeoToken.SET_GAS_PER_BLOCK, [.integer(gasPerBlock)])
    }
    
    /// Gets the price to register as a candidate.
    /// - Returns: The price to register as a candidate
    public func getRegisterPrice() async throws -> Int {
        return try await callFunctionReturningInt(NeoToken.GET_REGISTER_PRICE)
    }
    
    /// Creates a transaction script to set the price for candidate registration and initializes a ``TransactionBuilder`` based on this script.
    ///
    /// This contract invocation can only be successful if it is signed by the network committee.
    /// - Parameter registerPrice: The price to register as a candidate
    /// - Returns: The transaction builder
    public func setRegisterPrice(_ registerPrice: Int) throws -> TransactionBuilder {
        return try invokeFunction(NeoToken.SET_REGISTER_PRICE, [.integer(registerPrice)])
    }
    
    /// Gets the state of an account.
    /// - Parameter account: The account to get the state from
    /// - Returns: The account state
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
        return try .init(balance: balance, balanceHeight: updateHeight, publicKey: ECPublicKey(publicKeyItem.getHexString()))
    }
    
    /// This class represents the state of a candidate.
    public struct Candidate: Hashable {
        
        /// The candidate's public key.
        public let publicKey: ECPublicKey
        /// The candidate's votes. It is based on the summed up NEO balances of this candidate's voters.
        public let votes: Int
        
    }
    
}
