
import XCTest
@testable import NeoSwift

class RequestTests: XCTestCase {
    
    // MARK: Blockchain Methods
    
    public func testGetBestBlockHash() {
        let json = "{\"jsonrpc\":\"2.0\"," +
        "\"method\":\"getbestblockhash\"," +
        "\"id\":1," +
        "\"params\":[]}"
        
        verifyRequest(json, { neoSwift in
            return neoSwift.getBestBlockHash()
        })
    }
    
    public func testGetBlockHash() {
        let json = "{\"jsonrpc\":\"2.0\"," +
        "\"method\":\"getblockhash\"," +
        "\"id\":1," +
        "\"params\":[16293]}"
        
        verifyRequest(json, { neoSwift in
            return neoSwift.getBlockHash(16293)
        })
    }
    
    func testGetBlock_Index() {
        let json = "{\"jsonrpc\":\"2.0\"," +
        "\"method\":\"getblock\"," +
        "\"id\":1," +
        "\"params\":[12345,1]}"
        
        verifyRequest(json, { neoSwift in
            return neoSwift.getBlock(12345, true)
        })
    }
    
    func testGetBlock_Index_onlyHeader() {
        let json = "{\"jsonrpc\":\"2.0\"," +
        "\"method\":\"getblockheader\"," +
        "\"id\":1," +
        "\"params\":[12345,1]}"
        
        verifyRequest(json, { neoSwift in
            return neoSwift.getBlock(12345, false)
        })
    }
    
    func testGetBlock_Hash() {
        let json = "{\"jsonrpc\":\"2.0\"," +
        "\"method\":\"getblock\"," +
        "\"id\":1," +
        "\"params\":[\"2240b34669038f82ac492150d391dfc3d7fe5e3c1d34e5b547d50e99c09b468d\",1]}"
        
        verifyRequest(json, { neoSwift in
            return try! neoSwift.getBlock(Hash256("0x2240b34669038f82ac492150d391dfc3d7fe5e3c1d34e5b547d50e99c09b468d"), true)
        })
    }
    
    func testGetBlock_notFullTxObjects() {
        let json = "{\"jsonrpc\":\"2.0\"," +
        "\"method\":\"getblockheader\"," +
        "\"id\":1," +
        "\"params\":[\"2240b34669038f82ac492150d391dfc3d7fe5e3c1d34e5b547d50e99c09b468d\",1]}"
        
        verifyRequest(json, { neoSwift in
            return try! neoSwift.getBlock(Hash256("0x2240b34669038f82ac492150d391dfc3d7fe5e3c1d34e5b547d50e99c09b468d"), false)
        })
    }
    
    func testGetRawBlock_Index() {
        let json = "{\"jsonrpc\":\"2.0\"," +
        "\"method\":\"getblock\"," +
        "\"id\":1," +
        "\"params\":[12345,0]}"
        
        verifyRequest(json, { neoSwift in
            return neoSwift.getRawBlock(12345)
        })
    }
    
    func testGetBlockHeaderCount() {
        let json = "{\"jsonrpc\":\"2.0\"," +
        "\"method\":\"getblockheadercount\"," +
        "\"id\":1," +
        "\"params\":[]}"
        
        verifyRequest(json, { neoSwift in
            return neoSwift.getBlockHeaderCount()
        })
    }
    
    public func testGetBlockCount() {
        let json = "{\"jsonrpc\":\"2.0\"," +
        "\"method\":\"getblockcount\"," +
        "\"id\":1," +
        "\"params\":[]}"
        
        verifyRequest(json, { neoSwift in
            return neoSwift.getBlockCount()
        })
    }
    
    public func testGetNativeContracts() {
        let json = "{\"jsonrpc\":\"2.0\"," +
        "\"method\":\"getnativecontracts\"," +
        "\"id\":1," +
        "\"params\":[]}"
        
        verifyRequest(json, { neoSwift in
            return neoSwift.getNativeContracts()
        })
    }
    
    public func testGetBlockHeader_Index() {
        let json = "{\"jsonrpc\":\"2.0\"," +
        "\"method\":\"getblockheader\"," +
        "\"id\":1," +
        "\"params\":[12345,1]}"
        
        verifyRequest(json, { neoSwift in
            return neoSwift.getBlockHeader(12345)
        })
    }
    
    public func testGetRawBlockHeader_Index() {
        let json = "{\"jsonrpc\":\"2.0\"," +
        "\"method\":\"getblockheader\"," +
        "\"id\":1," +
        "\"params\":[12345,0]}"
        
        verifyRequest(json, { neoSwift in
            return neoSwift.getRawBlockHeader(12345)
        })
    }
    
    public func testGetContractState() {
        let json = "{\"jsonrpc\":\"2.0\"," +
        "\"method\":\"getcontractstate\"," +
        "\"id\":1," +
        "\"params\":[\"dc675afc61a7c0f7b3d2682bf6e1d8ed865a0e5f\"]}"
        
        verifyRequest(json, { neoSwift in
            return try! neoSwift.getContractState(Hash160("dc675afc61a7c0f7b3d2682bf6e1d8ed865a0e5f"))
        })
    }
    
    public func testGetContractState_byName() {
        let json = "{\"jsonrpc\":\"2.0\"," +
        "\"method\":\"getcontractstate\"," +
        "\"id\":1," +
        "\"params\":[\"NeoToken\"]}"
        
        verifyRequest(json, { neoSwift in
            return neoSwift.getNativeContractState("NeoToken")
        })
    }
    
    public func testGetMemPool() {
        let json = "{\"jsonrpc\":\"2.0\"," +
        "\"method\":\"getrawmempool\"," +
        "\"id\":1," +
        "\"params\":[1]}"
        
        verifyRequest(json, { neoSwift in
            return neoSwift.getMemPool()
        })
    }
    
    public func testGetRawMemPool() {
        let json = "{\"jsonrpc\":\"2.0\"," +
        "\"method\":\"getrawmempool\"," +
        "\"id\":1," +
        "\"params\":[]}"
        
        verifyRequest(json, { neoSwift in
            return neoSwift.getRawMemPool()
        })
    }
    
    public func testGetTransaction() {
        let json = "{\"jsonrpc\":\"2.0\"," +
        "\"method\":\"getrawtransaction\"," +
        "\"id\":1," +
        "\"params\":[\"1f31821787b0a53df0ff7d6e0e7ecba3ac19dd517d6d2ea5aaf00432c20831d6\",1]}"
        
        verifyRequest(json, { neoSwift in
            return try! neoSwift.getTransaction(Hash256("0x1f31821787b0a53df0ff7d6e0e7ecba3ac19dd517d6d2ea5aaf00432c20831d6"))
        })
    }
    
    public func testGetRawTransaction() {
        let json = "{\"jsonrpc\":\"2.0\"," +
        "\"method\":\"getrawtransaction\"," +
        "\"id\":1," +
        "\"params\":[\"1f31821787b0a53df0ff7d6e0e7ecba3ac19dd517d6d2ea5aaf00432c20831d6\",0]}"
        
        verifyRequest(json, { neoSwift in
            return try! neoSwift.getRawTransaction(Hash256("0x1f31821787b0a53df0ff7d6e0e7ecba3ac19dd517d6d2ea5aaf00432c20831d6"))
        })
    }
    
