
import Foundation

/// Wrapper class to generate NEP-9 compatible URI schemes for NEP-17 Token transfers.
public class NeoURI {
    
    /// The NEP-9 `URL` of this NeoURI.
    public private(set) var uri: URL?
    public private(set) var neoSwift: NeoSwift?
    /// The script hash of the recipient address.
    public private(set) var recipient: Hash160?
    /// The token
    public private(set) var token: Hash160?
    /// The amount
    public private(set) var amount: Decimal?
    
    private static let NEO_SCHEME = "neo"
    private static let MIN_NEP9_URI_LENGTH = 38
    private static let NEO_TOKEN_STRING = "neo"
    private static let GAS_TOKEN_STRING = "gas"

    /// The NEP-9 URI of this NeoURI as string.
    public var uriString: String? {
        return uri?.absoluteString
    }
    
    /// The recipient address
    public var recipientAddress: String? {
        return recipient?.toAddress()
    }
    
    /// The token as a string
    public var tokenString: String? {
        switch token {
        case NeoToken.SCRIPT_HASH: return NeoURI.NEO_TOKEN_STRING
        case GasToken.SCRIPT_HASH: return NeoURI.GAS_TOKEN_STRING
        default: return token?.string
        }
    }
    
    /// The token as an address
    public var tokenAddress: String? {
        return token?.toAddress()
    }
    
    /// The amount as a string
    public var amountString: String? {
        return amount == nil ? nil : "\(amount!)"
    }
    
    public init() {}
    
    public init(_ neoSwift: NeoSwift) {
        self.neoSwift = neoSwift
    }
    
    /// Creates a NeoURI from a NEP-9 URI String.
    /// - Parameter uriString: A NEP-9 URI String
    /// - Returns: A NeoURI object
    public static func fromURI(_ uriString: String) throws -> NeoURI {
        let baseAndQuery = uriString.components(separatedBy: "?")
        guard let beginTx = baseAndQuery.first?.components(separatedBy: ":"),
              beginTx.count == 2, beginTx.first == NEO_SCHEME,
              uriString.count >= MIN_NEP9_URI_LENGTH else {
            throw NeoSwiftError.illegalArgument("The provided string does not conform to the NEP-9 standard.")
        }
        
        let neoURI = try NeoURI().to(.fromAddress(beginTx[1]))
        
        if baseAndQuery.count == 2 {
            let query = baseAndQuery[1].components(separatedBy: "&")
            try query.forEach { singleQuery in
                let parts = singleQuery.components(separatedBy: "=")
                guard parts.count == 2 else {
                    throw NeoSwiftError.illegalArgument("This URI contains invalid queries.")
                }
                if parts[0] == "asset" && neoURI.token == nil {
                    _ = try neoURI.token(parts[1])
                } else if parts[0] == "amount" && neoURI.amount == nil {
                    neoURI.amount = Decimal(string: parts[1])
                }
            }
        }
        
        return neoURI
    }
    
    /// Creates a transaction script to transfer and initializes a ``TransactionBuilder`` based on this script which is ready to be signed and sent.
    /// - Parameter sender: The sender account
    /// - Returns: A transaction builder
    public func buildTransferFrom(_ sender: Account) async throws -> TransactionBuilder {
        guard let neoSwift = neoSwift else {
            throw NeoSwiftError.illegalState("NeoSwift instance is not set.")
        }
        guard let recipient = recipient else {
            throw NeoSwiftError.illegalState("Recipient is not set.")
        }
        guard let amount = amount else {
            throw NeoSwiftError.illegalState("Amount is not set.")
        }
        guard let tokenHash = token else {
            throw NeoSwiftError.illegalState("Token is not set.")
        }
        
        let token = FungibleToken(scriptHash: tokenHash, neoSwift: neoSwift)
        let amountScale = amount.scale
        
        if isNeoToken(tokenHash) && amountScale > NeoToken.DECIMALS {
            throw NeoSwiftError.illegalArgument("The NEO token does not support any decimal places.")
        } else if isGasToken(tokenHash) && amountScale > GasToken.DECIMALS {
            throw NeoSwiftError.illegalArgument("The GAS token does not support more than \(GasToken.DECIMALS) decimal places.")
        } else {
            let decimals = try await token.getDecimals()
            if amountScale > decimals {
                throw NeoSwiftError.illegalArgument("The \(tokenHash) token does not support more than \(decimals) decimal places.")
            }
        }
        return try await token.transfer(sender, recipient, token.toFractions(amount))
    }
    
    private func isNeoToken(_ token: Hash160) -> Bool {
        return token == NeoToken.SCRIPT_HASH
    }
    
    private func isGasToken(_ token: Hash160) -> Bool {
        return token == GasToken.SCRIPT_HASH
    }
    
    /// Sets the recipient's script hash.
    /// - Parameter recipient: The recipient's script hash
    /// - Returns: This NeoURI object
    public func to(_ recipient: Hash160) -> NeoURI {
        self.recipient = recipient
        return self
    }
    
    /// Sets the token.
    /// - Parameter token: The token hash
    /// - Returns: This NeoURI object
    public func token(_ token: Hash160) -> NeoURI {
        self.token = token
        return self
    }
    
    /// Sets the token.
    /// - Parameter token: The token hash, 'neo' or 'gas'
    /// - Returns: This NeoURI object
    public func token(_ token: String) throws -> NeoURI {
        switch token {
        case NeoURI.NEO_TOKEN_STRING: self.token = NeoToken.SCRIPT_HASH
        case NeoURI.GAS_TOKEN_STRING: self.token = GasToken.SCRIPT_HASH
        default: self.token = try Hash160(token)
        }
        return self
    }
    
    /// Sets the amount.
    ///
    /// Make sure to use decimals and not token fractions. E.g. for GAS use 1.5 instead of 150_000_000.
    /// - Parameter amount: The amount
    /// - Returns: This NeoURI object
    public func amount(_ amount: Decimal) -> NeoURI {
        self.amount = amount
        return self
    }
    
    /// Sets the NeoSwift instance
    /// - Parameter neoSwift: The NeoSwift instance
    /// - Returns: This NeoURI object
    public func neoSwift(_ neoSwift: NeoSwift) -> NeoURI {
        self.neoSwift = neoSwift
        return self
    }
    
    private func buildQueryPart() -> String {
        var query: [String] = []
        if let tokenHash = token {
            switch tokenHash {
            case NeoToken.SCRIPT_HASH: query.append("asset=\(NeoURI.NEO_TOKEN_STRING)")
            case GasToken.SCRIPT_HASH: query.append("asset=\(NeoURI.GAS_TOKEN_STRING)")
            default: query.append("asset=\(tokenHash.string)")
            }
        }
        if let amount = amount {
            query.append("amount=\(amount)")
        }
        return query.joined(separator: "&")
    }
    
    /// Builds a NEP-9 URI from the set variables and stores its value to its variable `uri` as a `URL`.
    /// - Returns: This NeoURI object
    public func buildURI() throws -> NeoURI {
        guard let recipient = recipient else {
            throw NeoSwiftError.illegalState("Could not create a NEP-9 URI without a recipient address.")
        }
        let base = "\(NeoURI.NEO_SCHEME):\(recipient.toAddress())"
        let query = buildQueryPart()
        uri = URL(string: base + (query == "" ? "" : "?\(query)"))
        return self
    }
    
}
