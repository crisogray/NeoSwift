
/// Represents the official NeoNameService contract and provides methods to invoke its functions.
///
/// To set a specific script hash for this contract, see ``NeoSwiftConfig/setNNSResolver(_:)``.
/// By default the official NNS contract deployed on mainnet with the script hash
/// `0x50ac1c37690cc2cfc594472833cf57505d5f46de` is used.
public class NeoNameService: NonFungibleToken {
    
    private static let ADD_ROOT = "addRoot"
    private static let ROOTS = "roots"
    private static let SET_PRICE = "setPrice"
    private static let GET_PRICE = "getPrice"
    private static let IS_AVAILABLE = "isAvailable"
    private static let REGISTER = "register"
    private static let RENEW = "renew"
    private static let SET_ADMIN = "setAdmin"
    private static let SET_RECORD = "setRecord"
    private static let GET_RECORD = "getRecord"
    private static let GET_ALL_RECORDS = "getAllRecords"
    private static let DELETE_RECORD = "deleteRecord"
    private static let RESOLVE = "resolve"
    private static let PROPERTIES = "properties"

    private static let NAME_PROPERTY = StackItem.byteString("name".bytes)
    private static let EXPIRATION_PROPERTY = StackItem.byteString("expiration".bytes)
    private static let ADMIN_PROPERTY = StackItem.byteString("admin".bytes)
    
    /// Initializes an interface to the NeoNameService smart contract.
    ///
    /// Uses the NNS script hash specified in the ``NeoSwiftConfig``.
    /// By default the official NNS smart contract deployed on mainnet with the script hash `0x50ac1c37690cc2cfc594472833cf57505d5f46de` is used.
    /// Uses the given ``NeoSwift`` instance for invocations.
    /// - Parameter neoSwift: The ``NeoSwift`` instance to use for invocations
    public init(neoSwift: NeoSwift) {
        super.init(scriptHash: neoSwift.nnsResolver, neoSwift: neoSwift)
    }
    
    /// Returns the name of the NeoNameService contract.
    ///
    /// Doesn't require a call to the Neo node.
    /// - Returns: The name
    public override func getName() async throws -> String? {
        return "NameService"
    }
    
    // MARK: NEP-11 Methods
    
    /// Returns the symbol of the NeoNameService contract.
    ///
    /// Doesn't require a call to the Neo node.
    /// - Returns: The symbol of the NeoNameService contract
    public override func getSymbol() async throws -> String {
        return "NNS"
    }
    
    /// Returns the decimals of the NeoNameService contract.
    ///
    /// Doesn't require a call to the Neo node.
    /// - Returns: The decimals of the NeoNameService contract
    public override func getDecimals() async throws -> Int {
        return 0
    }
    
    /// Gets the owner of of the domain name.
    /// - Parameter name: The domain name
    /// - Returns: The owner of of the domain name
    public func ownerOf(_ name: NNSName) async throws -> Hash160 {
        return try await ownerOf(name.bytes)
    }
    
    /// Gets the properties of the domain name.
    /// - Parameter name: The domain name
    /// - Returns: The properties of the domain name
    public func properties(_ name: NNSName) async throws -> [String : String] {
        return try await properties(name.bytes)
    }
    
    /// Creates a transaction script to transfer a domain name and initializes a ``TransactionBuilder`` based on this script.
    ///
    /// The returned ``TransactionBuilder`` is ready to be signed and sent. The `from` account is set as a signer on the transaction.
    /// Use the `data` parameter if the receiver of the domain name is a smart contract and you want to pass data to its `onNEP11Payment` method.
    /// - Parameters:
    ///   - from: The owner of the domain name
    ///   - to: The receiver of the domain name
    ///   - name: The domain name
    ///   - data: The data that is passed to the `onNEP11Payment` method of the receiving smart contract
    /// - Returns: A transaction builder
    public func transfer(_ from: Account, _ to: Hash160, _ name: NNSName, _ data: ContractParameter? = nil) async throws -> TransactionBuilder {
        try await checkDomainNameAvailability(name, false)
        return try await transfer(from, to, name.bytes, data)
    }
    
    // MARK: Custom Name Service Methods
    
    /// Creates a transaction script to add a root domain (like .neo) and initializes a ``TransactionBuilder`` based on this script.
    ///
    /// Only the committee is allowed to add a new root domain.
    /// Requires to be signed by the committee.
    /// - Parameter nnsRoot: The new root domain
    /// - Returns: A transaction builder
    public func addRoot(_ nnsRoot: NNSName.NNSRoot) throws -> TransactionBuilder {
        return try invokeFunction(NeoNameService.ADD_ROOT, [.string(nnsRoot.root)])
    }
    
    /// Gets all existing roots.
    ///
    /// This method requires sessions to be enabled on the Neo node. If sessions are disabled on the Neo node, use ``NeoNameService/getRootsUnwrapped()``.
    /// - Returns: The roots
    public func getRoots() async throws -> Iterator<String> {
        return try await callFunctionReturningIterator(NeoNameService.ROOTS, [], mapper: { try $0.getString() })
    }
    
