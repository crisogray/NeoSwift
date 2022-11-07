
import Foundation

public enum OpCode: Byte, CaseIterable {
    
    // MARK: Constants
    
    case pushInt8 = 0x00, pushInt16 = 0x01, pushInt32 = 0x02, pushInt64 = 0x03, pushInt128 = 0x04, pushInt256 = 0x05
    case pushA = 0x0A, pushNull = 0x0B, pushData1 = 0x0C, pushData2 = 0x0D, pushData4 = 0x0E, pushM1 = 0x0F
    case push0 = 0x10, push1 = 0x11, push2 = 0x12, push3 = 0x13, push4 = 0x14, push5 = 0x15
    case push6 = 0x16, push7 = 0x17, push8 = 0x18, push9 = 0x19, push10 = 0x1A, push11 = 0x1B
    case push12 = 0x1C, push13 = 0x1D, push14 = 0x1E, push15 = 0x1F, push16 = 0x20
    
    // MARK: Flow Control
    
    case nop = 0x21, jmp = 0x22, jmp_l = 0x23, jmpIf = 0x24, jmpIf_l = 0x25, jmpIfNot = 0x26, jmpIfNot_l = 0x27
    case jmpEq = 0x28, jmpEq_l = 0x29, jmpNe = 0x2A, jmpNe_l = 0x2B
    case jmpGt = 0x2C, jmpGt_l = 0x2D, jmpGe = 0x2E, jmpGe_l = 0x2F
    case jmpLt = 0x30, jmpLt_l = 0x31, jmpLe = 0x32, jmpLe_l = 0x33
    case call = 0x34, call_l = 0x35, callA = 0x36, callT = 0x37
    case abort = 0x38, assert = 0x39, _throw = 0x3A, _try = 0x3B, try_l = 0x3C
    case endTry = 0x3D, endTry_l = 0x3E, endFinally = 0x3F, ret = 0x40, syscall = 0x41
    
    // MARK: Stack
    
    case depth = 0x43, drop = 0x45, nip = 0x46, xdrop = 0x48, clear = 0x49
    case dup = 0x4A, over = 0x4B, pick = 0x4D, tuck = 0x4E
    case swap = 0x50, rot = 0x51, roll = 0x52, reverse3 = 0x53, reverse4 = 0x54, reverseN = 0x55
    
    // MARK: Slot
    
    case initSSlot = 0x56, initSlot = 0x57
    case ldSFld0 = 0x58, ldSFld1 = 0x59, ldSFld2 = 0x5A, ldSFld3 = 0x5B
    case ldSFld4 = 0x5C, ldSFld5 = 0x5D, ldSFld6 = 0x5E, ldSFld = 0x5F
    case stSFld0 = 0x60, stSFld1 = 0x61, stSFld2 = 0x62, stSFld3 = 0x63
    case stSFld4 = 0x64, stSFld5 = 0x65, stSFld6 = 0x66, stSFld = 0x67
    case ldLoc0 = 0x68, ldLoc1 = 0x69, ldLoc2 = 0x6A, ldLoc3 = 0x6B
    case ldLoc4 = 0x6C, ldLoc5 = 0x6D, ldLoc6 = 0x6E, ldLoc = 0x6F
    case stLoc0 = 0x70, stLoc1 = 0x71, stLoc2 = 0x72, stLoc3 = 0x73
    case stLoc4 = 0x74, stLoc5 = 0x75, stLoc6 = 0x76, stLoc = 0x77
    case ldArg0 = 0x78, ldArg1 = 0x79, ldArg2 = 0x7A, ldArg3 = 0x7B
    case ldArg4 = 0x7C, ldArg5 = 0x7D, ldArg6 = 0x7E, ldArg = 0x7F
    case stArg0 = 0x80, stArg1 = 0x81, stArg2 = 0x82, stArg3 = 0x83
    case stArg4 = 0x84, stArg5 = 0x85, stArg6 = 0x86, stArg = 0x87
    
    // MARK: Splice
    
    case newBuffer = 0x88, memCpy = 0x89, cat = 0x8B, substr = 0x8C, left = 0x8D, right = 0x8E
    
    // MARK: Bitwise Logic
    
    case invert = 0x90, and = 0x91, or = 0x92, xor = 0x93, equal = 0x97, notEqual = 0x98
    
    // MARK: Arithmetic
    
    case sign = 0x99, abs = 0x9A, negate = 0x9B, inc = 0x9C, dec = 0x9D
    case add = 0x9E, sub = 0x9F, mul = 0xA0, div = 0xA1, mod = 0xA2
    case pow = 0xA3, sqrt = 0xA4, modMul = 0xA5, modPow = 0xA6, shL = 0xA8, shR = 0xA9
    case not = 0xAA, boolAnd = 0xAB, boolOr = 0xAC, nz = 0xB1, numEqual = 0xB3, numNotEqual = 0xB4
    case lt = 0xB5, le = 0xB6, gt = 0xB7, ge = 0xB8, min = 0xB9, max = 0xBA, within = 0xBB
    