    public func testGetStorage() {
        let key = "616e797468696e67"
        let hash = try! Hash160("03febccf81ac85e3d795bc5cbd4e84e907812aa3")
        let json = "{\"jsonrpc\":\"2.0\"," +
        "\"method\":\"getstorage\"," +
        "\"id\":1," +
        "\"params\":[\"03febccf81ac85e3d795bc5cbd4e84e907812aa3\",\"" + key.base64Encoded + "\"]}"
        verifyRequest(json) { neoSwift in
            return neoSwift.getStorage(hash, key)
        }
    }
    
    public func testGetTransactionHeight() {
        let hash = try! Hash256("0x793f560ae7058a50c672890e69c9292391dd159ce963a33462059d03b9573d6a")
        let json = "{\"jsonrpc\":\"2.0\"," +
        "\"method\":\"gettransactionheight\"," +
        "\"id\":1," +
        "\"params\":[\"793f560ae7058a50c672890e69c9292391dd159ce963a33462059d03b9573d6a\"]}"
        verifyRequest(json) { neoSwift in
            return neoSwift.getTransactionHeight(hash)
        }
    }
    
    public func testGetNextBlockValidators() {
        let json = "{\"jsonrpc\":\"2.0\"," +
        "\"method\":\"getnextblockvalidators\"," +
        "\"id\":1," +
        "\"params\":[]}"
        
        verifyRequest(json, { neoSwift in
            return neoSwift.getNextBlockValidators()
        })
    }
    
    public func testGetCommittee() {
        let json = "{\"jsonrpc\":\"2.0\"," +
        "\"method\":\"getcommittee\"," +
        "\"id\":1," +
        "\"params\":[]}"
        
        verifyRequest(json, { neoSwift in
            return neoSwift.getCommittee()
        })
    }
    
    // MARK: Node Methods
    
    public func testGetConnectionCount() {
        let json = "{\"jsonrpc\":\"2.0\"," +
        "\"method\":\"getconnectioncount\"," +
        "\"id\":1," +
        "\"params\":[]}"
        
        verifyRequest(json, { neoSwift in
            return neoSwift.getConnectionCount()
        })
    }
    
    public func testGetPeers() {
        let json = "{\"jsonrpc\":\"2.0\"," +
        "\"method\":\"getpeers\"," +
        "\"id\":1," +
        "\"params\":[]}"
        
        verifyRequest(json, { neoSwift in
            return neoSwift.getPeers()
        })
    }
    
    public func testGetVersion() {
        let json = "{\"jsonrpc\":\"2.0\"," +
        "\"method\":\"getversion\"," +
        "\"id\":1," +
        "\"params\":[]}"
        
        verifyRequest(json, { neoSwift in
            return neoSwift.getVersion()
        })
    }
    
    public func testSendRawTransaction() {
        let json = "{\"jsonrpc\":\"2.0\"," +
        "\"method\":\"sendrawtransaction\"," +
        "\"id\":1," +
        "\"params\":[\"gAAAAdQFqwPnNqAconfZSxN3ETx+lhu0VQUR/h1AjzDHeoJlAAACm3z/2qZ0vq4Pkw6+YIWvkJPl/lazSlwiDM3Pbvwzb8UAypo7AAAAACO6JwPFMmPo1uUi3DIgMznc2O7pm3z/2qZ0vq4Pkw6+YIWvkJPl/lazSlwiDM3Pbvwzb8UAGnEYAgAAAClfg/g/xDn1bm4fsGLYnG9TgmPXAUFANxHjZvyZ53oRC2yWtfiCjvlWptXPpctjJzQZFJARsPMNxUWPqlnkhn0Kx1N+MkyYEku2kf7KXF3fbtIPStt3giMhAmW/kGvzhfvz93eDLlWoeZG8++GbCX+3xcouQCWk1eXWrA==\"]}"
        
        verifyRequest(json) { neoSwift in
            return neoSwift
                .sendRawTransaction("80000001d405ab03e736a01ca277d94b1377113c7e961bb4550511fe1d408f30c77a82650000029b7cffdaa674beae0f930ebe6085af9093e5fe56b34a5c220ccdcf6efc336fc500ca9a3b0000000023ba2703c53263e8d6e522dc32203339dcd8eee99b7cffdaa674beae0f930ebe6085af9093e5fe56b34a5c220ccdcf6efc336fc5001a711802000000295f83f83fc439f56e6e1fb062d89c6f538263d70141403711e366fc99e77a110b6c96b5f8828ef956a6d5cfa5cb63273419149011b0f30dc5458faa59e4867d0ac7537e324c98124bb691feca5c5ddf6ed20f4adb778223210265bf906bf385fbf3f777832e55a87991bcfbe19b097fb7c5ca2e4025a4d5e5d6ac")
                
        }
    }
    
    public func testSubmitBlock() {
        let json = "{\"jsonrpc\":\"2.0\"," +
        "\"method\":\"submitblock\"," +
        "\"id\":1," +
        "\"params\":[\"00000000000000000000000000000000\"]}"
        
        
        verifyRequest(json, { neoSwift in
            return neoSwift.submitBlock("00000000000000000000000000000000")
        })
    }
    
    // MARK: Smart Contract Methods
    
    public func testInvokeFunction() {
        let pubKey = try! ECPublicKey(defaultAccountPublicKey)
        let json = "{\"jsonrpc\":\"2.0\"," +
        "\"method\":\"invokefunction\"," +
        "\"id\":1," +
        "\"params\":[\"af7c7328eee5a275a3bcaee2bf0cf662b5e739be\",\"balanceOf\"," +
        "[{\"type\":\"Hash160\",\"value\":\"91b83e96f2a7c4fdf0c1688441ec61986c7cae26\"}]," +
        "[{\"allowedcontracts\":[\"ef4073a0f2b305a38ec4050e4d3d28bc40ea63f5\"]," +
        "\"account\":\"cadb3dc2faa3ef14a13b619c9a43124755aa2569\"," +
        "\"rules\":[{" +
        "\"condition\":{" +
        "\"type\":\"CalledByContract\"," +
        "\"hash\":\"" + neoTokenHash + "\"}," +
        "\"action\":\"Allow\"}]," +
        "\"allowedgroups" +
        "\":[\"033a4d051b04b7fc0230d2b1aaedfd5a84be279a5361a7358db665ad7857787f1b\"]," +
        "\"scopes\":\"CalledByEntry,CustomContracts,CustomGroups,WitnessRules\"" +
        "}]]}"
        
        verifyRequest(json) { neoSwift in
            return try! neoSwift.invokeFunction(
                Hash160("af7c7328eee5a275a3bcaee2bf0cf662b5e739be"),
                "balanceOf",
                [.hash160(Hash160("91b83e96f2a7c4fdf0c1688441ec61986c7cae26"))],
                [AccountSigner.calledByEntry(Hash160("0xcadb3dc2faa3ef14a13b619c9a43124755aa2569"))
                    .setAllowedContracts([Hash160(neoTokenHash)])
                    .setAllowedGroups([pubKey])
                    .setRules([.init(action: .allow, condition: .calledByContract(Hash160(neoTokenHash)))])
                ]
            )
        }
    }
    
