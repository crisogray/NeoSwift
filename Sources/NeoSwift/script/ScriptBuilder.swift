
import BigInt
import Foundation

public class ScriptBuilder {
    
    let writer = BinaryWriter()
    
    public init() {}
    
    public func opCode(_ opCodes: OpCode...) -> ScriptBuilder {
        opCodes.forEach { writer.writeByte($0.opcode) }
        return self
    }
    
    public func opCode(_ opCode: OpCode, _ argument: Bytes) -> ScriptBuilder {
        writer.writeByte(opCode.opcode)
        writer.write(argument)
        return self
    }
    
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
    
    public func pushInteger(_ i: Int) throws -> ScriptBuilder {
        return try pushInteger(BInt(i))
    }
    
    public func padNumber(_ v: BInt, _ length: Int) -> Bytes {
        let bytes = v.asSignedBytes()
        if bytes.count == length { return bytes }
        else if v.signum == -1 { return (Bytes(repeating: 255, count: length - bytes.count) + bytes).reversed() }
        return Bytes(bytes.reversed() + Bytes(repeating: 0, count: length - bytes.count))
    }
    
    public func pushBoolean(_ bool: Bool) -> ScriptBuilder {
        return opCode(bool ? .push1 : .push0)
    }
    
    public func pushData(_ data: String) -> ScriptBuilder {
        return pushData(data.bytes)
    }
    
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
    
    public static func buildVerificationScript(_ encodedPublicKey: Bytes) -> Bytes {
        return ScriptBuilder().pushData(encodedPublicKey).sysCall(.systemCryptoCheckSig).toArray()
    }
    
    public static func buildVerificationScript(_ pubKeys: [ECPublicKey], _ signingThreshold: Int) throws -> Bytes {
        let builder = try ScriptBuilder().pushInteger(signingThreshold)
        try pubKeys.sorted().forEach { _ = builder.pushData(try $0.getEncoded(compressed: true)) }
        return try builder.pushInteger(pubKeys.count).sysCall(.systemCryptoCheckMultisig).toArray()
    }
    
    public static func buildContractHashScript(_ sender: Hash160, _ nefCheckSum: Int, _ contractName: String) throws -> Bytes {
        return try ScriptBuilder()
            .opCode(.abort).pushData(sender.toLittleEndianArray())
            .pushInteger(nefCheckSum).pushData(contractName).toArray()
    }
        
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
        let jmpBytesToCycleStart = Byte(iteratorTraverseCycleStartOffset - jmpOffset)
        _ = b.opCode(.jmp, [jmpBytesToCycleStart])
        
        let loadResultOffset = b.writer.size
        _ = b.opCode(.nip, .nip)
        
        var bytes = b.toArray()
        bytes[jmpIfNotOffset + 1] = Byte(loadResultOffset - jmpIfNotOffset)
        bytes[jmpIfMaxReachedOffset + 1] = Byte(loadResultOffset - jmpIfMaxReachedOffset)
        
        return bytes
    }
    
}

