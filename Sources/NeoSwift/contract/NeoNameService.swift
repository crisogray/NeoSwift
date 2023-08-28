
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

    public init(neoSwift: NeoSwift) {
        super.init(scriptHash: neoSwift.nnsResolver, neoSwift: neoSwift)
    }
    
    public override func getName() async throws -> String? {
        return "NameService"
    }
    
    // MARK: NEP-11 Methods
    
    public override func getSymbol() async throws -> String {
        return "NNS"
    }
    
    public override func getDecimals() async throws -> Int {
        return 0
    }
    
    public func ownerOf(_ name: NNSName) async throws -> Hash160 {
        return try await ownerOf(name.bytes)
    }
    
    public func properties(_ name: NNSName) async throws -> [String : String] {
        return try await properties(name.bytes)
    }
    
    public func transfer(_ from: Account, _ to: Hash160, _ name: NNSName, _ data: ContractParameter? = nil) async throws -> TransactionBuilder {
        try await checkDomainNameAvailability(name, false)
        return try await transfer(from, to, name.bytes, data)
    }
    
    // MARK: Custom Name Service Methods
    
    public func addRoot(_ nnsRoot: NNSName.NNSRoot) throws -> TransactionBuilder {
        return try invokeFunction(NeoNameService.ADD_ROOT, [.string(nnsRoot.root)])
    }
    
    public func getRoots() async throws -> Iterator<String> {
        return try await callFunctionReturningIterator(NeoNameService.ROOTS, [], mapper: { try $0.getString() })
    }
    
    public func getRootsUnwrapped() async throws -> [String] {
        return try await callFunctionAndUnwrapIterator(NeoNameService.ROOTS, [], NeoConstants.MAX_ITERATOR_ITEMS_DEFAULT, [])
            .map { try $0.getString() }
    }
    
    public func setPrice(_ priceList: [Int]) throws -> TransactionBuilder {
        return try invokeFunction(NeoNameService.SET_PRICE, [.array(priceList)])
    }
    
    public func getPrice(_ domainNameLength: Int) async throws -> Int {
        return try await callFunctionReturningInt(NeoNameService.GET_PRICE, [.integer(domainNameLength)])
    }
    
    public func isAvailable(_ name: NNSName) async throws -> Bool {
        return try await callFunctionReturningBool(NeoNameService.IS_AVAILABLE, [.string(name.name)])
    }
    
    public func register(_ name: NNSName, _ owner: Hash160) async throws -> TransactionBuilder {
        try await checkDomainNameAvailability(name, true)
        return try invokeFunction(NeoNameService.REGISTER, [.string(name.name), .hash160(owner)])
    }
    
    public func renew(_ name: NNSName) async throws -> TransactionBuilder {
        try await checkDomainNameAvailability(name, false)
        return try invokeFunction(NeoNameService.RENEW, [.string(name.name)])
    }
    
    public func renew(_ name: NNSName, _ years: Int) async throws -> TransactionBuilder {
        guard years > 0 && years <= 10 else {
            throw NeoSwiftError.illegalArgument("Domain names can only be renewed by at least 1, and at most 10 years.")
        }
        try await checkDomainNameAvailability(name, false)
        return try invokeFunction(NeoNameService.RENEW, [.string(name.name), .integer(years)])
    }
    
    public func setAdmin(_ name: NNSName, _ admin: Hash160) async throws -> TransactionBuilder {
        try await checkDomainNameAvailability(name, false)
        return try invokeFunction(NeoNameService.SET_ADMIN, [.string(name.name), .hash160(admin)])
    }
    
    public func setRecord(_ name: NNSName, _ type: RecordType, _ data: String) throws -> TransactionBuilder {
        return try invokeFunction(NeoNameService.SET_RECORD, [.string(name.name), .integer(type.byte), .string(data)])
    }
    
    public func getRecord(_ name: NNSName, _ type: RecordType) throws -> TransactionBuilder {
        do {
            return try invokeFunction(NeoNameService.GET_RECORD, [.string(name.name), .integer(type.byte)])
        } catch ContractError.unresolvableDomainName {
            throw NeoSwiftError.illegalArgument("Could not get a record of type '\(type)' for the domain name '\(name)'.")
        } catch ProtocolError.invocationFaultSate {
            throw NeoSwiftError.illegalArgument("The domain name '\(name.name)' might not be registered or is in an invalid format.")
        }
    }
    
    public func getAllRecords(_ name: NNSName) async throws -> Iterator<RecordState> {
        return try await callFunctionReturningIterator(NeoNameService.GET_ALL_RECORDS, [.string(name.name)], mapper: RecordState.fromStackItem)
    }
    
    public func getAllRecordsUnwrapped(_ name: NNSName) async throws -> [RecordState] {
        return try await callFunctionAndUnwrapIterator(NeoNameService.GET_ALL_RECORDS, [.string(name.name)], NeoConstants.MAX_ITERATOR_ITEMS_DEFAULT, [])
            .map(RecordState.fromStackItem)
    }
    
    public func deleteRecord(_ name: NNSName, _ type: RecordType) throws -> TransactionBuilder {
        return try invokeFunction(NeoNameService.DELETE_RECORD, [.string(name.name), .integer(type.byte)])
    }
    
    public func resolve(_ name: NNSName, _ type: RecordType) async throws -> String {
        do {
            return try await callFunctionReturningString(NeoNameService.RESOLVE, [.string(name.name), .integer(type.byte)])
        } catch {
            throw ContractError.unresolvableDomainName(name.name)
        }
    }
    
    private func checkDomainNameAvailability(_ name: NNSName, _ shouldBeAvailable: Bool) async throws {
        let isAvailable = try await isAvailable(name)
        if shouldBeAvailable && !isAvailable {
            throw NeoSwiftError.illegalArgument("The domain name '\(name.name)' is already taken.")
        } else if !shouldBeAvailable && isAvailable {
            throw NeoSwiftError.illegalArgument("The domain name '\(name.name)' is not registered.")
        }
    }
    
    public func getNameState(_ name: NNSName) async throws -> NameState {
        return try await getNameState(name.bytes)
    }
    
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