    public func testInvokeFunction_witnessRules() {
        let json = "{\"jsonrpc\":\"2.0\"," +
        "\"method\":\"invokefunction\"," +
        "\"id\":1," +
        "\"params\":[\"af7c7328eee5a275a3bcaee2bf0cf662b5e739be\",\"balanceOf\"," +
        "[{\"type\":\"Hash160\",\"value\":\"91b83e96f2a7c4fdf0c1688441ec61986c7cae26\"}]," +
        "[{\"allowedcontracts\":[\"ef4073a0f2b305a38ec4050e4d3d28bc40ea63f5\"]," +
        "\"account\":\"cadb3dc2faa3ef14a13b619c9a43124755aa2569\"," +
        "\"rules\":[{" +
        "\"condition\":{" +
        "\"type\":\"And\"," +
        "\"expressions\":[{" +
        "\"type\":\"Boolean\"," +
        "\"expression\":true" +
        "},{" +
        "\"type\":\"CalledByContract\"," +
        "\"hash\":\"" + neoTokenHash + "\"" +
        "},{" +
        "\"type\":\"CalledByGroup\"," +
        "\"group\":\"" + defaultAccountPublicKey + "\"" +
        "},{" +
        "\"type\":\"Group\"," +
        "\"group\":\"" + defaultAccountPublicKey + "\"" +
        "}]}," +
        "\"action\":\"Deny\"" +
        "},{" +
        "\"condition\":{" +
        "\"type\":\"Or\"," +
        "\"expressions\":[" +
        "{\"type\":\"CalledByGroup\"," +
        "\"group\":\"" + defaultAccountPublicKey + "\"" +
        "},{" +
        "\"type\":\"ScriptHash\"," +
        "\"hash\":\"" + committeeAccountScriptHash + "\"" +
        "}]}," +
        "\"action\":\"Deny\"" +
        "},{" +
        "\"condition\":{" +
        "\"type\":\"Not\"," +
        "\"expression\":{" +
        "\"type\":\"CalledByEntry\"" +
        "}}," +
        "\"action\":\"Allow\"" +
        "}]," +
        "\"allowedgroups" +
        "\":[\"033a4d051b04b7fc0230d2b1aaedfd5a84be279a5361a7358db665ad7857787f1b\"]," +
        "\"scopes\":\"CalledByEntry,CustomContracts,CustomGroups,WitnessRules\"" +
        "}]]}"
        
        let pubKey = try! ECPublicKey(defaultAccountPublicKey)
        
        verifyRequest(json) { neoSwift in
            return try! neoSwift.invokeFunction(
                Hash160("af7c7328eee5a275a3bcaee2bf0cf662b5e739be"),
                "balanceOf",
                [.hash160(Hash160("91b83e96f2a7c4fdf0c1688441ec61986c7cae26"))],
                [AccountSigner.calledByEntry(Hash160("0xcadb3dc2faa3ef14a13b619c9a43124755aa2569"))
                    .setAllowedContracts([Hash160(neoTokenHash)])
                    .setAllowedGroups([pubKey])
                    .setRules([
                        .init(action: .deny, condition: .and([.boolean(true), .calledByContract(Hash160(neoTokenHash)), .calledByGroup(pubKey), .group(pubKey)])),
                        .init(action: .deny, condition: .or([.calledByGroup(pubKey), .scriptHash(Hash160(committeeAccountScriptHash))])),
                        .init(action: .allow, condition: .not(.calledByEntry))
                    ])
                ]
            )
        }
    }
    
    public func testInvokeFunctionDiagnostics() {
        let json = "{" +
        "\"jsonrpc\":\"2.0\"," +
        "\"method\":\"invokefunction\"," +
        "\"id\":1," +
        "\"params\":[" +
        "\"af7c7328eee5a275a3bcaee2bf0cf662b5e739be\"," +
        "\"balanceOf\"," +
        "[{" +
        "\"type\":\"Hash160\"," +
        "\"value\":\"91b83e96f2a7c4fdf0c1688441ec61986c7cae26\"" +
        "}]," +
        "[]," +
        "1" +
        "]}"
        
        verifyRequest(json, { neoSwift in
            return try! neoSwift.invokeFunctionDiagnostics(
                Hash160("af7c7328eee5a275a3bcaee2bf0cf662b5e739be"), "balanceOf",
                [.hash160(Hash160("91b83e96f2a7c4fdf0c1688441ec61986c7cae26"))])
        })
    }
    
    public func testInvokeFunctionDiagnostics_noParams() {
        let json = "{" +
        "\"jsonrpc\":\"2.0\"," +
        "\"method\":\"invokefunction\"," +
        "\"id\":1," +
        "\"params\":[" +
        "\"af7c7328eee5a275a3bcaee2bf0cf662b5e739be\"," +
        "\"symbol\"," +
        "[]," +
        "[]," +
        "1" +
        "]}"
        
        verifyRequest(json, { neoSwift in
            return try! neoSwift.invokeFunctionDiagnostics(
                Hash160("af7c7328eee5a275a3bcaee2bf0cf662b5e739be"), "symbol", [], [])
        })
        
    }
    
    public func testInvokeScript() {
        let json = "{\"jsonrpc\":\"2.0\"," +
        "\"method\":\"invokescript\"," +
        "\"id\":1," +
        "\"params\":[\"EMAMCGRlY2ltYWxzDBQlBZ7LSHjTqHX5HFHO3tMw1Fdf3kFifVtS\",[]]}"
        
        verifyRequest(json, { neoSwift in
            return neoSwift.invokeScript("10c00c08646563696d616c730c1425059ecb4878d3a875f91c51ceded330d4575fde41627d5b52")
        })
    }
    
    public func testInvokeScriptDiagnostics() {
        let json = "{\"jsonrpc\":\"2.0\"," +
        "\"method\":\"invokescript\"," +
        "\"id\":1," +
        "\"params\":[\"EMAMCGRlY2ltYWxzDBQlBZ7LSHjTqHX5HFHO3tMw1Fdf3kFifVtS\",[],1]}"
        
        verifyRequest(json, { neoSwift in
            return neoSwift.invokeScriptDiagnostics("10c00c08646563696d616c730c1425059ecb4878d3a875f91c51ceded330d4575fde41627d5b52")
        })
    }
    
    public func testInvokeScriptWithSigner() {
        let json = "{\"jsonrpc\":\"2.0\"," +
        "\"method\":\"invokescript\",\"id\":1," +
        "\"params\":[\"EMAMCGRlY2ltYWxzDBQlBZ7LSHjTqHX5HFHO3tMw1Fdf3kFifVtS\"," +
        "[{\"allowedcontracts\":[],\"account\":\"cc45cc8987b0e35371f5685431e3c8eeea306722\"," +
        "\"rules\":[],\"allowedgroups\":[],\"scopes\":\"CalledByEntry\"}]]}"
        
        verifyRequest(json, { neoSwift in
            return try! neoSwift.invokeScript("10c00c08646563696d616c730c1425059ecb4878d3a875f91c51ceded330d4575fde41627d5b52",
                                                 [AccountSigner.calledByEntry(Hash160("0xcc45cc8987b0e35371f5685431e3c8eeea306722"))])
        })
    }
    
