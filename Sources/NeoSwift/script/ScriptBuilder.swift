
import BigInt
import Foundation

public class ScriptBuilder {
    
    let writer = BinaryWriter()
    
    public init() {}
    
    public func opCode(_ opCodes: OpCode...) -> ScriptBuilder {
        opCodes.forEach { writer.writeByte($0.opcode) }
        return self
    }
    
    /// Appends OpCodes to the script in the order provided.
    /// - Parameters:
    ///   - opCode: The OpCodes to append
    ///   - argument: The argument of the OpCode
    /// - Returns: This ScriptBuilder object (self)
    public func opCode(_ opCode: OpCode, _ argument: Bytes) -> ScriptBuilder {
        writer.writeByte(opCode.opcode)
        writer.write(argument)
        return self
    }
    
    /// Appends a call to the contract denoted by the given script hash.
    /// - Parameters:
    ///   - hash160: The script hash of the contract to call
    ///   - method: The method to call
    ///   - params: The parameters that will be used in the call. Need to be in correct order
    ///   - callFlags: The call flags to use for the contract call
    /// - Returns: This ScriptBuilder object (self)
    public func contractCall(_ hash160: Hash160, method: String, params: [ContractParameter?], callFlags: CallFlags = .all) throws -> ScriptBuilder {
        _ = params.isEmpty ? opCode(.newArray0) : try pushParams(params)
        return try pushInteger(Int(callFlags.value))
            .pushData(method)
            .pushData(hash160.toLittleEndianArray())
            .sysCall(.systemContractCall)
    }
    
    public func sysCall(_ operation: InteropService) -> ScriptBuilder {
        _ = opCode(.sysCall)
        writer.write(operation.hash.bytesFromHex)
        return self
    }
    
    /// Adds the given contract parameters to the script.
    /// - Parameter params: The list of parameters to add
    /// - Returns: This ScriptBuilder object (self)
    public func pushParams(_ params: [ContractParameter?]) throws -> ScriptBuilder {
        try params.forEach { _ = try pushParam($0) }
        return try pushInteger(params.count).opCode(.pack)
    }
    
    public func pushParam(_ param: ContractParameter?) throws -> ScriptBuilder {
        guard let param = param, let value = param.value else {
            return opCode(.pushNull)
        }
        switch param.type {
        case .byteArray, .signature, .publicKey: return pushData(value as! Bytes)
        case .boolean: return pushBoolean(value as! Bool)
        case .integer:
            if let bInt = value as? BInt { return try pushInteger(bInt)}
            else { return try pushInteger(value as! Int) }
        case .hash160: return pushData((value as! Hash160).toLittleEndianArray())
        case .hash256: return pushData((value as! Hash256).toLittleEndianArray())
        case .string: return pushData(value as! String)
        case .array: return try pushArray(value as! [ContractParameter])
        case .map: return try pushMap(value as! [ContractParameter: ContractParameter])
        case .any: return self
        default: throw NeoSwiftError.illegalArgument("Parameter type '\(param.type.jsonValue)' not supported.")
        }
    }
    
    /// Adds a push operation with the given integer to the script. The integer is encoded in its two's complement and in little-endian order.
    ///
    /// The integer can be up to 32 bytes long.
    /// - Parameter i: The number to push
    /// - Returns: This ScriptBuilder object (self)
    public func pushInteger(_ i: BInt) throws -> ScriptBuilder {
        if i <= 16 && i >= -1 {
            return opCode(OpCode(rawValue: OpCode.push0.opcode + Byte(i.asInt()!))!)
        }
        let bytes: Bytes = i.asSignedBytes().reversed()
        if bytes.count == 1 { return opCode(.pushInt8, bytes) }
        else if bytes.count == 2 { return opCode(.pushInt16, bytes) }
        else if bytes.count <= 4 { return opCode(.pushInt32, padNumber(i, 4)) }
        else if bytes.count <= 8 { return opCode(.pushInt64, padNumber(i, 8)) }
        else if bytes.count <= 16 { return opCode(.pushInt128, padNumber(i, 16)) }
        else if bytes.count <= 32 { return opCode(.pushInt256, padNumber(i, 32)) }
        throw NeoSwiftError.illegalArgument("The given number (\(i)) is out of range.")
    }
    
    /// Adds a push operation with the given integer to the script. The integer is encoded in its two's complement and in little-endian order.
    ///
    /// The integer can be up to 32 bytes long.
    /// - Parameter i: The number to push
    /// - Returns: This ScriptBuilder object (self)
    public func pushInteger(_ i: Int) throws -> ScriptBuilder {
        return try pushInteger(BInt(i))
    }
    
    private func padNumber(_ v: BInt, _ length: Int) -> Bytes {
        let bytes = v.asSignedBytes()
        if bytes.count == length { return bytes }
        else if v.signum == -1 { return (Bytes(repeating: 255, count: length - bytes.count) + bytes).reversed() }
        return Bytes(bytes.reversed() + Bytes(repeating: 0, count: length - bytes.count))
    }
    
    /// Adds a push operation with the given boolean to the script.
    /// - Parameter bool: The boolean to push
    /// - Returns: This ScriptBuilder object (self)
    public func pushBoolean(_ bool: Bool) -> ScriptBuilder {
        return opCode(bool ? .push1 : .push0)
    }
    
    /// Adds the data to the script, prefixed with the correct code for its length.
    /// - Parameter data: The data to add to the script
    /// - Returns: This ScriptBuilder object (self)
    public func pushData(_ data: String) -> ScriptBuilder {
        return pushData(data.bytes)
    }
    
