# NeoSwift
NeoSwift is a Swift SDK for interacting with the Neo blockchain from iOS and Mac devices. It is designed to have the same interface as the existing Java/Android SDK [neow3j.](https://github.com/neow3j/neow3j)

The SDK is currently under development with support from [GrantShares.](https://grantshares.io/)

## Usage
You can import NeoSwift into your project using Swift Package Manager in Xcode.

Go to File > Add Packages and search using the URL below.
```
https://github.com/crisogray/NeoSwift
```

Alternatively, if using `Package.swift`, you can add the package by adding the following line to the list of dependencies.
```
.package(url: “https://github.com/crisogray/NeoSwift”, from: “0.1.0”)
```
and add `”NeoSwift"` to the dependencies in your target.

## Completed Functionality: Stages 1 & 2

Although currently incomplete and in development, the SDK can be used as is for some lower-level functionality. 
Below is the extent of the completed functionality for stage 1.

*Cryptography*
* Key Generation
* Bip32 Key Creation/Derivation
* Message Signing and Signature Verification
* Key Recovery from Signature
* NEP 2 Password Encryption 
* WIF Encode/Decode

*Scripts*
* Binary Read/Write
* Script Builder/Reader
* Verification & Invocation Scripts
* Hash160/256 & Types

*Wallet*
* Account
* Wallet
* NEP6 Wallet
* BIP 39 Mnemonic Account

*Protocol*
* Requests and response handling
* HTTP/API connection
* Reactive (Using Swift Combine) subscription to blockchain

*Transaction*
* Signers (Account and Contract)
* Witnesses and witness scopes
* Serializable transaction object and transaction builder

## Remaining: Stage 3
* Contract: Token Types (e.g. NEO, NFT, GAS, Fungible), Contract classes
* In-code documentation
* Demo Swift playground
* Readme/overview documentation
