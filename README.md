
# NeoSwift
NeoSwift is a Swift SDK for interacting with the Neo blockchain from iOS and Mac devices. It is designed to have the same interface as the existing Java/Android SDK [neow3j.](https://github.com/neow3j/neow3j)

## Installation
You can import NeoSwift into your project using Swift Package Manager in Xcode.

Go to File > Add Packages and search using the URL below.

`https://github.com/crisogray/NeoSwift`

Alternatively, if using `Package.swift`, you can add the package by adding the following line to the list of dependencies `.package(url: “https://github.com/crisogray/NeoSwift”, from: “0.1.0”)` and add `NeoSwift` to the dependencies in your target.

## Usage
The NeoSwift library is designed to be used almost identically to the neow3j Java package on which it's based. There are of course syntactic differences between the two packages, with the Swift code examples below showing the syntax for each corresponding part of the [neow3j dApp Development documentation](https://neow3j.io/#/neo-n3/dapp_development/introduction).
### Interacting with a Neo Node
[neow3j docs](https://neow3j.io/#/neo-n3/dapp_development/interacting_with_a_node)
#### Setting up a Connection
Instantiating a `NeoSwift` object.
```
let url = URL(string: "http://localhost:40332")!
let neoSwift = NeoSwift.build(HttpService(url: url))
```
Instantiating a `NeoSwift` object with a config.
```
let url = URL(string: "http://localhost:40332")!
let neoSwift = NeoSwift.build(HttpService(url: url), NeoSwiftConfig(networkMagic: 769))
```
#### Monitoring the Blockchain
Getting all blocks starting at block index 100 and subscribing to any newly generated blocks.
```
neoSwift.catchUpToLatestAndSubscribeToNewBlocksPublisher(100, true)
    .sink(receiveCompletion: { print("Completion: \($0)") }) { blockReqResult in
        if let block = blockReqResult.block {
            print(block.index)
            print(block.hash)
            print(block.confirmations)
            print(block.transactions ?? "No transactions")
        }
    }.store(in: &cancellables)
```
Just subscribing to latest blocks.
```
neoSwift.subscribeToNewBlocksPublisher(true)
    .sink(receiveCompletion: { print("Completion: \($0)") }) { blockReqResult in
        if let block = blockReqResult.block {
            print(block.index)
            print(block.hash)
            print(block.confirmations)
            print(block.transactions ?? "No transactions")
        }
    }.store(in: &cancellables)
```
#### Inspecting a Transaction
Checking the state of a single transaction.
```
let txHash = try Hash256("da5a53a79ac399e07c6eea366c192a4942fa930d6903ffc10b497f834a538fee")
let response = try await neoSwift.getTransaction(txHash).send()
if let error = response.error {
    throw error
}
let tx = response.transaction
```
Getting a raw transaction's raw byte array (as a base64 string).
```
let response = try await neoSwift.getRawTransaction(txHash).send()
let tx = response.rawTransaction
```
Getting results of an invoation using `getApplicationLog`.
```
let txHash = try Hash256("da5a53a79ac399e07c6eea366c192a4942fa930d6903ffc10b497f834a538fee")
let response = try await neoSwift.getApplicationLog(txHash).send()
if let error = response.error {
    throw error
}
// Get the first execution. Usually there is only one execution.
if let execution = response.applicationLog?.executions.first {
    // Check if the execution ended in a NeoVM state FAULT.
    if execution.state == .fault {
        // Invocation Failed
    }
    // Get the result stack.
    let stack = execution.stack
    let returnValue = stack.first
      
    // Get the notifications fired by the transaction.
    let notifications = execution.notification
}
```
#### Using a Wallet on the Node
Opening the wallet
```
let response = try await neoSwift.openWallet("/path/to/wallet.json", "walletPassword").send()
if let error = response.error {
    throw error
}
if let opened = response.openWallet, opened {
    // Successfully opened wallet.
} else {
    // Wallet not opened.
}
```
Listing the accounts in the wallet.
```
let response = try await neoSwift.listAddress().send()
if let error = response.error {
    throw error
}
let listOfAddresses = response.addresses
```
Checking the wallet's balances.
```
let response = try await neoSwift.getWalletBalance(NeoToken.SCRIPT_HASH).send()
if let error = response.error {
    throw error
}
let balance = response.walletBalance?.balance
```
Closing the wallet.
```
let response = try await neoSwift.closeWallet().send()
```
#### Neo-Express
Instantiating a `NeoSwiftExpress` object.
```
let url = URL(string: "http://localhost:40332")!
let neoSwiftExpress = NeoSwiftExpress.build(HttpService(url: url))
```
---
### Wallets and Accounts
[neow3j docs](https://neow3j.io/#/neo-n3/dapp_development/wallets_and_accounts)
#### Wallets
Creating a wallet.
```
let wallet = try Wallet.create()
```
Reading a wallet from an NEP-6 file and renaming.
```
let wallet = try Wallet.fromNEP6Wallet(url).name("NewName")
```
Creating a wallet from an account and updating name and version.
```
let wallet = try Wallet.withAccounts([Account.create()])
    .name("MyWallet")
    .version("1.0")
```
#### Accounts
Creating an account from a WIF and changing the label.
```
let account = try Account.fromWIF("L3kCZj6QbFPwbsVhxnB8nUERDy4mhCSrWJew4u5Qh5QmGMfnCTda")
    .label("MyAccount")
```
#### Multi-sig Accounts
Creating a multi-sig account from an array of public keys, with a signature threshold of 2.
```
let publicKeys = try [
    ECKeyPair.createEcKeyPair().publicKey,
    ECKeyPair.createEcKeyPair().publicKey,
    ECKeyPair.createEcKeyPair().publicKey
]
let account = try Account.createMultiSigAccount(publicKeys, 2)
```
#### Account Balances
Checking balances of an account.
```
let account = try Account.fromWIF("L3kCZj6QbFPwbsVhxnB8nUERDy4mhCSrWJew4u5Qh5QmGMfnCTda")

let url = URL(string: "http://localhost:40332"))!
let neoSwift = NeoSwift.build(HttpService(url: url))
let balances = try await account.getNep17Balances(neoSwift)
```

---
### Transactions
[neow3j docs](https://neow3j.io/#/neo-n3/dapp_development/transactions)
#### Building Transactions
Instantiating a `TransactionBuilder` object.
```
let url = URL(string: "http://localhost:40332")!
let neoSwift = NeoSwift.build(HttpService(url: url))
let builder = TransactionBuilder(neoSwift)
```
Adding a preconfigured script byte array to the builder.
```
builder.script(script)
```
Example of building, signing and sending a transaction.
```
let url = URL(string: mainnet)!
let neoSwift = NeoSwift.build(HttpService(url: url))
let account = try Account.fromWIF("L3kCZj6QbFPwbsVhxnB8nUERDy4mhCSrWJew4u5Qh5QmGMfnCTda")
            
let script = try ScriptBuilder()
    .contractCall(NeoToken.SCRIPT_HASH, method: "symbol", params: [])
    .toArray()
            
let tx = try await TransactionBuilder(neoSwift)
    .script(script)
    .signers(AccountSigner.calledByEntry(account))
    .sign()
            
let response = try await tx.send()
```
#### Signing Transactions
Manually signing an unsigned transaction
```
let tx = try await builder.getUnsignedTransaction()
let account = try Account.fromWIF("L3kCZj6QbFPwbsVhxnB8nUERDy4mhCSrWJew4u5Qh5QmGMfnCTda")
let keyPair = account.keyPair!
let txBytes = try await tx.getHashData()
let witness = try Witness.create(txBytes, keyPair)
let response = try await tx.addWitness(witness).send()
```
#### Tracking Transactions
Tracking a transaction and receiving the index of the block in which it's contained.
```
try tx.track().sink(receiveCompletion: { print("Completion: \($0)") }) { blockIndex in
    print("Transaction contained in block \(blockIndex).")
}.store(in: &cancellables)
```
#### Adding Additional Network Fees
Adding an additional network fee to a transaction.
```
let tx = try await TransactionBuilder(neoSwift)
    .script(script)
    .signers(AccountSigner.calledByEntry(account))
    .additionalNetworkFee(1_000_000)
    .sign()
```
---
### Smart Contracts 
[neow3j docs](https://neow3j.io/#/neo-n3/dapp_development/smart_contracts)
#### Contract Parameters
Constructing a contract parameter representing a `bongo` instance (re [neow3j example](https://neow3j.io/#/neo-n3/dapp_development/smart_contracts?id=contract-parameters)).
```
let contractParameter = try ContractParameter.array(["C2", "C5"])
```
#### Contract Invocation
Creating a `SmartContract` object with a `NeoSwift` instance.
```
let scriptHash = try Hash160("0x1a70eac53f5882e40dd90f55463cce31a9f72cd4")
let smartContract = SmartContract(scriptHash: scriptHash, neoSwift: neoSwift)
```
Reading information from the ABI in the contract's manifest.
```
if let methods = try? await smartContract.getManifest().abi?.methods {
    print(methods)
}
```
Using the `SmartContract` instance to invoke the `register` function with the domain and account as parameters.
```
let account = try Account.fromWIF("L3kCZj6QbFPwbsVhxnB8nUERDy4mhCSrWJew4u5Qh5QmGMfnCTda")
let domainParam = ContractParameter.string("myname.neo")
let accountParam = try ContractParameter.hash160(account.getScriptHash())
            
let function = "register"
let txBuilder = try smartContract.invokeFunction(function, [domainParam, accountParam])
```
The complete invocation is below.
```
let url = URL(string: "http://localhost:40332")!
let neoSwift = NeoSwift.build(HttpService(url: url))

let scriptHash = try Hash160("0x1a70eac53f5882e40dd90f55463cce31a9f72cd4")
let smartContract = SmartContract(scriptHash: scriptHash, neoSwift: neoSwift)

let account = try Account.fromWIF("L3kCZj6QbFPwbsVhxnB8nUERDy4mhCSrWJew4u5Qh5QmGMfnCTda")
let domainParam = ContractParameter.string("myname.neo")
let accountParam = try ContractParameter.hash160(account.getScriptHash())
let function = "register"

let response = try await smartContract
    .invokeFunction(function, [domainParam, accountParam])
    .signers(AccountSigner.calledByEntry(account))
    .sign()
    .send()
```

#### Testing the Invocation
Using `callInvokeFunction` to test a contract invocation.
```
let url = URL(string: "http://localhost:40332")!
let neoSwift = NeoSwift.build(HttpService(url: url))

let scriptHash = try Hash160("0x1a70eac53f5882e40dd90f55463cce31a9f72cd4")
let function = "register"

let account = try Account.fromWIF("L3kCZj6QbFPwbsVhxnB8nUERDy4mhCSrWJew4u5Qh5QmGMfnCTda")
let domainParam = ContractParameter.string("myname.neo")
let accountParam = try ContractParameter.hash160(account.getScriptHash())

let response = try await SmartContract(scriptHash: scriptHash, neoSwift: neoSwift)
    .callInvokeFunction(function, [domainParam, accountParam], [AccountSigner.calledByEntry(account)])
```
#### Contract Interfaces
Deploying a `ContractManagement` contract.
```
let tx = try await ContractManagement(neoSwift)
    .deploy(nef, manifest)
    .signers(AccountSigner.calledByEntry(account))
    .sign()
```
---
### Token Contracts
[neow3j docs](https://neow3j.io/#/neo-n3/dapp_development/token_contracts)
#### Fungible Token Contracts (NEP-11)
Transferring from one account to another.
```
let account = try Account.fromWIF("L3kCZj6QbFPwbsVhxnB8nUERDy4mhCSrWJew4u5Qh5QmGMfnCTda")
let to = try Hash160.fromAddress("NWcx4EfYdfqn5jNjDz8AHE6hWtWdUGDdmy")

let response = try await NeoToken(neoSwift)
    .transfer(account, to, 15)
    .sign()
    .send()
```
Transferring using `Hash160` instead of an `Account`, manually adding the signers.
```
let to = try Hash160.fromAddress("NWcx4EfYdfqn5jNjDz8AHE6hWtWdUGDdmy")
            
// Owner of the contract. Required in for verifying the withdraw from the contract.
let account = try Account.fromWIF("L3kCZj6QbFPwbsVhxnB8nUERDy4mhCSrWJew4u5Qh5QmGMfnCTda")

let response = try await NeoToken(neoSwift)
    .transfer(contractHash, to, 15)
    .signers(AccountSigner.calledByEntry(account),
             ContractSigner.calledByEntry(contractHash))
    .sign()
    .send()
```
#### Non-fungible Token Contracts (NEP-11)
Sending 200 fractions of the token with ID 1.
```
let account = try Account.fromWIF("L3kCZj6QbFPwbsVhxnB8nUERDy4mhCSrWJew4u5Qh5QmGMfnCTda")
let to = try Hash160.fromAddress("NWcx4EfYdfqn5jNjDz8AHE6hWtWdUGDdmy")

let nft = try NonFungibleToken(scriptHash: Hash160("ebc856327332bcffb7587a28ef8d144df6be8537"), neoSwift: neoSwift)
let txBuilder = try await nft.transfer(account, to, 200, [1])
```

## Acknowledgements

The SDK was made possible with support from [GrantShares.](https://grantshares.io/)