    /// Adds the data to the script, prefixed with the correct code for its length.
    /// - Parameter data: The data to add to the script
    /// - Returns: This ScriptBuilder object (self)
    public func pushData(_ data: Bytes) -> ScriptBuilder {
        if data.count < 256 {
            _ = opCode(.pushData1)
            writer.writeByte(Byte(data.count))
            writer.write(data)
        } else if data.count < 65536 {
            _ = opCode(.pushData2)
            writer.writeUInt16(UInt16(data.count))
            writer.write(data)
        } else {
            _ = opCode(.pushData4)
            writer.writeInt32(Int32(data.count))
            writer.write(data)
        }
        return self
    }
    
    public func pushArray(_ params: [ContractParameter]) throws -> ScriptBuilder {
        return params.isEmpty ? opCode(.newArray0) : try pushParams(params)
    }
    
    public func pushMap(_ map: [ContractParameter: ContractParameter]) throws -> ScriptBuilder {
        try map.forEach { k, v in
            _ = try pushParam(v)
            _ = try pushParam(k)
        }
        return try pushInteger(map.count).opCode(.packMap)
    }
    
    public func pack() -> ScriptBuilder {
        return opCode(.pack)
    }
    
    public func toArray() -> Bytes {
        return writer.toArray()
    }
    
    /// Builds a verification script for the given public key.
    /// - Parameter encodedPublicKey: The public key encoded in compressed format
    /// - Returns: The script
    public static func buildVerificationScript(_ encodedPublicKey: Bytes) -> Bytes {
        return ScriptBuilder().pushData(encodedPublicKey).sysCall(.systemCryptoCheckSig).toArray()
    }
    
    /// Builds a verification script for a multi signature account from the given public keys.
    /// - Parameters:
    ///   - pubKeys: The public keys
    ///   - signingThreshold: The desired minimum number of signatures required when using the multi-sig account
    /// - Returns: The script
    public static func buildVerificationScript(_ pubKeys: [ECPublicKey], _ signingThreshold: Int) throws -> Bytes {
        let builder = try ScriptBuilder().pushInteger(signingThreshold)
        try pubKeys.sorted().forEach { _ = builder.pushData(try $0.getEncoded(compressed: true)) }
        return try builder.pushInteger(pubKeys.count).sysCall(.systemCryptoCheckMultisig).toArray()
    }
    
    /// Calculates the script of the contract hash deployed by `sender`.
    ///
    /// A contract's hash doesn't change after deployment. Even if the contract's script is updated the hash stays the same.
    /// It depends on the initial NEF checksum, contract name, and the sender of the deployment transaction.
    /// - Parameters:
    ///   - sender: The account that deployed the contract
    ///   - nefCheckSum: The checksum of the contract's NEF file
    ///   - contractName: The contract's name
    /// - Returns: The bytes of the contract hash
    public static func buildContractHashScript(_ sender: Hash160, _ nefCheckSum: Int, _ contractName: String) throws -> Bytes {
        return try ScriptBuilder()
            .opCode(.abort).pushData(sender.toLittleEndianArray())
            .pushInteger(nefCheckSum).pushData(contractName).toArray()
    }
    
    /// Builds a script that calls a contract method with the provided parameters where the return value is expected to be an iterator.
    /// The iterator is then traversed and its values are added to an array.
    ///
    /// Use this to retrieve iterator values in interaction with an RPC server that has sessions disabled.
    ///
    /// Thanks to Anna Shaleva and Roman Khimov for the [implementation in neo-go](https://github.com/nspcc-dev/neo-go/blob/d4292ed5326e11aaa9fa53fe35459acd6a0e3239/pkg/smartcontract/entry.go#L21) on which this method is based on.
    /// - Parameters:
    ///   - contractHash: The script hash of the contract to call
    ///   - method: The method to call
    ///   - params: The parameters that will be used in the call. Need to be in correct order
    ///   - maxIteratorResultItems: The maximal number of iterator result items to include in the array. This value must not exceed NeoVM limits.
    ///   - callFlags: The call flags to use for the contract call
    /// - Returns: The script
    public static func buildContractCallAndUnwrapIterator(_ contractHash: Hash160, _ method: String, _ params: [ContractParameter],
                                                        _ maxIteratorResultItems: Int, _ callFlags: CallFlags = .all) throws -> Bytes {
        let b = try ScriptBuilder().pushInteger(maxIteratorResultItems)
        _ = try b.contractCall(contractHash, method: method, params: params, callFlags: callFlags)
            .opCode(.newArray0)
        
        let iteratorTraverseCycleStartOffset = b.writer.size
        _ = b.opCode(.over)
            .sysCall(.systemIteratorNext)
        
        let jmpIfNotOffset = b.writer.size
        _ = b.opCode(.jmpIfNot, [0x00])
        
        _ = b.opCode(.dup, .push2, .pick)
            .sysCall(.systemIteratorValue)
            .opCode(.append, .dup, .size, .push3, .pick, .ge)
        
        let jmpIfMaxReachedOffset = b.writer.size
        _ = b.opCode(.jmpIf, [0x00])
        
        let jmpOffset = b.writer.size
        let jmpBytesToCycleStart = BInt(iteratorTraverseCycleStartOffset - jmpOffset).asSignedBytes()[0]
        _ = b.opCode(.jmp, [jmpBytesToCycleStart])
        
        let loadResultOffset = b.writer.size
        _ = b.opCode(.nip, .nip)
        
        var bytes = b.toArray()
        bytes[jmpIfNotOffset + 1] = BInt(loadResultOffset - jmpIfNotOffset).asSignedBytes()[0]
        bytes[jmpIfMaxReachedOffset + 1] = BInt(loadResultOffset - jmpIfMaxReachedOffset).asSignedBytes()[0]
        
        return bytes
    }
    
}