    public func testInvokeScriptDiagnosticsWithSigner() {
        let json = "{" +
        "\"jsonrpc\":\"2.0\"," +
        "\"method\":\"invokescript\"," +
        "\"id\":1," +
        "\"params\":[" +
        "\"EMAMCGRlY2ltYWxzDBQlBZ7LSHjTqHX5HFHO3tMw1Fdf3kFifVtS\"," +
        "[{" +
        "\"allowedcontracts\":[]," +
        "\"account\":\"cc45cc8987b0e35371f5685431e3c8eeea306722\"," +
        "\"rules\":[]," +
        "\"allowedgroups\":[]," +
        "\"scopes\":\"CalledByEntry\"" +
        "}],1]}"
        
        verifyRequest(json, { neoSwift in
            return try! neoSwift.invokeScriptDiagnostics("10c00c08646563696d616c730c1425059ecb4878d3a875f91c51ceded330d4575fde41627d5b52",
                                                            [AccountSigner.calledByEntry(Hash160("0xcc45cc8987b0e35371f5685431e3c8eeea306722"))])
        })
        
    }
    
    public func testTraverseIterator() {
        let json = "{" +
        "\"jsonrpc\":\"2.0\"," +
        "\"method\":\"traverseiterator\"," +
        "\"id\":1," +
        "\"params\":[" +
        "\"127d3320-db35-48d5-b6d3-ca22dca4a370\"," +
        "\"cb7ef774-1ade-4a83-914b-94373ca92010\"," +
        "100" +
        "]}"
        
        verifyRequest(json, { neoSwift in
            return neoSwift.traverseIterator(
                "127d3320-db35-48d5-b6d3-ca22dca4a370",
                "cb7ef774-1ade-4a83-914b-94373ca92010",
                100
            )
        })
    }
    
    public func testTerminateSession() {
        let json = "{" +
        "\"jsonrpc\":\"2.0\"," +
        "\"method\":\"terminatesession\"," +
        "\"id\":1," +
        "\"params\":[" +
        "\"127d3320-db35-48d5-b6d3-ca22dca4a370\"" +
        "]}"
        
        verifyRequest(json, { neoSwift in
            return neoSwift.terminateSession("127d3320-db35-48d5-b6d3-ca22dca4a370")
        })
    }
    
    public func testInvokeContractVerify() {
        let json = "{\"jsonrpc\":\"2.0\"," +
        "\"method\":\"invokecontractverify\"," +
        "\"id\":1," +
        "\"params\":[\"af7c7328eee5a275a3bcaee2bf0cf662b5e739be\"," +
        "[{\"type\":\"String\",\"value\":\"a string\"}," +
        "{\"type\":\"String\",\"value\":\"another string\"}]," +
        "[{\"allowedcontracts\":[],\"account\":\"cadb3dc2faa3ef14a13b619c9a43124755aa2569\"," +
        "\"rules\":[],\"allowedgroups\":[],\"scopes\":\"CalledByEntry\"" +
        "}]]}"
        
        verifyRequest(json, { neoSwift in
            return try! neoSwift.invokeContractVerify(
                Hash160("af7c7328eee5a275a3bcaee2bf0cf662b5e739be"),
                [.string("a string"), .string("another string")],
                [AccountSigner.calledByEntry(Hash160("cadb3dc2faa3ef14a13b619c9a43124755aa2569"))])
        })
    }
    
    public func testInvokeContractVerifyNoParamsNoSigners() {
        let json = "{\"jsonrpc\":\"2.0\"," +
        "\"method\":\"invokecontractverify\"," +
        "\"id\":1," +
        "\"params\":[\"af7c7328eee5a275a3bcaee2bf0cf662b5e739be\",[],[]]}"
        
        verifyRequest(json, { neoSwift in
            return try! neoSwift.invokeContractVerify(Hash160("af7c7328eee5a275a3bcaee2bf0cf662b5e739be"))
        })
    }
    
    // MARK: Utilities Methods
    
    public func testListPlugins() {
        let json = "{\"jsonrpc\":\"2.0\"," +
        "\"method\":\"listplugins\"," +
        "\"id\":1," +
        "\"params\":[]}"
        
        
        verifyRequest(json, { neoSwift in
            return neoSwift.listPlugins()
        })
    }
    
    public func testValidateAddress() {
        let json = "{\"jsonrpc\":\"2.0\"," +
        "\"method\":\"validateaddress\"," +
        "\"id\":1," +
        "\"params\":[\"NTzVAPBpnUUCvrA6tFPxBHGge8Kyw8igxX\"]}"
        
        verifyRequest(json, { neoSwift in
            return neoSwift.validateAddress("NTzVAPBpnUUCvrA6tFPxBHGge8Kyw8igxX")
        })
    }
    
    // MARK: Wallet Methods
    
    public func testCloseWallet() {
        let json = "{\"jsonrpc\":\"2.0\"," +
        "\"method\":\"closewallet\"," +
        "\"id\":1," +
        "\"params\":[]}"
        
        verifyRequest(json, { neoSwift in
            return neoSwift.closeWallet()
        })
    }
    
    public func testOpenWallet() {
        let json = "{\"jsonrpc\":\"2.0\"," +
        "\"method\":\"openwallet\"," +
        "\"id\":1," +
        "\"params\":[\"wallet.json\",\"one\"]}"
        
        verifyRequest(json, { neoSwift in
            return neoSwift.openWallet("wallet.json", "one")
        })
    }
    
    public func testDumpPrivKey() {
        let json = "{\"jsonrpc\":\"2.0\"," +
        "\"method\":\"dumpprivkey\"," +
        "\"id\":1," +
        "\"params\":[\"NdWaiUoBWbPxGsm5wXPjXYJxCyuY1Zw8uW\"]}"
        
        verifyRequest(json, { neoSwift in
            return try! neoSwift.dumpPrivKey(Hash160("c11d816956b6682c3406bb99b7ec8a3e93f005c1"))
        })
    }
    
    public func testGetWalletBalance() {
        let json = "{\"jsonrpc\":\"2.0\"," +
        "\"method\":\"getwalletbalance\"," +
        "\"id\":1," +
        "\"params\":[\"de5f57d430d3dece511cf975a8d37848cb9e0525\"]}"
        
        verifyRequest(json, { neoSwift in
            return try! neoSwift.getWalletBalance(Hash160("de5f57d430d3dece511cf975a8d37848cb9e0525"))
        })
    }
    
    public func testGetNewAddress() {
        let json = "{\"jsonrpc\":\"2.0\"," +
        "\"method\":\"getnewaddress\"," +
        "\"id\":1," +
        "\"params\":[]}"
        
        verifyRequest(json, { neoSwift in
            return neoSwift.getNewAddress()
        })
    }
    
    public func testGetWalletUnclaimedGas() {
        let json = "{\"jsonrpc\":\"2.0\"," +
        "\"method\":\"getwalletunclaimedgas\"," +
        "\"id\":1," +
        "\"params\":[]}"
        
        verifyRequest(json, { neoSwift in
            return neoSwift.getWalletUnclaimedGas()
        })
    }
    