    /// Gets all existing roots.
    ///
    /// Use this method if sessions are disabled on the Neo node.
    /// This method returns at most ``NeoConstants/MAX_ITERATOR_ITEMS_DEFAULT`` values.
    /// If there are more values, connect to a Neo node that supports sessions and use ``NeoNameService/getRoots()``.
    /// - Returns: The roots
    public func getRootsUnwrapped() async throws -> [String] {
        return try await callFunctionAndUnwrapIterator(NeoNameService.ROOTS, [], NeoConstants.MAX_ITERATOR_ITEMS_DEFAULT, [])
            .map { try $0.getString() }
    }
    
    /// Creates a transaction script to set the prices for registering a domain and initializes a ``TransactionBuilder`` based on this script.
    ///
    /// Only the committee is allowed to set the price.
    /// Requires to be signed by the committee.
    /// - Parameter priceList: The prices for registering a domain. The index refers to the length of the domain.
    /// The value at index 0 is used for domain names longer than the price list's highest index. Use -1 for domain name lengths that are
    /// - Returns: A transaction builder
    public func setPrice(_ priceList: [Int]) throws -> TransactionBuilder {
        return try invokeFunction(NeoNameService.SET_PRICE, [.array(priceList)])
    }
    
    /// Gets the price to register a domain name of a certain length.
    /// - Parameter domainNameLength: The length of the domain name
    /// - Returns: The price to register a domain
    public func getPrice(_ domainNameLength: Int) async throws -> Int {
        return try await callFunctionReturningInt(NeoNameService.GET_PRICE, [.integer(domainNameLength)])
    }
    
    /// Checks if the specified domain name is available.
    /// - Parameter name: The domain name
    /// - Returns: `true` if the domain name is available. Otherwise `false`
    public func isAvailable(_ name: NNSName) async throws -> Bool {
        return try await callFunctionReturningBool(NeoNameService.IS_AVAILABLE, [.string(name.name)])
    }
    
    /// Creates a transaction script to register a new domain name and initializes a ``TransactionBuilder`` based on this script.
    /// - Parameters:
    ///   - name: The domain name
    ///   - owner: The address of the domain owner.
    /// - Returns: A transaction builder
    public func register(_ name: NNSName, _ owner: Hash160) async throws -> TransactionBuilder {
        try await checkDomainNameAvailability(name, true)
        return try invokeFunction(NeoNameService.REGISTER, [.string(name.name), .hash160(owner)])
    }
    
    /// Creates a transaction script to update the TTL of the domain name and initializes a ``TransactionBuilder`` based on this script.
    ///
    /// Each call will extend the validity period of the domain name by one year.
    /// - Parameter name: The domain name
    /// - Returns: A transaction builder
    public func renew(_ name: NNSName) async throws -> TransactionBuilder {
        try await checkDomainNameAvailability(name, false)
        return try invokeFunction(NeoNameService.RENEW, [.string(name.name)])
    }
    
    /// Creates a transaction script to update the TTL of the domain name and initializes a ``TransactionBuilder`` based on this script.
    /// - Parameters:
    ///   - name: The domain name
    ///   - years: Te number of years to renew this domain name. Has to be in the range of 1 to 10
    /// - Returns: A transaction builder
    public func renew(_ name: NNSName, _ years: Int) async throws -> TransactionBuilder {
        guard years > 0 && years <= 10 else {
            throw NeoSwiftError.illegalArgument("Domain names can only be renewed by at least 1, and at most 10 years.")
        }
        try await checkDomainNameAvailability(name, false)
        return try invokeFunction(NeoNameService.RENEW, [.string(name.name), .integer(years)])
    }
    
    /// Creates a transaction script to set the admin for the specified domain name and initializes a ``TransactionBuilder`` based on this script.
    ///
    /// Requires to be signed by the current owner and the new admin of the domain.
    /// - Parameters:
    ///   - name: The domain name
    ///   - admin: The script hash of the admin address
    /// - Returns: A transaction builder
    public func setAdmin(_ name: NNSName, _ admin: Hash160) async throws -> TransactionBuilder {
        try await checkDomainNameAvailability(name, false)
        return try invokeFunction(NeoNameService.SET_ADMIN, [.string(name.name), .hash160(admin)])
    }
    
    /// Creates a transaction script to set the type of the specified domain name and the corresponding type data and initializes a ``TransactionBuilder`` based on this script.
    ///
    /// Requires to be signed by the domain owner or the domain admin.
    /// - Parameters:
    ///   - name: The domain name
    ///   - type: The record type
    ///   - data: The corresponding data
    /// - Returns: A transaction builder
    public func setRecord(_ name: NNSName, _ type: RecordType, _ data: String) throws -> TransactionBuilder {
        return try invokeFunction(NeoNameService.SET_RECORD, [.string(name.name), .integer(type.byte), .string(data)])
    }
    