    // MARK: Compound-Type
    
    case packMap = 0xBE, packStruct = 0xBF, pack = 0xC0, unpack  = 0xC1
    case newArray0 = 0xC2, newArray = 0xC3, newArray_t = 0xC4, newStruct0 = 0xC5, newStruct = 0xC6, newMap = 0xC8
    case size = 0xCA, hasKey = 0xCB, keys = 0xCC, values = 0xCD, pickItem = 0xCE, append = 0xCF
    case setItem = 0xD0, reverseItems = 0xD1, remove = 0xD2, clearItems = 0xD3
    
    // MARK: Types
    
    case isNull = 0xD8, isType = 0xD9, convert = 0xDB
    
    
    public var opcode: Byte {
        return rawValue
    }
    
    public var price: Int {
        switch self {
        case .pushInt8, .pushInt16, .pushInt32, .pushInt64, .pushNull,
                .pushM1, .push0, .push1, .push2, .push3, .push4, .push5,
                .push6, .push7, .push8, .push9, .push10, .push11, .push12,
                .push13, .push14, .push15, .push16, .nop, .assert:
            return 1
        case .pushInt128, .pushInt256, .pushA, ._try,
                .endTry, .endTry_l, .endFinally, .invert,
                .sign, .abs, .negate, .inc, .dec, .not, .nz,
                .size:
            return 1 << 2
        case .pushData1, .and, .or, .xor, .add, .sub, .mul, .div, .mod,
                .shL, .shR, .boolAnd, .boolOr, .numEqual, .numNotEqual,
                .lt, .le, .gt, .ge, .min, .max, .within, .newMap:
            return 1 << 3
        case .xdrop, .clear, .roll, .reverseN, .initSSlot,
                .newArray0, .newStruct0, .keys, .remove, .clearItems:
            return 1 << 4
        case .equal, .notEqual, .modMul:
            return 1 << 5
        case .initSlot, .pow, .hasKey, .pickItem:
            return 1 << 6
        case .newBuffer:
            return 1 << 8
        case .pushData2, .call, .call_l, .callA, ._throw,
                .newArray, .newArray_t, .newStruct:
            return 1 << 9
        case .memCpy, .cat, .substr, .left, .right, .sqrt, .modPow,
                .packMap, .packStruct, .pack, .unpack:
            return 1 << 11
        case .pushData4:
            return 1 << 12
        case .values, .append, .setItem, .reverseItems, .convert:
            return 1 << 13
        case .callT:
            return 1 << 15
        case .abort, .ret, .syscall:
            return 0
        default: return 1 << 1
        }
    }
    
    public var operandSize: OperandSize? {
        switch self {
        case .pushInt8,
                .jmp, .jmpIf, .jmpIfNot, .jmpEq, .jmpNe,
                .jmpGt, .jmpGe, .jmpLt, .jmpLe, .call, .endTry,
                .initSSlot, .ldSFld, .stSFld, .ldLoc, .stLoc, .ldArg, .stArg,
                .newArray_t, .isType, .convert:
            return .withSize(1)
        case .pushInt16, .callT, ._try, .initSlot:
            return .withSize(2)
        case .pushInt32, .pushA,
                .jmp_l, .jmpIf_l, .jmpIfNot_l, .jmpEq_l, .jmpNe_l,
                .jmpGt_l, .jmpGe_l, .jmpLt_l, .jmpLe_l, .call_l,
                .endTry_l, .syscall:
            return .withSize(4)
        case .pushInt64, .try_l:
            return .withSize(8)
        case .pushInt128:
            return .withSize(16)
        case .pushInt256:
            return .withSize(32)
        case .pushData1:
            return .withPrefixSize(1)
        case .pushData2:
            return .withPrefixSize(2)
        case .pushData4:
            return .withPrefixSize(4)
        default: return nil
        }
    }
    
    public struct OperandSize {
        public var prefixSize: Int = 0
        public var size: Int = 0
        
        public static func withSize(_ s: Int) -> OperandSize {
            return OperandSize(size: s)
        }
        
        public static func withPrefixSize(_ pS: Int) -> OperandSize {
            return OperandSize(prefixSize: pS)
        }
        
        public static func withPrefixSizeAndSize(_ pS: Int, _ s: Int) -> OperandSize {
            return OperandSize(prefixSize: pS, size: s)
        }
        
    }
    
}