    public func testGetUnclaimedGas() {
        let json = "{\"jsonrpc\":\"2.0\"," +
        "\"method\":\"getunclaimedgas\"," +
        "\"id\":1," +
        "\"params\":[\"NaQ6Kj6qYinh1frv1wrn53wbPFe5BH5T7g\"]}"
        
        verifyRequest(json, { neoSwift in
            return try! neoSwift.getUnclaimedGas(Hash160("ffa6adbb5f82ad2a1aafa22ce6aaf05dad5de39e"))
        })
    }
    
    public func testImportPrivKey() {
        let json = "{\"jsonrpc\":\"2.0\"," +
        "\"method\":\"importprivkey\"," +
        "\"id\":1," +
        "\"params\":[\"L5c6jz6Rh8arFJW3A5vg7Suaggo28ApXVF2EPzkAXbm94ThqaA6r\"]}"
        
        verifyRequest(json, { neoSwift in
            return neoSwift.importPrivKey("L5c6jz6Rh8arFJW3A5vg7Suaggo28ApXVF2EPzkAXbm94ThqaA6r")
        })
    }
    
    public func testCalculateNetworkFee() {
        let json = "{\"jsonrpc\":\"2.0\"," +
        "\"method\":\"calculatenetworkfee\"," +
        "\"id\":1," +
        "\"params\":[\"bmVvdzNq\"]}"
        
        verifyRequest(json, { neoSwift in
            return neoSwift.calculateNetworkFee("6e656f77336a")
        })
    }
    
    public func testListAddress() {
        let json = "{\"jsonrpc\":\"2.0\"," +
        "\"method\":\"listaddress\"," +
        "\"id\":1," +
        "\"params\":[]}"
        
        verifyRequest(json, { neoSwift in
            return neoSwift.listAddress()
        })
    }
    
    public func testSendFrom() {
        let json = "{\"jsonrpc\":\"2.0\"," +
        "\"method\":\"sendfrom\"," +
        "\"id\":1," +
        "\"params\":[\"de5f57d430d3dece511cf975a8d37848cb9e0525\"," +
        "\"NaxePjypvtsQ5GVi6S1jBsSjXribTSUKRu\"," +
        "\"NbD6be5uYezFZRSBDt6aBfYR9bYsAk8Yui\"," +
        "10]}"
        
        verifyRequest(json, { neoSwift in
            return try! neoSwift.sendFrom(
                Hash160("0xde5f57d430d3dece511cf975a8d37848cb9e0525"),
                Hash160("8cdb257b8873049918fe5a1e7f6289f75d720ba5"),
                Hash160("db1acbae4dbae55f8325724cf080ed782925c7a7"), 10)
        })
        
    }
    
    public func testSendFrom_TransactionSendAsset() {
        let json = "{\"jsonrpc\":\"2.0\"," +
        "\"method\":\"sendfrom\"," +
        "\"id\":1," +
        "\"params\":[\"de5f57d430d3dece511cf975a8d37848cb9e0525\"," +
        "\"Ng9E3D4DpM6JrgSxizhanJ6zm6BjvZ2XkM\"," +
        "\"NUokBS9rfH8qncwFdfByBTT9yJjxQv8h2h\"," +
        "10" +
        "]}"
        
        verifyRequest(json, { neoSwift in
            return try! neoSwift.sendFrom(Hash160("44b159ceed1bfbd753748227309428f54f52e4dd"),
                                             TransactionSendToken(token: Hash160("0xde5f57d430d3dece511cf975a8d37848cb9e0525"),
                                                                  value: 10, address: "NUokBS9rfH8qncwFdfByBTT9yJjxQv8h2h"))
        })
    }
    
    public func testSendMany() {
        let json = "{\"jsonrpc\":\"2.0\"," +
        "\"method\":\"sendmany\"," +
        "\"id\":1," +
        "\"params\":[" +
        "[{\"asset\":\"de5f57d430d3dece511cf975a8d37848cb9e0525\",\"value\":100,\"address\":\"NRkkHsxkzFxGz77mJtJgYZ3FnBm8baU5Um\"}," +
        "{\"asset\":\"de5f57d430d3dece511cf975a8d37848cb9e0525\",\"value\":10,\"address\":\"NNFGNNK1HXSSnA7yKLzRpr8YXwcdgTrsCu\"}]" +
        "]}"
        
        verifyRequest(json, { neoSwift in
            return try! neoSwift.sendMany([
                TransactionSendToken(token: Hash160("0xde5f57d430d3dece511cf975a8d37848cb9e0525"),
                                     value: 100, address: "NRkkHsxkzFxGz77mJtJgYZ3FnBm8baU5Um"),
                TransactionSendToken(token: Hash160("0xde5f57d430d3dece511cf975a8d37848cb9e0525"),
                                     value: 10, address: "NNFGNNK1HXSSnA7yKLzRpr8YXwcdgTrsCu")
            ])
        })
        
    }
    
    public func testSendMany_Empty_Transaction() {
        let json = "{\"jsonrpc\":\"2.0\"," +
        "\"method\":\"sendmany\"," +
        "\"id\":1," +
        "\"params\":[[]]}"
        
        verifyRequest(json, { neoSwift in
            return neoSwift.sendMany([])
        })
    }
    
    public func testSendManyWithFrom() {
        let json = "{\"jsonrpc\":\"2.0\"," +
        "\"method\":\"sendmany\"," +
        "\"id\":1," +
        "\"params\":[\"NiVNRW6cBXwkvrZnetZToaHPGSSGgV1HmA\"," +
        "[{" +
        "\"asset\":\"de5f57d430d3dece511cf975a8d37848cb9e0525\"," +
        "\"value\":100," +
        "\"address\":\"Nhsi2q3hkByxcH2uBQw7cjc2qEpzXSEKTC\"" +
        "},{" +
        "\"asset\":\"de5f57d430d3dece511cf975a8d37848cb9e0525\"," +
        "\"value\":10," +
        "\"address\":\"NcwVWxJZh9fxncJ9Sq8msVLotJDsAD3ZD8\"}" +
        "]]" +
        "}"
        
        verifyRequest(json, { neoSwift in
            return try! neoSwift.sendMany(
                .fromAddress("NiVNRW6cBXwkvrZnetZToaHPGSSGgV1HmA"),
                [TransactionSendToken(token: Hash160("0xde5f57d430d3dece511cf975a8d37848cb9e0525"),
                                      value: 100, address: "Nhsi2q3hkByxcH2uBQw7cjc2qEpzXSEKTC"),
                 TransactionSendToken(token: Hash160("0xde5f57d430d3dece511cf975a8d37848cb9e0525"),
                                      value: 10, address: "NcwVWxJZh9fxncJ9Sq8msVLotJDsAD3ZD8")]
            )
        })
    }
    
    public func testSendToAddress() {
        let json = "{\"jsonrpc\":\"2.0\"," +
        "\"method\":\"sendtoaddress\"," +
        "\"id\":1," +
        "\"params\":[\"de5f57d430d3dece511cf975a8d37848cb9e0525\"," +
        "\"NRCcuUUxKCa3sp45o7bjXetyxUeq58T4ED\"," +
        "10" +
        "]}"
        
        verifyRequest(json, { neoSwift in
            return try! neoSwift.sendToAddress(Hash160("0xde5f57d430d3dece511cf975a8d37848cb9e0525"),
                                                  Hash160("674231bd321880fc5c4a73994c87870e52c5fe39"), 10)
        })
    }
    