    /// Gets the record type data of the domain name.
    /// - Parameters:
    ///   - name: The domain name
    ///   - type: The record type
    /// - Returns: A transaction builder
    public func getRecord(_ name: NNSName, _ type: RecordType) async throws -> String {
        do {
            return try await callFunctionReturningString(NeoNameService.GET_RECORD, [.string(name.name), .integer(type.byte)])
        } catch ContractError.unexpectedReturnType {
            throw NeoSwiftError.illegalArgument("Could not get a record of type '\(type)' for the domain name '\(name.name)'.")
        } catch ProtocolError.invocationFaultState {
            throw NeoSwiftError.illegalArgument("The domain name '\(name.name)' might not be registered or is in an invalid format.")
        }
    }
    
    /// Gets all records of the domain name.
    /// - Parameter name: The domain name
    /// - Returns: All records of the domain name
    public func getAllRecords(_ name: NNSName) async throws -> Iterator<RecordState> {
        return try await callFunctionReturningIterator(NeoNameService.GET_ALL_RECORDS, [.string(name.name)], mapper: RecordState.fromStackItem)
    }
    
    /// Gets all records of the domain name.
    ///
    /// Use this method if sessions are disabled on the Neo node.
    /// This method returns at most ``NeoConstants/MAX_ITERATOR_ITEMS_DEFAULT`` values.
    /// If there are more values,connect to a Neo node that supports sessions and use ``NeoNameService/getAllRecords(_:)``.
    /// - Parameter name: The domain name
    /// - Returns: All records of the domain name
    public func getAllRecordsUnwrapped(_ name: NNSName) async throws -> [RecordState] {
        return try await callFunctionAndUnwrapIterator(NeoNameService.GET_ALL_RECORDS, [.string(name.name)], NeoConstants.MAX_ITERATOR_ITEMS_DEFAULT, [])
            .map(RecordState.fromStackItem)
    }
    
    /// Creates a transaction script to delete record data of a domain name initializes a ``TransactionBuilder`` based on this script.
    ///
    /// Requires to be signed by the domain owner or the domain admin.
    /// - Parameters:
    ///   - name: The domain name
    ///   - type: The record type
    /// - Returns: A transaction builder
    public func deleteRecord(_ name: NNSName, _ type: RecordType) throws -> TransactionBuilder {
        return try invokeFunction(NeoNameService.DELETE_RECORD, [.string(name.name), .integer(type.byte)])
    }
    
    /// Resolves a domain name.
    /// - Parameters:
    ///   - name: The domain name
    ///   - type: The record type
    /// - Returns: The resolution result
    public func resolve(_ name: NNSName, _ type: RecordType) async throws -> String {
        do {
            return try await callFunctionReturningString(NeoNameService.RESOLVE, [.string(name.name), .integer(type.byte)])
        } catch {
            throw ContractError.unresolvableDomainName(name.name)
        }
    }
    
    internal func checkDomainNameAvailability(_ name: NNSName, _ shouldBeAvailable: Bool) async throws {
        let isAvailable = try await isAvailable(name)
        if shouldBeAvailable && !isAvailable {
            throw NeoSwiftError.illegalArgument("The domain name '\(name.name)' is already taken.")
        } else if !shouldBeAvailable && isAvailable {
            throw NeoSwiftError.illegalArgument("The domain name '\(name.name)' is not registered.")
        }
    }
    
    /// Gets the state of the domain name.
    ///
    /// Relates to the NEP-11 properties deserialized into a ``NameState`` object.
    /// - Parameter name: The domain name
    /// - Returns: The state of the domain name as ``NameState``
    public func getNameState(_ name: NNSName) async throws -> NameState {
        return try await getNameState(name.bytes)
    }
    
    /// Gets the state of the domain name.
    ///
    /// Relates to the NEP-11 properties deserialized into a ``NameState`` object.
    /// - Parameter name: The domain name as bytes
    /// - Returns: The state of the domain name as ``NameState``
    public func getNameState(_ name: Bytes) async throws -> NameState {
        let invocationResult = try await callInvokeFunction(NeoNameService.PROPERTIES, [.byteArray(name)]).getResult()
        return try deserializeNameState(invocationResult)
    }
    
    private func deserializeNameState(_ invocationResult: InvocationResult) throws -> NameState {
        try throwIfFaultState(invocationResult)
        let map = try mapStackItem(invocationResult).map!
        guard let name = map[NeoNameService.NAME_PROPERTY]?.string else {
            throw NeoSwiftError.illegalState("'name' property not found in stack item")
        }
        guard let expiration = map[NeoNameService.EXPIRATION_PROPERTY]?.integer else {
            throw NeoSwiftError.illegalState("'expiration' property not found in stack item")
        }
        if let adminAddress = map[NeoNameService.ADMIN_PROPERTY]?.address {
            return try NameState(name: name, expiration: expiration, admin: Hash160.fromAddress(adminAddress))
        }
        return NameState(name: name, expiration: expiration, admin: nil)
    }
    
}