    public func testSendToAddress_TransactionSendAsset() {
        let json = "{\"jsonrpc\":\"2.0\"," +
        "\"method\":\"sendtoaddress\"," +
        "\"id\":1," +
        "\"params\":[\"de5f57d430d3dece511cf975a8d37848cb9e0525\"," +
        "\"NaCsFrmoJepqCJSxnTyb41CXVSjr3dMjuL\"," +
        "10" +
        "]}"
        
        verifyRequest(json, { neoSwift in
            return try! neoSwift.sendToAddress(TransactionSendToken(token: Hash160("0xde5f57d430d3dece511cf975a8d37848cb9e0525"),
                                                                       value: 10, address: "NaCsFrmoJepqCJSxnTyb41CXVSjr3dMjuL"))
        })
    }
    
    // MARK: Nep17
    
    public func testGetNep17Transfers() {
        let json = "{\"jsonrpc\":\"2.0\"," +
        "\"method\":\"getnep17transfers\"," +
        "\"id\":1," +
        "\"params\":[\"NekZLTu93WgrdFHxzBEJUYgLTQMAT85GLi\"]}"
        
        verifyRequest(json, { neoSwift in
            return try! neoSwift.getNep17Transfers(Hash160("04457ce4219e462146ac00b09793f81bc5bca2ce"))
        })
    }
    
    public func testGetNep17Transfers_Date() {
        let json = "{\"jsonrpc\":\"2.0\"," +
        "\"method\":\"getnep17transfers\"," +
        "\"id\":1," +
        "\"params\":[\"NekZLTu93WgrdFHxzBEJUYgLTQMAT85GLi\",1553105830]}"
        
        verifyRequest(json, { neoSwift in
            return try! neoSwift.getNep17Transfers(Hash160("04457ce4219e462146ac00b09793f81bc5bca2ce"),
                                                      Date(timeIntervalSince1970: 1553105830 / 1000))
        })
    }
    
    public func testGetNep17Transfers_DateFromTo() {
        let json = "{\"jsonrpc\":\"2.0\"," +
        "\"method\":\"getnep17transfers\"," +
        "\"id\":1," +
        "\"params\":[\"NekZLTu93WgrdFHxzBEJUYgLTQMAT85GLi\",1553105830,1557305830]}"
        
        verifyRequest(json, { neoSwift in
            return try! neoSwift.getNep17Transfers(Hash160("04457ce4219e462146ac00b09793f81bc5bca2ce"),
                                                      Date(timeIntervalSince1970: 1553105830 / 1000),
                                                      Date(timeIntervalSince1970: 1557305830 / 1000))
        })
    }
    
    public func testGetNep17Balances() {
        let json = "{\"jsonrpc\":\"2.0\"," +
        "\"method\":\"getnep17balances\"," +
        "\"id\":1," +
        "\"params\":[\"NY9zhKwcmht5cQJ3oRqjJGo3QuVLwXwTzL\"]}"
        
        verifyRequest(json, { neoSwift in
            return try! neoSwift.getNep17Balances(Hash160("5d75775015b024970bfeacf7c6ab1b0ade974886"))
        })
    }
    
    // MARK: ApplicationLogs
    
    public func testGetApplicationLog() {
        let json = "{\"jsonrpc\":\"2.0\"," +
        "\"method\":\"getapplicationlog\"," +
        "\"id\":1," +
        "\"params\":[\"420d1eb458c707d698c6d2ba0f91327918ddb3b7bae2944df070f3f4e579078b\"]}"
        
        verifyRequest(json, { neoSwift in
            return try! neoSwift.getApplicationLog(Hash256("420d1eb458c707d698c6d2ba0f91327918ddb3b7bae2944df070f3f4e579078b"))
        })
    }
    
    // MARK: StateService
    
    public func testGetStateRoot() {
        let json = "{\"jsonrpc\":\"2.0\"," +
        "\"method\":\"getstateroot\"," +
        "\"id\":1," +
        "\"params\":[52]}"
        
        verifyRequest(json, { neoSwift in
            return neoSwift.getStateRoot(52)
        })
    }
    
    public func testGetProof() {
        let json = "{\"jsonrpc\":\"2.0\"," +
        "\"method\":\"getproof\"," +
        "\"id\":1," +
        "\"params\":[" +
        "\"7bf925dbd33af0e00d392b92313da59369ed86c82494d0e02040b24faac0a3ca\"," +
        "\"79bcd398505eb779df6e67e4be6c14cded08e2f2\"," +
        "\"YW55dGhpbmc=\"" +
        "]}"
        
        verifyRequest(json, { neoSwift in
            return try! neoSwift.getProof(
                Hash256("0x7bf925dbd33af0e00d392b92313da59369ed86c82494d0e02040b24faac0a3ca"),
                Hash160("0x79bcd398505eb779df6e67e4be6c14cded08e2f2"),
                "616e797468696e67"
            )
        })
    }
    
    public func testVerifyProof() {
        let json = "{\"jsonrpc\":\"2.0\"," +
        "\"method\":\"verifyproof\"," +
        "\"id\":1," +
        "\"params\":[" +
        "\"7bf925dbd33af0e00d392b92313da59369ed86c82494d0e02040b24faac0a3ca\"," +
        "\"Bfv///8XBiQBAQ8DRzb6Vkdw0r5nxMBp6Z5nvbyXiupMvffwm0v5GdB6jHvyAAQEBAQEBAQEA7l84HFtRI5V11s58vA+8CZ5GArFLkGUYLO98RLaMaYmA5MEnx0upnVI45XTpoUDRvwrlPD59uWy9aIrdS4T0D2cA6Rwv/l3GmrctRzL1me+iTUFdDgooaz+esFHFXJdDANfA2bdshZMp5ox2goVAOMjvoxNIWWOqjJoRPu6ZOw2kdj6A8xovEK1Mp6cAG9z/jfFDrSEM60kuo97MNaVOP/cDZ1wA1nf4WdI+jksYz0EJgzBukK8rEzz8jE2cb2Zx2fytVyQBANC7v2RaLMCRF1XgLpSri12L2IwL9Zcjz5LZiaB5nHKNgQpAQYPDw8PDw8DggFffnsVMyqAfZjg+4gu97N/gKpOsAK8Q27s56tijRlSAAMm26DYxOdf/IjEgkE/u/CoRL6dDnzvs1dxCg/00esMvgPGioeOqQCkDOTfliOnCxYjbY/0XvVUOXkceuDm1W0FzQQEBAQEBAQEBAQEBAQEBJIABAPH1PnX/P8NOgV4KHnogwD7xIsD8KvNhkTcDxgCo7Ec6gPQs1zD4igSJB4M9jTREq+7lQ5PbTH/6d138yUVvtM8bQP9Df1kh7asXrYjZolKhLcQ1NoClQgEzbcJfYkCHXv6DQQEBAOUw9zNl/7FJrWD7rCv0mbOoy6nLlHWiWuyGsA12ohRuAQEBAQEBAQEBAYCBAIAAgA=\"" +
        "]}"
        
        verifyRequest(json, { neoSwift in
            return try! neoSwift.verifyProof(Hash256("0x7bf925dbd33af0e00d392b92313da59369ed86c82494d0e02040b24faac0a3ca"),
                                                "05fbffffff17062401010f034736fa564770d2be67c4c069e99e67bdbc978aea4cbdf7f09b4bf919d07a8c7bf200040404040404040403b97ce0716d448e55d75b39f2f03ef02679180ac52e419460b3bdf112da31a6260393049f1d2ea67548e395d3a6850346fc2b94f0f9f6e5b2f5a22b752e13d03d9c03a470bff9771a6adcb51ccbd667be893505743828a1acfe7ac14715725d0c035f0366ddb2164ca79a31da0a1500e323be8c4d21658eaa326844fbba64ec3691d8fa03cc68bc42b5329e9c006f73fe37c50eb48433ad24ba8f7b30d69538ffdc0d9d700359dfe16748fa392c633d04260cc1ba42bcac4cf3f2313671bd99c767f2b55c90040342eefd9168b302445d5780ba52ae2d762f62302fd65c8f3e4b662681e671ca36042901060f0f0f0f0f0f0382015f7e7b15332a807d98e0fb882ef7b37f80aa4eb002bc436eece7ab628d1952000326dba0d8c4e75ffc88c482413fbbf0a844be9d0e7cefb357710a0ff4d1eb0cbe03c68a878ea900a40ce4df9623a70b16236d8ff45ef55439791c7ae0e6d56d05cd04040404040404040404040404040492000403c7d4f9d7fcff0d3a05782879e88300fbc48b03f0abcd8644dc0f1802a3b11cea03d0b35cc3e22812241e0cf634d112afbb950e4f6d31ffe9dd77f32515bed33c6d03fd0dfd6487b6ac5eb62366894a84b710d4da02950804cdb7097d89021d7bfa0d0404040394c3dccd97fec526b583eeb0afd266cea32ea72e51d6896bb21ac035da8851b804040404040404040406020402000200"
            )
        })
    }
    
    public func testGetStateHeight() {
        let json = "{\"jsonrpc\":\"2.0\"," +
        "\"method\":\"getstateheight\"," +
        "\"id\":1," +
        "\"params\":[]}"
        
        verifyRequest(json, { neoSwift in
            return neoSwift.getStateHeight()
        })
    }
    
    public func testGetState() {
        let json = "{\"jsonrpc\":\"2.0\"," +
        "\"method\":\"getstate\"," +
        "\"id\":1," +
        "\"params\":[" +
        "\"7bf925dbd33af0e00d392b92313da59369ed86c82494d0e02040b24faac0a3ca\"," +
        "\"7c5832ba81fd0af40ec11e96b1c26613466dae02\"," +
        "\"QQEhB4DRxWFfeRI=\"" +
        "]}"
        
        verifyRequest(json, { neoSwift in
            return try! neoSwift.getState(Hash256("0x7bf925dbd33af0e00d392b92313da59369ed86c82494d0e02040b24faac0a3ca"),
                                             Hash160("7c5832ba81fd0af40ec11e96b1c26613466dae02"), "4101210780d1c5615f7912")
        })
    }
    
    public func testFindStates() {
        let json = "{\"jsonrpc\":\"2.0\"," +
        "\"method\":\"findstates\"," +
        "\"id\":1," +
        "\"params\":[" +
        "\"76d6bddf6d9b5979d532877f0617bf31abd03d663c73357dfb2e2417a287b09f\"," +
        "\"d2a4cff31913016155e38e474a2c06d08be276cf\"," +
        "\"C/4=\"," +
        "\"Cw==\"," +
        "2" +
        "]}"
        
        verifyRequest(json, { neoSwift in
            return try! neoSwift.findStates(Hash256("0x76d6bddf6d9b5979d532877f0617bf31abd03d663c73357dfb2e2417a287b09f"),
                                               Hash160("0xd2a4cff31913016155e38e474a2c06d08be276cf"),
                                               "0bfe",
                                               "0b",
                                               2)
        })
    }
    
    public func testFindStates_noCount() {
        let json = "{\"jsonrpc\":\"2.0\"," +
        "\"method\":\"findstates\"," +
        "\"id\":1," +
        "\"params\":[" +
        "\"76d6bddf6d9b5979d532877f0617bf31abd03d663c73357dfb2e2417a287b09f\"," +
        "\"d2a4cff31913016155e38e474a2c06d08be276cf\"," +
        "\"C/4=\"," +
        "\"Cw==\"]}"
        
        verifyRequest(json, { neoSwift in
            return try! neoSwift.findStates(Hash256("0x76d6bddf6d9b5979d532877f0617bf31abd03d663c73357dfb2e2417a287b09f"),
                                               Hash160("0xd2a4cff31913016155e38e474a2c06d08be276cf"),
                                               "0bfe", "0b")
        })
    }
    
    public func testFindStates_noStartKey_withCount() {
        let json = "{\"jsonrpc\":\"2.0\"," +
        "\"method\":\"findstates\"," +
        "\"id\":1," +
        "\"params\":[" +
        "\"76d6bddf6d9b5979d532877f0617bf31abd03d663c73357dfb2e2417a287b09f\"," +
        "\"d2a4cff31913016155e38e474a2c06d08be276cf\"," +
        "\"C/4=\"," +
        "\"\"," +
        "53]}"
        
        verifyRequest(json, { neoSwift in
            return try! neoSwift.findStates(Hash256("0x76d6bddf6d9b5979d532877f0617bf31abd03d663c73357dfb2e2417a287b09f"),
                                               Hash160("0xd2a4cff31913016155e38e474a2c06d08be276cf"),
                                               "0bfe", 53)
        })
    }
    
    public func testFindStates_noStartKey() {
        let json = "{\"jsonrpc\":\"2.0\"," +
        "\"method\":\"findstates\"," +
        "\"id\":1," +
        "\"params\":[" +
        "\"76d6bddf6d9b5979d532877f0617bf31abd03d663c73357dfb2e2417a287b09f\"," +
        "\"d2a4cff31913016155e38e474a2c06d08be276cf\"," +
        "\"C/4=\"]}"
        
        verifyRequest(json, { neoSwift in
            return try! neoSwift.findStates(Hash256("0x76d6bddf6d9b5979d532877f0617bf31abd03d663c73357dfb2e2417a287b09f"),
                                               Hash160("0xd2a4cff31913016155e38e474a2c06d08be276cf"),
                                               "0bfe")
        })
    }
    
    // MARK: Neo-express related tests
    
    public func testExpressGetPopulatedBlocks() {
        let json = "{" +
        "\"jsonrpc\":\"2.0\"," +
        "\"method\":\"expressgetpopulatedblocks\"," +
        "\"id\":1," +
        "\"params\":[]}"

        verifyExpressRequest(json, { neoSwiftExpress in
            return neoSwiftExpress.expressGetPopulatedBlocks()
        })
    }
    
    public func testExpressGetNep17Contracts() {
        let json = "{" +
        "\"jsonrpc\":\"2.0\"," +
        "\"method\":\"expressgetnep17contracts\"," +
        "\"id\":1," +
        "\"params\":[]}"

        verifyExpressRequest(json, { neoSwiftExpress in
            return neoSwiftExpress.expressGetNep17Contracts()
        })
    }
    
    public func testExpressGetContractStorage() {
        let json = "{" +
        "\"jsonrpc\":\"2.0\"," +
        "\"method\":\"expressgetcontractstorage\"," +
        "\"id\":1," +
        "\"params\":[\"d2a4cff31913016155e38e474a2c06d08be276cf\"]}"

        verifyExpressRequest(json, { neoSwiftExpress in
            return try! neoSwiftExpress.expressGetContractStorage(Hash160("0xd2a4cff31913016155e38e474a2c06d08be276cf"))
        })
    }
    
    public func testExpressListContracts() {
        let json = "{" +
        "\"jsonrpc\":\"2.0\"," +
        "\"method\":\"expresslistcontracts\"," +
        "\"id\":1," +
        "\"params\":[]}"

        verifyExpressRequest(json, { neoSwiftExpress in
            return neoSwiftExpress.expressListContracts()
        })
    }
    
    
    public func testExpressCreateCheckpoint() {
        let json = "{" +
        "\"jsonrpc\":\"2.0\"," +
        "\"method\":\"expresscreatecheckpoint\"," +
        "\"id\":1," +
        "\"params\":[\"checkpoint-1.neoxp-checkpoint\"]}"

        verifyExpressRequest(json, { neoSwiftExpress in
            return neoSwiftExpress.expressCreateCheckpoint("checkpoint-1.neoxp-checkpoint")
        })
    }
    
    public func testExpressListOracleRequests() {
        let json = "{" +
        "\"jsonrpc\":\"2.0\"," +
        "\"method\":\"expresslistoraclerequests\"," +
        "\"id\":1," +
        "\"params\":[]}"

        verifyExpressRequest(json, { neoSwiftExpress in
            return neoSwiftExpress.expressListOracleRequests()
        })
    }
    
    public func testExpressCreateOracleResponseTx() {
        let json = "{" +
        "\"jsonrpc\":\"2.0\"," +
        "\"method\":\"expresscreateoracleresponsetx\"," +
        "\"id\":1," +
        "\"params\":[{\"id\":3,\"result\":\"bmVvdzNq\",\"code\":\"Success\"}]}"

        verifyExpressRequest(json, { neoSwiftExpress in
            return neoSwiftExpress.expressCreateOracleResponseTx(.oracleResponse(3, .success, "bmVvdzNq"))
        })
    }
    
    public func testExpressShutdown() {
        let json = "{" +
        "\"jsonrpc\":\"2.0\"," +
        "\"method\":\"expressshutdown\"," +
        "\"id\":1," +
        "\"params\":[]}"

        verifyExpressRequest(json, { neoSwiftExpress in
            return neoSwiftExpress.expressShutdown()
        })
    }
    
    // MARK: Nep11
    
    public func testGetNep11Balances() {
        let json = "{\"jsonrpc\":\"2.0\"," +
        "\"method\":\"getnep11balances\"," +
        "\"id\":1," +
        "\"params\":[\"NY9zhKwcmht5cQJ3oRqjJGo3QuVLwXwTzL\"]}"
        
        verifyRequest(json, { neoSwift in
            return try! neoSwift.getNep11Balances(Hash160("5d75775015b024970bfeacf7c6ab1b0ade974886"))
        })
    }
    
    public func testGetNep11Transfers() {
        let json = "{\"jsonrpc\":\"2.0\"," +
        "\"method\":\"getnep11transfers\"," +
        "\"id\":1," +
        "\"params\":[\"NekZLTu93WgrdFHxzBEJUYgLTQMAT85GLi\"]}"
        
        verifyRequest(json, { neoSwift in
            return try! neoSwift.getNep11Transfers(Hash160("04457ce4219e462146ac00b09793f81bc5bca2ce"))
        })
    }
    
    public func testGetNep11Transfers_Date() {
        let json = "{\"jsonrpc\":\"2.0\"," +
        "\"method\":\"getnep11transfers\"," +
        "\"id\":1," +
        "\"params\":[\"NSH1UeM96PKhjuzVBKcyWeNNuQkT3sHGmA\",1553105830]}"
        
        verifyRequest(json, { neoSwift in
            return try! neoSwift.getNep11Transfers(Hash160("8bed27d0e88266807a6339270f0593510967cb45"),
                                                      Date(timeIntervalSince1970: 1553105830 / 1000))
        })
    }
    
    public func testGetNep11Transfers_DateFromTo() {
        let json = "{\"jsonrpc\":\"2.0\"," +
        "\"method\":\"getnep11transfers\"," +
        "\"id\":1," +
        "\"params\":[\"NSH1UeM96PKhjuzVBKcyWeNNuQkT3sHGmA\",1553105830,1557305830]}"
        
        verifyRequest(json, { neoSwift in
            return try! neoSwift.getNep11Transfers(Hash160("8bed27d0e88266807a6339270f0593510967cb45"),
                                                      Date(timeIntervalSince1970: 1553105830 / 1000),
                                                      Date(timeIntervalSince1970: 1557305830 / 1000))
        })
    }
    
    public func testGetNep11Properties() {
        let json = "{\"jsonrpc\":\"2.0\"," +
        "\"method\":\"getnep11properties\"," +
        "\"id\":1," +
        "\"params\":[\"NfWL3Kx7qtZzXrajmggAD4b6r2kGzajbaJ\",\"12345\"]}"
        
        verifyRequest(json, { neoSwift in
            return try! neoSwift.getNep11Properties(Hash160("2eeda865e7824c71b3fe14bed35d04d0f2f0e9d6"),"12345")
        })
    }
    
    private func verifyRequest<T: Response<U>, U>(_ expected: String, _ makeRequest: (NeoSwift) throws -> Request<T, U>) {
        let mockUrlSession = MockURLSession().requestInterceptor { request in
            guard let body = request.httpBody else {
                return XCTFail("No request body")
            }
            XCTAssertEqual(String(data: body, encoding: .ascii)!, expected)
        }
        let httpService = HttpService(urlSession: mockUrlSession)
        let neoSwift = NeoSwift.build(httpService)
        NeoSwiftConfig.REQUEST_COUNTER.reset()
        let request = try! makeRequest(neoSwift)
        performRequest(request)
    }
    
    private func verifyExpressRequest<T: Response<U>, U>(_ expected: String, _ makeRequest: (NeoSwiftExpress) throws -> Request<T, U>) {
        let mockUrlSession = MockURLSession().requestInterceptor { request in
            guard let body = request.httpBody else {
                return XCTFail("No request body")
            }
            XCTAssertEqual(String(data: body, encoding: .ascii)!, expected)
        }
        let httpService = HttpService(urlSession: mockUrlSession)
        let neoSwift: NeoSwiftExpress = NeoSwiftExpress.build(httpService)
        NeoSwiftConfig.REQUEST_COUNTER.reset()
        let request = try! makeRequest(neoSwift)
        performRequest(request)
    }
    
    public func performRequest<T: Response<U>, U>(_ request: Request<T, U>) {
        let semaphore = DispatchSemaphore(value: 0)
        Task {
            _ = try! await request.send()
            semaphore.signal()
        }
        semaphore.wait()
    }
    
}
