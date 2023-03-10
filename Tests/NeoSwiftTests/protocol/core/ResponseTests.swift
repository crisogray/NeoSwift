
import XCTest
@testable import NeoSwift

class ResponseTests: XCTestCase {
    
    public func testErrorResponse() {
        let json = """
{
    "jsonrpc": "2.0",
    "id": 1,
    "error": {
        "code": -32602,
        "message": "Invalid address length, expected 40 got 64 bytes",
        "data": null
    }
}
"""
        let ethBlock = decodeJson(NeoBlockCount.self, from: json)
        XCTAssert(ethBlock.hasError)
        XCTAssertEqual(ethBlock.error, .init(code: -32602, message: "Invalid address length, expected 40 got 64 bytes"))
    }
    
    public func testComplexErrorResponse() {
        let json = """
{
    "jsonrpc": "2.0",
    "id": 1,
    "error": {
        "code": -32602,
        "message": "Invalid address length, expected 40 got 64 bytes",
        "data": {
            "foo": "bar"
        }
    }
}
"""
        let ethBlock = decodeJson(NeoBlockCount.self, from: json)
        XCTAssert(ethBlock.hasError)
        XCTAssertEqual(ethBlock.error?.data, "{\"foo\":\"bar\"}"
        )
    }
    
    // MARK: Blockchain Methods
    
    public func testGetBestBlockHash() {
        let json = """
{
    "jsonrpc": "2.0",
    "id": 1,
    "result": "0x3d1e051247f246f60dd2ba4f90f799578b5d394157b1f2b012c016b29536b899"
}
"""
        let block = decodeJson(NeoBlockHash.self, from: json)
        XCTAssertEqual(block.blockHash, try! Hash256("0x3d1e051247f246f60dd2ba4f90f799578b5d394157b1f2b012c016b29536b899"))
    }
    
    public func testGetBlockHash() {
        let json = """
{
    "jsonrpc": "2.0",
    "id": 1,
    "result": "0x147ad6a26f1d5a9bb2bea3f0b2ca9fab3824873beaf8887e87d08c8fd98a81b3"
}
"""
        let block = decodeJson(NeoBlockHash.self, from: json)
        XCTAssertEqual(block.blockHash, try! Hash256("0x147ad6a26f1d5a9bb2bea3f0b2ca9fab3824873beaf8887e87d08c8fd98a81b3"))
    }
    
    public func testGetBlock() {
        let json = """
{
    "jsonrpc": "2.0",
    "id": 1,
    "result": {
        "hash": "0x1de7e5eaab0f74ac38f5191c038e009d3c93ef5c392d1d66fa95ab164ba308b8",
        "size": 1217,
        "version": 0,
        "previousblockhash": "0x045cabde4ecbd50f5e4e1b141eaf0842c1f5f56517324c8dcab8ccac924e3a39",
        "merkleroot": "0x6afa63201b88b55ad2213e5a69a1ad5f0db650bc178fc2bedd2fb301c1278bf7",
        "time": 1539968858,
        "index": 1914006,
        "nextconsensus": "AWZo4qAxhT8fwKL93QATSjCYCgHmCY1XLB",
        "witnesses": [
            {
                "invocation": "DEBJVWapboNkCDlH9uu+tStOgGnwODlolRifxTvQiBkhM0vplSPo4vMj9Jt3jvzztMlwmO75Ss5cptL8wUMxASjZ",
                "verification": "EQwhA/HsPB4oPogN5unEifDyfBkAfFM4WqpMDJF8MgB57a3yEQtBMHOzuw=="
            }
        ],
        "tx": [
            {
                "hash": "0x46eca609a9a8c8340ee56b174b04bc9c9f37c89771c3a8998dc043f5a74ad510",
                "size": 267,
                "version": 0,
                "nonce": 565086327,
                "sender": "AHE5cLhX5NjGB5R2PcdUvGudUoGUBDeHX4",
                "sysfee": "0",
                "netfee": "0",
                "validuntilblock": 2107425,
                "signers": [
                    {
                        "account": "0xf68f181731a47036a99f04dad90043a744edec0f",
                        "scopes": "CalledByEntry"
                    }
                ],
                "attributes": [],
                "script": "AGQMFObBATZUrxE9ipaL3KUsmUioK5U9DBQP7O1Ep0MA2doEn6k2cKQxFxiP9hPADAh0cmFuc2ZlcgwUiXcg2M129PAKv6N8Dt2InCCP3ptBYn1bUjg",
                "witnesses": [
                    {
                        "invocation": "DEBR7EQOb1NUjat1wrINzBNKOQtXoUmRVZU8h5c8K5CLMCUVcGkFVqAAGUJDh3mVcz6sTgXvmMuujWYrBveeM4q+",
                        "verification": "EQwhA/HsPB4oPogN5unEifDyfBkAfFM4WqpMDJF8MgB57a3yEQtBMHOzuw=="
                    }
                ]
            },
            {
                "hash": "0x46eca609a9a8c8340ee56b174b04bc9c9f37c89771c3a8998dc043f5a74ad510",
                "size": 267,
                "version": 0,
                "nonce": 565086327,
                "sender": "AHE5cLhX5NjGB5R2PcdUvGudUoGUBDeHX4",
                "sysfee": "0",
                "netfee": "0",
                "validuntilblock": 2107425,
                "signers": [
                    {
                        "account": "0xf68f181731a47036a99f04dad90043a744edec0f",
                        "scopes": "CalledByEntry"
                    }
                ],
                "attributes": [],
                "script": "AGQMFObBATZUrxE9ipaL3KUsmUioK5U9DBQP7O1Ep0MA2doEn6k2cKQxFxiP9hPADAh0cmFuc2ZlcgwUiXcg2M129PAKv6N8Dt2InCCP3ptBYn1bUjg",
                "witnesses": [
                    {
                        "invocation": "DEBR7EQOb1NUjat1wrINzBNKOQtXoUmRVZU8h5c8K5CLMCUVcGkFVqAAGUJDh3mVcz6sTgXvmMuujWYrBveeM4q+",
                        "verification": "EQwhA/HsPB4oPogN5unEifDyfBkAfFM4WqpMDJF8MgB57a3yEQtBMHOzuw=="
                    }
                ]
            }
        ],
        "confirmations": 7878,
        "nextblockhash": "0x4a97ca89199627f877b6bffe865b8327be84b368d62572ef20953829c3501643"
    }
}
"""
        let getBlock = decodeJson(NeoGetBlock.self, from: json)
        XCTAssertEqual(getBlock.block?.hash, try! Hash256("0x1de7e5eaab0f74ac38f5191c038e009d3c93ef5c392d1d66fa95ab164ba308b8"))
        XCTAssertEqual(getBlock.block?.size, 1217)
        XCTAssertEqual(getBlock.block?.version, 0)
        XCTAssertEqual(getBlock.block?.prevBlockHash, try! Hash256("0x045cabde4ecbd50f5e4e1b141eaf0842c1f5f56517324c8dcab8ccac924e3a39"))
        XCTAssertEqual(getBlock.block?.merkleRootHash, try! Hash256("0x6afa63201b88b55ad2213e5a69a1ad5f0db650bc178fc2bedd2fb301c1278bf7"))
        XCTAssertEqual(getBlock.block?.time, 1539968858)
        XCTAssertEqual(getBlock.block?.index, 1914006)
        XCTAssertEqual(getBlock.block?.nextConsensus, "AWZo4qAxhT8fwKL93QATSjCYCgHmCY1XLB")
        XCTAssertEqual(getBlock.block?.version, 0)
        
        XCTAssertEqual(getBlock.block?.witnesses?.count, 1)
        XCTAssert(getBlock.block?.witnesses?.contains(NeoWitness(
            "DEBJVWapboNkCDlH9uu+tStOgGnwODlolRifxTvQiBkhM0vplSPo4vMj9Jt3jvzztMlwmO75Ss5cptL8wUMxASjZ",
            "EQwhA/HsPB4oPogN5unEifDyfBkAfFM4WqpMDJF8MgB57a3yEQtBMHOzuw=="
        )) ?? false)
        
        XCTAssertEqual(getBlock.block?.transactions?.count, 2)
        let transactions = [
            Transaction(
                hash: try! Hash256("0x46eca609a9a8c8340ee56b174b04bc9c9f37c89771c3a8998dc043f5a74ad510"),
                size: 267,
                version: 0,
                nonce: 565086327,
                sender: "AHE5cLhX5NjGB5R2PcdUvGudUoGUBDeHX4",
                sysFee: "0",
                netFee: "0",
                validUntilBlock: 2107425,
                signers: [TransactionSigner(try!  Hash160("0xf68f181731a47036a99f04dad90043a744edec0f"), [.calledByEntry])],
                attributes: [],
                script: "AGQMFObBATZUrxE9ipaL3KUsmUioK5U9DBQP7O1Ep0MA2doEn6k2cKQxFxiP9hPADAh0cmFuc2ZlcgwUiXcg2M129PAKv6N8Dt2InCCP3ptBYn1bUjg",
                witnesses: [NeoWitness(
                    "DEBR7EQOb1NUjat1wrINzBNKOQtXoUmRVZU8h5c8K5CLMCUVcGkFVqAAGUJDh3mVcz6sTgXvmMuujWYrBveeM4q+",
                    "EQwhA/HsPB4oPogN5unEifDyfBkAfFM4WqpMDJF8MgB57a3yEQtBMHOzuw=="
                )]
            ),
            Transaction(
                hash: try! Hash256("0x46eca609a9a8c8340ee56b174b04bc9c9f37c89771c3a8998dc043f5a74ad510"),
                size: 267,
                version: 0,
                nonce: 565086327,
                sender: "AHE5cLhX5NjGB5R2PcdUvGudUoGUBDeHX4",
                sysFee: "0",
                netFee: "0",
                validUntilBlock: 2107425,
                signers: [TransactionSigner(try! Hash160("0xf68f181731a47036a99f04dad90043a744edec0f"), [.calledByEntry])],
                attributes: [],
                script: "AGQMFObBATZUrxE9ipaL3KUsmUioK5U9DBQP7O1Ep0MA2doEn6k2cKQxFxiP9hPADAh0cmFuc2ZlcgwUiXcg2M129PAKv6N8Dt2InCCP3ptBYn1bUjg",
                witnesses: [NeoWitness(
                    "DEBR7EQOb1NUjat1wrINzBNKOQtXoUmRVZU8h5c8K5CLMCUVcGkFVqAAGUJDh3mVcz6sTgXvmMuujWYrBveeM4q+",
                    "EQwhA/HsPB4oPogN5unEifDyfBkAfFM4WqpMDJF8MgB57a3yEQtBMHOzuw=="
                )]
            )
        ]
        transactions.forEach {
            XCTAssert(getBlock.block?.transactions?.contains($0) ?? false)
        }
        
        XCTAssertEqual(getBlock.block?.confirmations, 7878)
        XCTAssertEqual(getBlock.block?.nextBlockHash, try! Hash256("0x4a97ca89199627f877b6bffe865b8327be84b368d62572ef20953829c3501643"))
    }
    
    public func testGetBlockBlockHeader() {
        let json = """
{
    "jsonrpc": "2.0",
    "id": 1,
    "result": {
        "hash": "0x1de7e5eaab0f74ac38f5191c038e009d3c93ef5c392d1d66fa95ab164ba308b8",
        "size": 1217,
        "version": 0,
        "previousblockhash": "0x045cabde4ecbd50f5e4e1b141eaf0842c1f5f56517324c8dcab8ccac924e3a39",
        "merkleroot": "0x6afa63201b88b55ad2213e5a69a1ad5f0db650bc178fc2bedd2fb301c1278bf7",
        "time": 1539968858,
        "index": 1914006,
        "nextconsensus": "AWZo4qAxhT8fwKL93QATSjCYCgHmCY1XLB",
        "witnesses": [
            {
                "invocation": "DEBJVWapboNkCDlH9uu+tStOgGnwODlolRifxTvQiBkhM0vplSPo4vMj9Jt3jvzztMlwmO75Ss5cptL8wUMxASjZ",
                "verification": "EQwhA/HsPB4oPogN5unEifDyfBkAfFM4WqpMDJF8MgB57a3yEQtBMHOzuw=="
            }
        ],
        "confirmations": 7878,
        "nextblockhash": "0x4a97ca89199627f877b6bffe865b8327be84b368d62572ef20953829c3501643"
    }
}
"""
        let getBlock = decodeJson(NeoGetBlock.self, from: json)
        XCTAssertEqual(getBlock.block?.hash, try! Hash256("0x1de7e5eaab0f74ac38f5191c038e009d3c93ef5c392d1d66fa95ab164ba308b8"))
        XCTAssertEqual(getBlock.block?.size, 1217)
        XCTAssertEqual(getBlock.block?.version, 0)
        XCTAssertEqual(getBlock.block?.prevBlockHash, try! Hash256("0x045cabde4ecbd50f5e4e1b141eaf0842c1f5f56517324c8dcab8ccac924e3a39"))
        XCTAssertEqual(getBlock.block?.merkleRootHash, try! Hash256("0x6afa63201b88b55ad2213e5a69a1ad5f0db650bc178fc2bedd2fb301c1278bf7"))
        XCTAssertEqual(getBlock.block?.time, 1539968858)
        XCTAssertEqual(getBlock.block?.index, 1914006)
        XCTAssertEqual(getBlock.block?.nextConsensus, "AWZo4qAxhT8fwKL93QATSjCYCgHmCY1XLB")
        
        XCTAssertEqual(getBlock.block?.witnesses?.count, 1)
        XCTAssert(getBlock.block?.witnesses?.contains(NeoWitness(
            "DEBJVWapboNkCDlH9uu+tStOgGnwODlolRifxTvQiBkhM0vplSPo4vMj9Jt3jvzztMlwmO75Ss5cptL8wUMxASjZ",
            "EQwhA/HsPB4oPogN5unEifDyfBkAfFM4WqpMDJF8MgB57a3yEQtBMHOzuw=="
        )) ?? false)
        
        XCTAssertNil(getBlock.block?.transactions)
        
        XCTAssertEqual(getBlock.block?.confirmations, 7878)
        XCTAssertEqual(getBlock.block?.nextBlockHash, try! Hash256("0x4a97ca89199627f877b6bffe865b8327be84b368d62572ef20953829c3501643"))
    }
    
    public func testGetRawBlock() {
        let json = """
{
    "jsonrpc": "2.0",
    "id": 67,
    "result": "00000000ebaa4ed893333db1ed556bb24145f4e7fe40b9c7c07ff2235c7d3d361ddb27e603da9da4c7420d090d0e29c588cfd701b3f81819375e537c634bd779ddc7e2e2c436cc5ba53f00001952d428256ad0cdbe48d3a3f5d10013ab9ffee489706078714f1ea201c340c44387d762d1bcb2ab0ec650628c7c674021f333ee7666e2a03805ad86df3b826b5dbf5ac607a361807a047d43cf6bba726dcb06a42662aee7e78886c72faef940e6cef9abab82e1e90c6683ac8241b3bf51a10c908f01465f19c3df1099ef5de5d43a648a6e4ab63cc7d5e88146bddbe950e8041e44a2b0b81f21ad706e88258540fd19314f46ad452b4cbedf58bf9d266c0c808374cd33ef18d9a0575b01e47f6bb04abe76036619787c457c49288aeb91ff23cdb85771c0209db184801d5bdd348b532102103a7f7dd016558597f7960d27c516a4394fd968b9e65155eb4b013e4040406e2102a7bc55fe8684e0119768d104ba30795bdcc86619e864add26156723ed185cd622102b3622bf4017bdfe317c58aed5f4c753f206b7db896046fa7d774bbc4bf7f8dc22103d90c07df63e690ce77912e10ab51acc944b66860237b608c4f8f8309e71ee69954ae0100001952d42800000000"
}
"""
        let rawBlock = decodeJson(NeoGetRawBlock.self, from: json)
        XCTAssertEqual(rawBlock.rawBlock,
                       "00000000ebaa4ed893333db1ed556bb24145f4e7fe40b9c7c07ff2235c7d3d361ddb27e603da9da4c7420d090d0e29c588cfd701b3f81819375e537c634bd779ddc7e2e2c436cc5ba53f00001952d428256ad0cdbe48d3a3f5d10013ab9ffee489706078714f1ea201c340c44387d762d1bcb2ab0ec650628c7c674021f333ee7666e2a03805ad86df3b826b5dbf5ac607a361807a047d43cf6bba726dcb06a42662aee7e78886c72faef940e6cef9abab82e1e90c6683ac8241b3bf51a10c908f01465f19c3df1099ef5de5d43a648a6e4ab63cc7d5e88146bddbe950e8041e44a2b0b81f21ad706e88258540fd19314f46ad452b4cbedf58bf9d266c0c808374cd33ef18d9a0575b01e47f6bb04abe76036619787c457c49288aeb91ff23cdb85771c0209db184801d5bdd348b532102103a7f7dd016558597f7960d27c516a4394fd968b9e65155eb4b013e4040406e2102a7bc55fe8684e0119768d104ba30795bdcc86619e864add26156723ed185cd622102b3622bf4017bdfe317c58aed5f4c753f206b7db896046fa7d774bbc4bf7f8dc22103d90c07df63e690ce77912e10ab51acc944b66860237b608c4f8f8309e71ee69954ae0100001952d42800000000"
        )
    }
    
    public func testGetBlockHeaderCount() {
        let json = """
{
    "jsonrpc": "2.0",
    "id": 1,
    "result": 543
}
"""
        let blockHeaderCount = decodeJson(NeoBlockHeaderCount.self, from: json)
        XCTAssertEqual(blockHeaderCount.count, 543)
    }
    
    public func testGetBlockCount() {
        let json = """
{
    "jsonrpc": "2.0",
    "id": 67,
    "result": 1234
}
"""
        let blockCount = decodeJson(NeoBlockCount.self, from: json)
        XCTAssertEqual(blockCount.blockCount, 1234)
    }
    
    public func testGetNativeContracts() {
        let json = """
{
    "jsonrpc": "2.0",
    "id": 1,
    "result": [
        {
            "id": -6,
            "hash": "0xd2a4cff31913016155e38e474a2c06d08be276cf",
            "nef": {
                "magic": 860243278,
                "compiler": "neo-core-v3.0",
                "source": "variable-size-source-gastoken",
                "tokens": [],
                "script": "EEEa93tnQBBBGvd7Z0AQQRr3e2dAEEEa93tnQBBBGvd7Z0A=",
                "checksum": 2663858513
            },
            "manifest": {
                "name": "GasToken",
                "groups": [],
                "supportedstandards": [
                    "NEP-17"
                ],
                "abi": {
                    "methods": [
                        {
                            "name": "balanceOf",
                            "parameters": [
                                {
                                    "name": "account",
                                    "type": "Hash160"
                                }
                            ],
                            "returntype": "Integer",
                            "offset": 0,
                            "safe": true
                        },
                        {
                            "name": "decimals",
                            "parameters": [],
                            "returntype": "Integer",
                            "offset": 7,
                            "safe": true
                        },
                        {
                            "name": "symbol",
                            "parameters": [],
                            "returntype": "String",
                            "offset": 14,
                            "safe": true
                        },
                        {
                            "name": "totalSupply",
                            "parameters": [],
                            "returntype": "Integer",
                            "offset": 21,
                            "safe": true
                        },
                        {
                            "name": "transfer",
                            "parameters": [
                                {
                                    "name": "from",
                                    "type": "Hash160"
                                },
                                {
                                    "name": "to",
                                    "type": "Hash160"
                                },
                                {
                                    "name": "amount",
                                    "type": "Integer"
                                },
                                {
                                    "name": "data",
                                    "type": "Any"
                                }
                            ],
                            "returntype": "Boolean",
                            "offset": 28,
                            "safe": false
                        }
                    ],
                    "events": [
                        {
                            "name": "Transfer",
                            "parameters": [
                                {
                                    "name": "from",
                                    "type": "Hash160"
                                },
                                {
                                    "name": "to",
                                    "type": "Hash160"
                                },
                                {
                                    "name": "amount",
                                    "type": "Integer"
                                }
                            ]
                        }
                    ]
                },
                "permissions": [
                    {
                        "contract": "*",
                        "methods": "*"
                    }
                ],
                "trusts": [],
                "extra": null
            },
            "updatehistory": [
                0
            ]
        },
        {
            "id": -8,
            "hash": "0x49cf4e5378ffcd4dec034fd98a174c5491e395e2",
            "nef": {
                "magic": 860243278,
                "compiler": "neo-core-v3.0",
                "source": "variable-size-source-rolemanagement",
                "tokens": [],
                "script": "EEEa93tnQBBBGvd7Z0A=",
                "checksum": 983638438
            },
            "manifest": {
                "name": "RoleManagement",
                "groups": [],
                "supportedstandards": [],
                "abi": {
                    "methods": [
                        {
                            "name": "designateAsRole",
                            "parameters": [
                                {
                                    "name": "role",
                                    "type": "Integer"
                                },
                                {
                                    "name": "nodes",
                                    "type": "Array"
                                }
                            ],
                            "returntype": "Void",
                            "offset": 0,
                            "safe": false
                        },
                        {
                            "name": "getDesignatedByRole",
                            "parameters": [
                                {
                                    "name": "role",
                                    "type": "Integer"
                                },
                                {
                                    "name": "index",
                                    "type": "Integer"
                                }
                            ],
                            "returntype": "Array",
                            "offset": 7,
                            "safe": true
                        }
                    ],
                    "events": []
                },
                "permissions": [
                    {
                        "contract": "*",
                        "methods": "*"
                    }
                ],
                "trusts": [],
                "extra": null
            },
            "updatehistory": [
                0
            ]
        },
        {
            "id": -9,
            "hash": "0xfe924b7cfe89ddd271abaf7210a80a7e11178758",
            "nef": {
                "magic": 860243278,
                "compiler": "neo-core-v3.0",
                "source": "variable-size-source-oraclecontract",
                "tokens": [],
                "script": "EEEa93tnQBBBGvd7Z0AQQRr3e2dAEEEa93tnQBBBGvd7Z0A=",
                "checksum": 2663858513
            },
            "manifest": {
                "name": "OracleContract",
                "groups": [],
                "supportedstandards": [],
                "abi": {
                    "methods": [
                        {
                            "name": "finish",
                            "parameters": [],
                            "returntype": "Void",
                            "offset": 0,
                            "safe": false
                        },
                        {
                            "name": "getPrice",
                            "parameters": [],
                            "returntype": "Integer",
                            "offset": 7,
                            "safe": true
                        },
                        {
                            "name": "request",
                            "parameters": [
                                {
                                    "name": "url",
                                    "type": "String"
                                },
                                {
                                    "name": "filter",
                                    "type": "String"
                                },
                                {
                                    "name": "callback",
                                    "type": "String"
                                },
                                {
                                    "name": "userData",
                                    "type": "Any"
                                },
                                {
                                    "name": "gasForResponse",
                                    "type": "Integer"
                                }
                            ],
                            "returntype": "Void",
                            "offset": 14,
                            "safe": false
                        },
                        {
                            "name": "setPrice",
                            "parameters": [
                                {
                                    "name": "price",
                                    "type": "Integer"
                                }
                            ],
                            "returntype": "Void",
                            "offset": 21,
                            "safe": false
                        },
                        {
                            "name": "verify",
                            "parameters": [],
                            "returntype": "Boolean",
                            "offset": 28,
                            "safe": true
                        }
                    ],
                    "events": [
                        {
                            "name": "OracleRequest",
                            "parameters": [
                                {
                                    "name": "Id",
                                    "type": "Integer"
                                },
                                {
                                    "name": "RequestContract",
                                    "type": "Hash160"
                                },
                                {
                                    "name": "Url",
                                    "type": "String"
                                },
                                {
                                    "name": "Filter",
                                    "type": "String"
                                }
                            ]
                        },
                        {
                            "name": "OracleResponse",
                            "parameters": [
                                {
                                    "name": "Id",
                                    "type": "Integer"
                                },
                                {
                                    "name": "OriginalTx",
                                    "type": "Hash256"
                                }
                            ]
                        }
                    ]
                },
                "permissions": [
                    {
                        "contract": "*",
                        "methods": "*"
                    }
                ],
                "trusts": [],
                "extra": null
            },
            "updatehistory": [
                0
            ]
        }
    ]
}
"""
        let nativeContracts = decodeJson(NeoGetNativeContracts.self, from: json).nativeContracts!
        XCTAssertEqual(nativeContracts.count, 3)
        
        let c1 = nativeContracts.first!
        XCTAssertEqual(c1.id, -6)
        XCTAssertEqual(c1.hash, try! Hash160("0xd2a4cff31913016155e38e474a2c06d08be276cf"))
        XCTAssertEqual(c1.updateHistory, [0])
        
        let nef1 = c1.nef
        XCTAssertEqual(nef1.magic, 860243278)
        XCTAssertEqual(nef1.compiler, "neo-core-v3.0")
        XCTAssertEqual(nef1.source, "variable-size-source-gastoken")
        XCTAssert(nef1.tokens.isEmpty)
        XCTAssertEqual(nef1.script, "EEEa93tnQBBBGvd7Z0AQQRr3e2dAEEEa93tnQBBBGvd7Z0A=")
        XCTAssertEqual(nef1.checksum, 2663858513)
        
        let manifest1 = c1.manifest
        XCTAssertEqual(manifest1.name, "GasToken")
        XCTAssert(manifest1.groups.isEmpty)
        XCTAssertEqual(manifest1.supportedStandards, ["NEP-17"])
        XCTAssertEqual(manifest1.abi.methods.count, 5)
        XCTAssertEqual(manifest1.abi.events.count, 1)
        
        let c2 = nativeContracts[1]
        XCTAssertEqual(c2.id, -8)
        XCTAssertEqual(c2.hash, try! Hash160("0x49cf4e5378ffcd4dec034fd98a174c5491e395e2"))
        XCTAssertEqual(c2.updateHistory, [0])
        
        let nef2 = c2.nef
        XCTAssertEqual(nef2.magic, 860243278)
        XCTAssertEqual(nef2.compiler, "neo-core-v3.0")
        XCTAssertEqual(nef2.source, "variable-size-source-rolemanagement")
        XCTAssert(nef2.tokens.isEmpty)
        XCTAssertEqual(nef2.script, "EEEa93tnQBBBGvd7Z0A=")
        XCTAssertEqual(nef2.checksum, 983638438)
        
        let manifest2 = c2.manifest
        XCTAssertEqual(manifest2.name, "RoleManagement")
        XCTAssert(manifest2.groups.isEmpty)
        XCTAssert(manifest2.supportedStandards.isEmpty)
        XCTAssertEqual(manifest2.abi.methods.count, 2)
        XCTAssert(manifest2.abi.events.isEmpty)
        
        let c3 = nativeContracts[2]
        XCTAssertEqual(c3.id, -9)
        XCTAssertEqual(c3.hash, try! Hash160("0xfe924b7cfe89ddd271abaf7210a80a7e11178758"))
        XCTAssertEqual(c3.updateHistory, [0])
        
        let nef3 = c3.nef
        XCTAssertEqual(nef3.magic, 860243278)
        XCTAssertEqual(nef3.compiler, "neo-core-v3.0")
        XCTAssertEqual(nef3.source, "variable-size-source-oraclecontract")
        XCTAssert(nef3.tokens.isEmpty)
        XCTAssertEqual(nef3.script, "EEEa93tnQBBBGvd7Z0AQQRr3e2dAEEEa93tnQBBBGvd7Z0A=")
        XCTAssertEqual(nef3.checksum, 2663858513)
    }
    
    public func testGetContractState() {
        let json = """
{
    "jsonrpc": "2.0",
    "id": 1,
    "result": {
        "id": -4,
        "updatecounter": 0,
        "hash": "0xda65b600f7124ce6c79950c1772a36403104f2be",
        "nef": {
            "magic": 860243278,
            "compiler": "neo-core-v3.0",
            "source": "variable-size-source-ledgercontract",
            "tokens": [],
            "script": "EEEa93tnQBBBGvd7Z0AQQRr3e2dAEEEa93tnQBBBGvd7Z0AQQRr3e2dA",
            "checksum": 529571427
        },
        "manifest": {
            "name": "LedgerContract",
            "groups": [],
            "features": {},
            "supportedstandards": [],
            "abi": {
                "methods": [
                    {
                        "name": "currentHash",
                        "parameters": [],
                        "returntype": "Hash256",
                        "offset": 0,
                        "safe": true
                    },
                    {
                        "name": "getTransactionHeight",
                        "parameters": [
                            {
                                "name": "hash",
                                "type": "Hash256"
                            }
                        ],
                        "returntype": "Integer",
                        "offset": 35,
                        "safe": true
                    }
                ],
                "events": []
            },
            "permissions": [
                {
                    "contract": "*",
                    "methods": "*"
                }
            ],
            "trusts": [],
            "extra": null
        }
    }
}
"""
        let contractState = decodeJson(NeoGetContractState.self, from: json).contractState!
        XCTAssertEqual(contractState.id, -4)
        XCTAssertEqual(contractState.updateCounter, 0)
        XCTAssertEqual(contractState.hash, try! Hash160("0xda65b600f7124ce6c79950c1772a36403104f2be"))
        XCTAssertEqual(contractState.nef.magic, 860243278)
        XCTAssertEqual(contractState.nef.compiler, "neo-core-v3.0")
        XCTAssertEqual(contractState.nef.source, "variable-size-source-ledgercontract")
        XCTAssertEqual(contractState.nef.script, "EEEa93tnQBBBGvd7Z0AQQRr3e2dAEEEa93tnQBBBGvd7Z0AQQRr3e2dA")
        XCTAssertEqual(contractState.nef.tokens, [])
        XCTAssertEqual(contractState.nef.checksum, 529571427)
        
        let manifest = contractState.manifest
        XCTAssertEqual(manifest.name, "LedgerContract")
        XCTAssert(manifest.groups.isEmpty)
        XCTAssert(manifest.supportedStandards.isEmpty)
        XCTAssertEqual(manifest.trusts, [])
        XCTAssertNil(manifest.extra)
        
        let abi = manifest.abi
        XCTAssertEqual(abi.methods.count, 2)
        XCTAssert(abi.events.isEmpty)
        
        let method1 = abi.methods[0]
        XCTAssertEqual(method1.name, "currentHash")
        XCTAssert(method1.parameters.isEmpty)
        
        let method2 = abi.methods[1]
        XCTAssertEqual(method2.name, "getTransactionHeight")
        XCTAssertEqual(method2.parameters.count, 1)
        XCTAssertEqual(method2.parameters.first, ContractParameter(name: "hash", type: .hash256))
        XCTAssertEqual(method2.returnType, .integer)
        
        let permissions = manifest.permissions
        XCTAssertEqual(permissions[0], .init(contract: "*", methods: ["*"]))
        
        let id = -4, updateCounter = 0
        
        let hash = try! Hash160("0xda65b600f7124ce6c79950c1772a36403104f2be")
        let nef = ContractNef(magic: 860243278, compiler: "neo-core-v3.0", source: "variable-size-source-ledgercontract", tokens: [],
                              script: "EEEa93tnQBBBGvd7Z0AQQRr3e2dAEEEa93tnQBBBGvd7Z0AQQRr3e2dA", checksum: 529571427)
        let newMethod1 = ContractManifest.ContractABI.ContractMethod(name: "currentHash", parameters: [], offset: 0, returnType: .hash256, safe: true)
        let newMethod2 = ContractManifest.ContractABI.ContractMethod(name: "getTransactionHeight", parameters: [.init(name: "hash", type: .hash256)],
                                                                     offset: 35, returnType: .integer, safe: true)
        let newAbi = ContractManifest.ContractABI(methods: [newMethod1, newMethod2], events: [])
        let permission = ContractManifest.ContractPermission(contract: "*", methods: ["*"])
        let newManifest = ContractManifest(name: "LedgerContract", groups: [], features: [:], supportedStandards: [], abi: newAbi, permissions: [permission], trusts: [], extra: nil)
        let newState = ContractState(id: id, updateCounter: updateCounter, hash: hash, nef: nef, manifest: newManifest)
        
        XCTAssertEqual(contractState, newState)
    }
    
    public func testExpressListContracts() {
        let json = """
{
    "jsonrpc": "2.0",
    "id": 1,
    "result": [
        {
            "hash": "0xda65b600f7124ce6c79950c1772a36403104f2be",
            "manifest": {
                "name": "LedgerContract",
                "groups": [],
                "features": {},
                "supportedstandards": [],
                "abi": {
                    "methods": [
                        {
                            "name": "currentHash",
                            "parameters": [],
                            "returntype": "Hash256",
                            "offset": 0,
                            "safe": true
                        }
                    ],
                    "events": []
                },
                "permissions": [
                    {
                        "contract": "*",
                        "methods": "*"
                    }
                ],
                "trusts": [],
                "extra": null
            }
        }
    ]
}
"""
        let contracts = decodeJson(NeoExpressListContracts.self, from: json).contracts!
        XCTAssertEqual(contracts.count, 1)
        
        let expressContractState = contracts.first!
        XCTAssertEqual(expressContractState.hash, try! Hash160("0xda65b600f7124ce6c79950c1772a36403104f2be"))
        
        let methods = [ContractManifest.ContractABI.ContractMethod(name: "currentHash", parameters: [], offset: 0, returnType: .hash256, safe: true)]
        let abi = ContractManifest.ContractABI(methods: methods, events: [])
        let permisions = [ContractManifest.ContractPermission(contract: "*", methods: ["*"])]
        let manifest = ContractManifest(name: "LedgerContract", groups: [], features: [:], supportedStandards: [], abi: abi, permissions: permisions, trusts: [], extra: nil)
        XCTAssertEqual(expressContractState.manifest, manifest)
    }
    
    public func testGetMemPool() {
        let json = """
{
    "jsonrpc": "2.0",
    "id": 67,
    "result": {
        "height": 5492,
        "verified": [
            "0x9786cce0dddb524c40ddbdd5e31a41ed1f6b5c8a683c122f627ca4a007a7cf4e",
            "0xb488ad25eb474f89d5ca3f985cc047ca96bc7373a6d3da8c0f192722896c1cd7"
        ],
        "unverified": [
            "0x9786cce0dddb524c40ddbdd5e31a41ed1f6b5c8a683c122f627ca4a007a7cf4e",
            "0xb488ad25eb474f89d5ca3f985cc047ca96bc7373a6d3da8c0f192722896c1cd7"
        ]
    }
}
"""
        let memPool = decodeJson(NeoGetMemPool.self, from: json).memPoolDetails!
        XCTAssertEqual(memPool.height, 5492)
        XCTAssertEqual(memPool.verified.count, 2)
        XCTAssert(memPool.verified.contains(try! Hash256("0x9786cce0dddb524c40ddbdd5e31a41ed1f6b5c8a683c122f627ca4a007a7cf4e")))
        XCTAssert(memPool.verified.contains(try! Hash256("0xb488ad25eb474f89d5ca3f985cc047ca96bc7373a6d3da8c0f192722896c1cd7")))
        XCTAssertEqual(memPool.unverified.count, 2)
        XCTAssert(memPool.unverified.contains(try! Hash256("0x9786cce0dddb524c40ddbdd5e31a41ed1f6b5c8a683c122f627ca4a007a7cf4e")))
        XCTAssert(memPool.unverified.contains(try! Hash256("0xb488ad25eb474f89d5ca3f985cc047ca96bc7373a6d3da8c0f192722896c1cd7")))
    }
    
    public func testGetMemPoolEmpty() {
        let json = """
{
    "jsonrpc": "2.0",
    "id": 67,
    "result": {
        "height": 5492,
        "verified": [],
        "unverified": []
    }
}
"""
        let memPool = decodeJson(NeoGetMemPool.self, from: json).memPoolDetails!
        XCTAssertEqual(memPool.height, 5492)
        XCTAssert(memPool.verified.isEmpty)
        XCTAssert(memPool.unverified.isEmpty)
    }
    
    public func testGetRawMemPool() {
        let json = """
{
    "jsonrpc": "2.0",
    "id": 67,
    "result": [
        "0x9786cce0dddb524c40ddbdd5e31a41ed1f6b5c8a683c122f627ca4a007a7cf4e",
        "0xb488ad25eb474f89d5ca3f985cc047ca96bc7373a6d3da8c0f192722896c1cd7",
        "0xf86f6f2c08fbf766ebe59dc84bc3b8829f1053f0a01deb26bf7960d99fa86cd6"
    ]
}
"""
        let rawMemPool = decodeJson(NeoGetRawMemPool.self, from: json)
        XCTAssertEqual(rawMemPool.addresses?.count, 3)
        
        let addresses = [
            try! Hash256("0x9786cce0dddb524c40ddbdd5e31a41ed1f6b5c8a683c122f627ca4a007a7cf4e"),
            try! Hash256("0xb488ad25eb474f89d5ca3f985cc047ca96bc7373a6d3da8c0f192722896c1cd7"),
            try! Hash256("0xf86f6f2c08fbf766ebe59dc84bc3b8829f1053f0a01deb26bf7960d99fa86cd6")
        ]

        addresses.forEach {
            XCTAssert(rawMemPool.addresses!.contains($0))
        }
    }
    
    public func testRawMemPoolEmpty() {
        let json = """
{
    "jsonrpc": "2.0",
    "id": 67,
    "result": []
}
"""
        let rawMemPool = decodeJson(NeoGetRawMemPool.self, from: json)
        XCTAssert(rawMemPool.addresses!.isEmpty)
    }
    
    public func testGetTransaction() {
        let json = """
{
    "jsonrpc": "2.0",
    "id": 1,
    "result": {
        "hash": "0x8b8b222ba4ae17eaf37d444210920690d0981b02c368f4f1973c8fd662438d89",
        "size": 267,
        "version": 0,
        "nonce": 1046354582,
        "sender": "AHE5cLhX5NjGB5R2PcdUvGudUoGUBDeHX4",
        "sysfee": "9007810",
        "netfee": "1267450",
        "validuntilblock": 2103622,
        "signers": [
            {
                "account": "0x69ecca587293047be4c59159bf8bc399985c160d",
                "scopes": "CustomContracts, CustomGroups, WitnessRules",
                "allowedcontracts": [
                    "0xd2a4cff31913016155e38e474a2c06d08be276cf",
                    "0xef4073a0f2b305a38ec4050e4d3d28bc40ea63f5"
                ],
                "allowedgroups": [
                    "033a4d051b04b7fc0230d2b1aaedfd5a84be279a5361a7358db665ad7857787f1b"
                ],
                "rules": [
                    {
                        "action": "Allow",
                        "condition": {
                            "type": "ScriptHash",
                            "hash": "0xef4073a0f2b305a38ec4050e4d3d28bc40ea63f5"
                        }
                    }
                ]
            }
        ],
        "attributes": [
            {
                "type": "HighPriority"
            },
            {
                "type": "OracleResponse",
                "id": 0,
                "code": "Success",
                "result": "EQwhA/HsPB4oPogN5unEifDyfBkAfFM4WqpMDJF8MgB57a3yEQtBMHOzuw=="
            }
        ],
        "script": "AGQMFObBATZUrxE9ipaL3KUsmUioK5U9DBQP7O1Ep0MA2doEn6k2cKQxFxiP9hPADAh0cmFuc2ZlcgwUiXcg2M129PAKv6N8Dt2InCCP3ptBYn1bUjg=",
        "witnesses": [
            {
                "invocation": "DEBhsuS9LxQ2PKpx2XJJ/aGEr/pZ7qfZy77OyhDmWx+BobkQAnDPLg6ohOa9SSHa0OMDavUl7zpmJip3r8T5Dr1L",
                "verification": "EQwhA/HsPB4oPogN5unEifDyfBkAfFM4WqpMDJF8MgB57a3yEQtBMHOzuw=="
            }
        ],
        "blockhash": "0x8529cf7301d13cc13d85913b8367700080a6e96db045687b8db720e91e803299",
        "confirmations": 1388,
        "blocktime": 1589019142879,
        "vmstate": "HALT"
    }
}
"""
        let transaction = decodeJson(NeoGetTransaction.self, from: json).transaction!
        XCTAssertEqual(transaction.hash, try! Hash256("0x8b8b222ba4ae17eaf37d444210920690d0981b02c368f4f1973c8fd662438d89"))
        XCTAssertEqual(transaction.size, 267)
        XCTAssertEqual(transaction.version, 0)
        XCTAssertEqual(transaction.nonce, 1046354582)
        XCTAssertEqual(transaction.sender, "AHE5cLhX5NjGB5R2PcdUvGudUoGUBDeHX4")
        XCTAssertEqual(transaction.sysFee, "9007810")
        XCTAssertEqual(transaction.netFee, "1267450")
        XCTAssertEqual(transaction.validUntilBlock, 2103622)
        
        let signers = transaction.signers
        XCTAssertEqual(signers.count, 1)
        
        let signer = signers.first!
        XCTAssertEqual(signer.account, try! Hash160("69ecca587293047be4c59159bf8bc399985c160d"))
        XCTAssertEqual(signer.scopes, [.customContracts, .customGroups, .witnessRules])
        XCTAssertEqual(signer.allowedContracts, ["0xd2a4cff31913016155e38e474a2c06d08be276cf", "0xef4073a0f2b305a38ec4050e4d3d28bc40ea63f5"])
        XCTAssertEqual(signer.allowedGroups, ["033a4d051b04b7fc0230d2b1aaedfd5a84be279a5361a7358db665ad7857787f1b"])
        XCTAssertEqual(signer.rules?.first, .init(action: .allow, condition: .scriptHash(try! Hash160("0xef4073a0f2b305a38ec4050e4d3d28bc40ea63f5"))))
        
        let attributes = transaction.attributes
        XCTAssertEqual(attributes.first, .highPriority)
        XCTAssertEqual(attributes[1], .oracleResponse(0, .success, "EQwhA/HsPB4oPogN5unEifDyfBkAfFM4WqpMDJF8MgB57a3yEQtBMHOzuw=="))
        
        XCTAssertEqual(transaction.script, "AGQMFObBATZUrxE9ipaL3KUsmUioK5U9DBQP7O1Ep0MA2doEn6k2cKQxFxiP9hPADAh0cmFuc2ZlcgwUiXcg2M129PAKv6N8Dt2InCCP3ptBYn1bUjg=")
        XCTAssertEqual(transaction.witnesses, [.init("DEBhsuS9LxQ2PKpx2XJJ/aGEr/pZ7qfZy77OyhDmWx+BobkQAnDPLg6ohOa9SSHa0OMDavUl7zpmJip3r8T5Dr1L",
                                                     "EQwhA/HsPB4oPogN5unEifDyfBkAfFM4WqpMDJF8MgB57a3yEQtBMHOzuw==")])
        XCTAssertEqual(transaction.blockHash, try! Hash256("0x8529cf7301d13cc13d85913b8367700080a6e96db045687b8db720e91e803299"))
        XCTAssertEqual(transaction.confirmations, 1388)
        XCTAssertEqual(transaction.blockTime, 1589019142879)
        XCTAssertEqual(transaction.vmState, .halt)
    }
    
    public func testGetRawTransaction() {
        let json = """
{
    "jsonrpc": "2.0",
    "id": 1,
    "result": "00961a5e3e0feced44a74300d9da049fa93670a43117188ff6c272890000000000fa561300000000004619200000010feced44a74300d9da049fa93670a43117188ff6015600640c14e6c1013654af113d8a968bdca52c9948a82b953d0c140feced44a74300d9da049fa93670a43117188ff613c00c087472616e736665720c14897720d8cd76f4f00abfa37c0edd889c208fde9b41627d5b523801420c4061b2e4bd2f14363caa71d97249fda184affa59eea7d9cbbececa10e65b1f81a1b9100270cf2e0ea884e6bd4921dad0e3036af525ef3a66262a77afc4f90ebd4b2b110c2103f1ec3c1e283e880de6e9c489f0f27c19007c53385aaa4c0c917c320079edadf2110b413073b3bb"
}
"""
        let rawTransaction = decodeJson(NeoGetRawTransaction.self, from: json)
        XCTAssertEqual(rawTransaction.rawTransaction, "00961a5e3e0feced44a74300d9da049fa93670a43117188ff6c272890000000000fa561300000000004619200000010feced44a74300d9da049fa93670a43117188ff6015600640c14e6c1013654af113d8a968bdca52c9948a82b953d0c140feced44a74300d9da049fa93670a43117188ff613c00c087472616e736665720c14897720d8cd76f4f00abfa37c0edd889c208fde9b41627d5b523801420c4061b2e4bd2f14363caa71d97249fda184affa59eea7d9cbbececa10e65b1f81a1b9100270cf2e0ea884e6bd4921dad0e3036af525ef3a66262a77afc4f90ebd4b2b110c2103f1ec3c1e283e880de6e9c489f0f27c19007c53385aaa4c0c917c320079edadf2110b413073b3bb")
    }
    
    public func testGetStorage() {
        let json = """
{
    "jsonrpc": "2.0",
    "id": 15,
    "result": "4c696e"
}
"""
        XCTAssertEqual(decodeJson(NeoGetStorage.self, from: json).storage, "4c696e")
    }
    
    public func testGetTransactionheight() {
        let json = """
{
    "jsonrpc": "2.0",
    "id": 1,
    "result": 1223
}
"""
        XCTAssertEqual(decodeJson(NeoGetTransactionHeight.self, from: json).height, 1223)
    }
    
    public func testGetNextBlockValidators() {
        let json = """
{
    "jsonrpc": "2.0",
    "id": 1,
    "result": [
        {
            "publickey": "03f1ec3c1e283e880de6e9c489f0f27c19007c53385aaa4c0c917c320079edadf2",
            "votes": "0",
            "active": false
        },
        {
            "publickey": "02494f3ff953e45ca4254375187004f17293f90a1aa4b1a89bc07065bc1da521f6",
            "votes": "91600000",
            "active": true
        }
    ]
}
"""
        let nextBlockValidators = decodeJson(NeoGetNextBlockValidators.self, from: json).nextBlockValidators!
        XCTAssertEqual(nextBlockValidators, [.init(publicKey: "03f1ec3c1e283e880de6e9c489f0f27c19007c53385aaa4c0c917c320079edadf2",
                                                   votes: "0", active: false),
                                             .init(publicKey: "02494f3ff953e45ca4254375187004f17293f90a1aa4b1a89bc07065bc1da521f6",
                                                   votes: "91600000", active: true)])
        
    }
    
    public func testGetNextBlockValidatorsEmpty() {
        let json = """
{
    "jsonrpc": "2.0",
    "id": 67,
    "result": []
}
"""
        let nextBlockValidators = decodeJson(NeoGetNextBlockValidators.self, from: json).nextBlockValidators!
        XCTAssert(nextBlockValidators.isEmpty)
    }
    
    // MARK: Node Methods
    
    public func testGetConnectionCount() {
        let json = """
{
    "jsonrpc": "2.0",
    "id": 1,
    "result": 2
}
"""
        XCTAssertEqual(decodeJson(NeoConnectionCount.self, from: json).count, 2)
    }
    
    public func testGetPeers() {
        let json = """
{
    "jsonrpc": "2.0",
    "id": 1,
    "result": {
        "unconnected": [
            {
                "address": "127.0.0.1",
                "port": 20335
            },
            {
                "address": "127.0.0.1",
                "port": 20336
            },
            {
                "address": "127.0.0.1",
                "port": 20337
            }
        ],
        "bad": [
            {
                "address": "127.0.0.1",
                "port": 20333
            }
        ],
        "connected": [
            {
                "address": "172.18.0.3",
                "port": 40333
            },
            {
                "address": "172.18.0.4",
                "port": 20333
            }
        ]
    }
}
"""
        let peers = decodeJson(NeoGetPeers.self, from: json).peers!
        XCTAssertEqual(peers.unconnected, [
            .init(address: "127.0.0.1", port: 20335),
            .init(address: "127.0.0.1", port: 20336),
            .init(address: "127.0.0.1", port: 20337)
        ])
        XCTAssertEqual(peers.bad, [.init(address: "127.0.0.1", port: 20333)])
        XCTAssertEqual(peers.connected, [
            .init(address: "172.18.0.3", port: 40333),
            .init(address: "172.18.0.4", port: 20333)
        ])
    }
    
    public func testGetPeersEmpty() {
        let json = """
{
    "jsonrpc": "2.0",
    "id": 1,
    "result": {
        "unconnected": [],
        "bad": [],
        "connected": []
    }
}
"""
        let peers = decodeJson(NeoGetPeers.self, from: json).peers!
        XCTAssert(peers.connected.isEmpty)
        XCTAssert(peers.bad.isEmpty)
        XCTAssert(peers.unconnected.isEmpty)
    }
    
    public func testGetVersion() {
        let json = """
{
    "jsonrpc": "2.0",
    "id": 1,
    "result": {
        "tcpport": 40333,
        "wsport": 40334,
        "nonce": 224036820,
        "useragent": "/Neo:3.0.0/",
        "protocol": {
            "network": 769,
            "validatorscount": 7,
            "msperblock": 15000,
            "maxvaliduntilblockincrement": 1,
            "maxtraceableblocks": 3,
            "addressversion": 22,
            "maxtransactionsperblock": 150000,
            "memorypoolmaxtransactions": 34000,
            "initialgasdistribution": 14
        }
    }
}
"""
        let version = decodeJson(NeoGetVersion.self, from: json).version!
        XCTAssertEqual(version.tcpPort, 40333)
        XCTAssertEqual(version.wsPort, 40334)
        XCTAssertEqual(version.nonce, 224036820)
        XCTAssertEqual(version.userAgent, "/Neo:3.0.0/")
        
        let p = version.protocol
        XCTAssertEqual(p.addressVersion, 22)
        XCTAssertEqual(p.network, 769)
        XCTAssertEqual(p.msPerBlock, 15000)
        XCTAssertEqual(p.maxTraceableBlocks, 3)
        XCTAssertEqual(p.maxValidUntilBlockIncrement, 1)
        XCTAssertEqual(p.maxTransactionsPerBlock, 150000)
        XCTAssertEqual(p.memoryPoolMaxTransactions, 34000)
        XCTAssertEqual(p.initialGasDistribution, 14)
    }
    
    public func testGetVersionNetworkLong() {
        let json = """
{
    "jsonrpc": "2.0",
    "id": 1,
    "result": {
        "tcpport": 40333,
        "wsport": 40334,
        "nonce": 224036820,
        "useragent": "/Neo:3.0.0/",
        "protocol": {
            "addressversion": 22,
            "network": 4232068425,
            "msperblock": 15000,
            "maxtraceableblocks": 3,
            "maxvaliduntilblockincrement": 1,
            "maxtransactionsperblock": 150000,
            "memorypoolmaxtransactions": 34000,
            "initialgasdistribution": 14
        }
    }
}
"""
        let version = decodeJson(NeoGetVersion.self, from: json).version!
        XCTAssertEqual(version.tcpPort, 40333)
        XCTAssertEqual(version.wsPort, 40334)
        XCTAssertEqual(version.nonce, 224036820)
        XCTAssertEqual(version.userAgent, "/Neo:3.0.0/")
        
        let p = version.protocol
        XCTAssertEqual(p.addressVersion, 22)
        XCTAssertEqual(p.network, 4232068425)
        XCTAssertEqual(p.msPerBlock, 15000)
        XCTAssertEqual(p.maxTraceableBlocks, 3)
        XCTAssertEqual(p.maxValidUntilBlockIncrement, 1)
        XCTAssertEqual(p.maxTransactionsPerBlock, 150000)
        XCTAssertEqual(p.memoryPoolMaxTransactions, 34000)
        XCTAssertEqual(p.initialGasDistribution, 14)
    }
    
    public func testSendRawTransaction() {
        let json = """
{
    "jsonrpc": "2.0",
    "id": 1,
    "result": {
        "hash": "0xb0748d216c9c0d0498094cdb50407035917b350fc0338c254b78f944f723b770"
    }
}
"""
        let sendRawTransaction = decodeJson(NeoSendRawTransaction.self, from: json).sendRawTransaction
        XCTAssertEqual(sendRawTransaction?.hash, try! Hash256("0xb0748d216c9c0d0498094cdb50407035917b350fc0338c254b78f944f723b770"))
    }
    
    public func testSubmitBlock() {
        let json = """
{
    "jsonrpc": "2.0",
    "id": 1,
    "result": true
}
"""
        let submitBlock = decodeJson(NeoSubmitBlock.self, from: json).submitBlock
        XCTAssertEqual(submitBlock, true)
    }
    
    public func testInvokeFunction() {
        let json = """
{
    "jsonrpc": "2.0",
    "id": 1,
    "result": {
        "script": "wh8MFnRva2Vuc1dpdGhXaXRuZXNzQ2hlY2sMFFdiWCF05OK8ywVb+rl30RPV3+zlQWJ9W1I=",
        "state": "HALT",
        "gasconsumed": "12908980",
        "exception": null,
        "notifications": [
            {
                "eventname": "Mint",
                "contract": "0xe5ecdfd513d177b9fa5b05cbbce2e47421586257",
                "state": {
                    "type": "Array",
                    "value": [
                        {
                            "type": "Integer",
                            "value": "1"
                        },
                        {
                            "type": "ByteString",
                            "value": "dG9rZW4x"
                        }
                    ]
                }
            },
            {
                "eventname": "StorageUpdate",
                "contract": "0xe5ecdfd513d177b9fa5b05cbbce2e47421586257",
                "state": {
                    "type": "Array",
                    "value": [
                        {
                            "type": "ByteString",
                            "value": "dG9rZW4x"
                        },
                        {
                            "type": "ByteString",
                            "value": "Y3JlYXRl"
                        }
                    ]
                }
            }
        ],
        "stack": [
            {
                "type": "InteropInterface",
                "interface": "IIterator",
                "id": "fcf7b800-192a-488f-95d3-c40ac7b30ef1"
            }
        ],
        "session": "6ecb0e24-ce7f-4550-9838-aeb8c9e08570"
    }
}
"""
        let invokeResult = decodeJson(NeoInvokeFunction.self, from: json).invocationResult!
        XCTAssertEqual(invokeResult.script, "wh8MFnRva2Vuc1dpdGhXaXRuZXNzQ2hlY2sMFFdiWCF05OK8ywVb+rl30RPV3+zlQWJ9W1I=")
        XCTAssertEqual(invokeResult.state, .halt)
        XCTAssertEqual(invokeResult.gasConsumed, "12908980")
        XCTAssertNil(invokeResult.exception)

        let notifications = invokeResult.notifications!
        XCTAssertEqual(notifications.count, 2)
        
        let not1 = notifications[0]
        XCTAssertEqual(not1.contract, try! Hash160("0xe5ecdfd513d177b9fa5b05cbbce2e47421586257"))
        XCTAssertEqual(not1.eventName, "Mint")
        XCTAssertEqual(not1.state, .array([.integer(1), .byteString("token1".bytes)]))
        
        let not2 = notifications[1]
        XCTAssertEqual(not2.contract, try! Hash160("0xe5ecdfd513d177b9fa5b05cbbce2e47421586257"))
        XCTAssertEqual(not2.eventName, "StorageUpdate")
        XCTAssertEqual(not2.state, .array([.byteString("token1".bytes), .byteString("create".bytes)]))
        
        XCTAssertEqual(invokeResult.stack, [.interopInterface("fcf7b800-192a-488f-95d3-c40ac7b30ef1", "IIterator")])
        XCTAssertEqual(invokeResult.sessionId, "6ecb0e24-ce7f-4550-9838-aeb8c9e08570")
    }
    
    public func testStackItemInvokeFunction() {
        let json = """
{
    "jsonrpc": "2.0",
    "id": 1,
    "result": {
        "script": "0c14e6c1013654af113d8a968bdca52c9948a82b953d11c00c0962616c616e63654f660c14897720d8cd76f4f00abfa37c0edd889c208fde9b41627d5b52",
        "state": "HALT",
        "gasconsumed": "2007570",
        "exception": null,
        "notifications": [],
        "stack": [
            {
                "type": "Buffer",
                "value": "dHJhbnNmZXI="
            },
            {
                "type": "Buffer",
                "value": "lBNDI5IT+g52XxAnznQvSNt3mpY="
            },
            {
                "type": "Buffer",
                "value": "wWq="
            },
            {
                "type": "Pointer",
                "value": "123"
            },
            {
                "type": "Map",
                "value": [
                    {
                        "key": {
                            "type": "ByteString",
                            "value": "lBNDI5IT+g52XxAnznQvSNt3mpY="
                        },
                        "value": {
                            "type": "Pointer",
                            "value": 12
                        }
                    }
                ]
            }
        ]
    }
}
"""
        let invocationResult = decodeJson(NeoInvokeFunction.self, from: json).invocationResult!
        XCTAssertEqual(invocationResult.script, "0c14e6c1013654af113d8a968bdca52c9948a82b953d11c00c0962616c616e63654f660c14897720d8cd76f4f00abfa37c0edd889c208fde9b41627d5b52")
        XCTAssertEqual(invocationResult.state, .halt)
        XCTAssertEqual(invocationResult.gasConsumed, "2007570")
        XCTAssertNil(invocationResult.exception)
        XCTAssert(invocationResult.notifications!.isEmpty)
        
        let stack = invocationResult.stack
        XCTAssertEqual(stack.count, 5)
        
        guard case .buffer = stack[0], case .buffer = stack[1], case .buffer = stack[2] else { return XCTFail() }
        XCTAssertEqual(stack[0].string, "transfer")
        XCTAssertEqual(stack[1].address, "NZQvGWfSupuUAYtCH6pje72hdkWJH1jAZP")
        XCTAssertEqual(stack[2].byteArray, "c16a".bytesFromHex)
        XCTAssertEqual(stack[2].integer, 27329)
        XCTAssertEqual(stack[3], .pointer(123))
        XCTAssertEqual(stack[4], .map([.byteString("941343239213fa0e765f1027ce742f48db779a96".bytesFromHex) : .pointer(12)]))
    }
    
    public func testInvokeFunctionPendingSignatures() {
        let json = """
{
    "jsonrpc": "2.0",
    "id": 1,
    "result": {
        "script": "00046e616d65675f0e5a86edd8e1f62b68d2b3f7c0a761fc5a67dc",
        "state": "HALT",
        "gasconsumed": "2.489",
        "stack": [],
        "pendingsignature": {
            "type": "Transaction",
            "data": "base64 string of the tx bytes",
            "network": 305419896,
            "items": {
                "0x69ecca587293047be4c59159bf8bc399985c160d": {
                    "script": "base64 script",
                    "parameters": [
                        {
                            "type": "Signature",
                            "value": ""
                        }
                    ],
                    "signatures": {
                        "<033a4d051b04b7fc0230d2b1aaedfd5a84be279a5361a7358db665ad7857787f1b>": "base64 string of signature"
                    }
                },
                "0x05859de95ccbbd5668e0f055b208273634d4657f": {
                    "script": "base64 script",
                    "parameters": [
                        {
                            "type": "Signature"
                        },
                        {
                            "type": "Signature"
                        }
                    ],
                    "signatures": {
                        "033a1d0a3b04b7fc0230d2b1aaedfd5a84be279a5361a7358db665ad7957783f81": "base64 string of signature",
                        "033a4c051b09b77c0230d2b1aaedfd5a84be279a5361a7358db665ad7d57787f10": "base64 string of signature"
                    }
                }
            }
        }
    }
}
"""
        let invocationResult = decodeJson(NeoInvokeFunction.self, from: json).invocationResult!
        XCTAssertEqual(invocationResult.script, "00046e616d65675f0e5a86edd8e1f62b68d2b3f7c0a761fc5a67dc")
        XCTAssertEqual(invocationResult.state, .halt)
        XCTAssertEqual(invocationResult.gasConsumed, "2.489")
        XCTAssert(invocationResult.stack.isEmpty)
        
        let pendingSignature = invocationResult.pendingSignature!
        XCTAssertEqual(pendingSignature.type, "Transaction")
        XCTAssertEqual(pendingSignature.data, "base64 string of the tx bytes")
        XCTAssertEqual(pendingSignature.network, 305419896)
        
        let item = pendingSignature.items["0x05859de95ccbbd5668e0f055b208273634d4657f"]!
        XCTAssertEqual(item.script, "base64 script")
        XCTAssertEqual(item.parameters[1].type, .signature)
        XCTAssertEqual(item.signatures["033a1d0a3b04b7fc0230d2b1aaedfd5a84be279a5361a7358db665ad7957783f81"], "base64 string of signature")
    }
    
    public func testInvokeFunctionWithoutOrEmptyParams() {
        let json = """
{
    "jsonrpc": "2.0",
    "id": 1,
    "result": {
        "script": "10c00c0962616c616e63654f660c14897720d8cd76f4f00abfa37c0edd889c208fde9b41627d5b52",
        "state": "FAULT",
        "gasconsumed": "2007390",
        "exception": null,
        "notifications": [],
        "stack": []
    }
}
"""
        let invocationResult = decodeJson(NeoInvokeFunction.self, from: json).invocationResult!
        XCTAssertEqual(invocationResult.script, "10c00c0962616c616e63654f660c14897720d8cd76f4f00abfa37c0edd889c208fde9b41627d5b52")
        XCTAssertEqual(invocationResult.state, .fault)
        XCTAssertEqual(invocationResult.gasConsumed, "2007390")
        XCTAssert(invocationResult.stack.isEmpty)
        
        XCTAssertEqual(invocationResult, InvocationResult(
            script: "10c00c0962616c616e63654f660c14897720d8cd76f4f00abfa37c0edd889c208fde9b41627d5b52",
            state: .fault, gasConsumed: "2007390", exception: nil, notifications: [], diagnostics: nil,
            stack: [], tx: nil, pendingSignature: nil, sessionId: nil))
    }
    
    public func testInvokeFunctionEmptyState() {
        let json = """
{
    "jsonrpc": "2.0",
    "id": 1,
    "result": {
        "script": "10c00c0962616c616e63654f660c14897720d8cd76f4f00abfa37c0edd889c208fde9b41627d5b52",
        "state": "",
        "gasconsumed": "2007390",
        "stack": []
    }
}
"""
        let invocationResult = decodeJson(NeoInvokeFunction.self, from: json).invocationResult!
        XCTAssertEqual(invocationResult.script, "10c00c0962616c616e63654f660c14897720d8cd76f4f00abfa37c0edd889c208fde9b41627d5b52")
        XCTAssertEqual(invocationResult.state, .none)
        XCTAssertEqual(invocationResult.gasConsumed, "2007390")
        XCTAssert(invocationResult.stack.isEmpty)
    }
    
    public func testInvokeFuntionDiagnostics() {
        let json = """
{
    "jsonrpc": "2.0",
    "id": 1,
    "result": {
        "script": "wh8MC2NhbGxTeW1ib2xzDBQ35AiF8REp1Iy5N6DbcAjECghSDkFifVtS",
        "state": "HALT",
        "gasconsumed": "4845600",
        "exception": null,
        "notifications": [],
        "diagnostics": {
            "invokedcontracts": {
                "hash": "0x7df45ba2d3a0c0520ceef7a73f8d1c404cc59a48",
                "call": [
                    {
                        "hash": "0x0e52080ac40870dba037b98cd42911f18508e437",
                        "call": [
                            {
                                "hash": "0x0e52080ac40870dba037b98cd42911f18508e437"
                            },
                            {
                                "hash": "0xef4073a0f2b305a38ec4050e4d3d28bc40ea63f5"
                            },
                            {
                                "hash": "0xd2a4cff31913016155e38e474a2c06d08be276cf"
                            }
                        ]
                    }
                ]
            },
            "storagechanges": [
                {
                    "state": "Deleted",
                    "key": "BgAAAP8=",
                    "value": "DRZcmJnDi79ZkcXkewSTcljK7Gk="
                },
                {
                    "state": "Changed",
                    "key": "+v///xQNFlyYmcOLv1mRxeR7BJNyWMrsaQ==",
                    "value": "QQEhBQAb1mAS"
                },
                {
                    "state": "Added",
                    "key": "+v///xRjv+9gkFzYfFbaQGRkS+b3ro7EiA==",
                    "value": "QQEhAQo="
                }
            ]
        },
        "stack": [
            {
                "type": "Array",
                "value": [
                    {
                        "type": "ByteString",
                        "value": "TkVP"
                    },
                    {
                        "type": "ByteString",
                        "value": "R0FT"
                    },
                    {
                        "type": "ByteString",
                        "value": "TkVP"
                    }
                ]
            }
        ]
    }
}
"""
        let diagnostics = decodeJson(NeoInvokeFunction.self, from: json).invocationResult!.diagnostics!
        
        let invokedContracts = diagnostics.invokedContracts
        let invokeHash = try! Hash160("0x7df45ba2d3a0c0520ceef7a73f8d1c404cc59a48")
        XCTAssertEqual(invokedContracts.hash, invokeHash)
        
        let calls = invokedContracts.invokedContracts!
        let calledContract = try! Hash160("0x0e52080ac40870dba037b98cd42911f18508e437")
        XCTAssertEqual(calls.count, 1)
        XCTAssertEqual(calls[0].hash, calledContract)
        
        let nestedInvokedContracts = calls[0].invokedContracts!
        XCTAssertEqual(nestedInvokedContracts.count, 3)
        XCTAssertEqual(nestedInvokedContracts[0].hash, calledContract)
        XCTAssertNil(nestedInvokedContracts[0].invokedContracts)
        let neoToken = try! Hash160("0xef4073a0f2b305a38ec4050e4d3d28bc40ea63f5")
        XCTAssertEqual(nestedInvokedContracts[1].hash, neoToken)
        XCTAssertNil(nestedInvokedContracts[1].invokedContracts)
        let gasToken = try! Hash160("0xd2a4cff31913016155e38e474a2c06d08be276cf")
        XCTAssertEqual(nestedInvokedContracts[2].hash, gasToken)
        XCTAssertNil(nestedInvokedContracts[2].invokedContracts)
        
        let storageChanges = diagnostics.storageChanges
        XCTAssertEqual(storageChanges.count, 3)
        
        let storageChange1 = Diagnostics.StorageChange(state: "Deleted", key: "BgAAAP8=", value: "DRZcmJnDi79ZkcXkewSTcljK7Gk=")
        let storageChange2 = Diagnostics.StorageChange(state: "Changed", key: "+v///xQNFlyYmcOLv1mRxeR7BJNyWMrsaQ==", value: "QQEhBQAb1mAS")
        let storageChange3 = Diagnostics.StorageChange(state: "Added", key: "+v///xRjv+9gkFzYfFbaQGRkS+b3ro7EiA==", value: "QQEhAQo=")

        XCTAssertEqual(storageChanges[0], storageChange1)
        XCTAssertEqual(storageChanges[1], storageChange2)
        XCTAssertEqual(storageChanges[2], storageChange3)
        
        let calledContractCall = Diagnostics.InvokedContract(hash: calledContract, invokedContracts: nil)
        let neoTokenCall = Diagnostics.InvokedContract(hash: neoToken, invokedContracts: nil)
        let gasTokenCall = Diagnostics.InvokedContract(hash: gasToken, invokedContracts: nil)
        let call = Diagnostics.InvokedContract(hash: calledContract, invokedContracts: [calledContractCall, neoTokenCall, gasTokenCall])
        
        XCTAssertEqual(diagnostics, .init(invokedContracts: .init(hash: invokeHash, invokedContracts: [call]),
                                          storageChanges: [storageChange1, storageChange2, storageChange3]))
    }
    
    public func testInvokeScript() {
        let json = """
{
    "jsonrpc": "2.0",
    "id": 3,
    "result": {
        "script": "10c00c08646563696d616c730c1425059ecb4878d3a875f91c51ceded330d4575fde41627d5b52",
        "state": "HALT",
        "gasconsumed": "0.161",
        "stack": [
            {
                "type": "ByteString",
                "value": "VHJhbnNmZXI="
            }
        ]
    }
}
"""
        let invocationResult = decodeJson(NeoInvokeScript.self, from: json).invocationResult!
        XCTAssertEqual(invocationResult.script, "10c00c08646563696d616c730c1425059ecb4878d3a875f91c51ceded330d4575fde41627d5b52")
        XCTAssertEqual(invocationResult.state, .halt)
        XCTAssertEqual(invocationResult.gasConsumed, "0.161")
        XCTAssertEqual(invocationResult.stack, [.byteString("Transfer".bytes)])
    }
    
    public func testTraverseIterator() {
        let json = """
{
    "jsonrpc": "2.0",
    "id": 1,
    "result": [
        {
            "type": "ByteString",
            "value": "dG9rZW5PbmU="
        },
        {
            "type": "ByteString",
            "value": "dG9rZW5Ud28="
        },
        {
            "type": "ByteString",
            "value": "dG9rZW5UaHJlZQ=="
        },
        {
            "type": "ByteString",
            "value": "dG9rZW5Gb3Vy"
        }
    ]
}
"""
        let traverseIterator = decodeJson(NeoTraverseIterator.self, from: json).traverseIterator!
        XCTAssertEqual(traverseIterator.count, 4)
        XCTAssertEqual(traverseIterator[3].string, "tokenFour")
    }
    
    public func testTerminateSession() {
        let json = """
{
    "jsonrpc": "2.0",
    "id": 1,
    "result": true
}
"""
        XCTAssertTrue(decodeJson(NeoTerminateSession.self, from: json).terminateSession!)
    }
    
    public func testNeoInvokeContractVerify() {
        let json = """
{
  "jsonrpc": "2.0",
  "id": 1,
  "result": {
    "script": "VgEMFJOtFXKks1xLklSDzhcBt4dC3EYPYEBXAAIhXwAhQfgn7IxA",
    "state": "FAULT",
    "gasconsumed": "0.0103542",
    "exception": "Specified argument was out of the range of valid values. (Parameter 'index')",
    "stack": [
      {
        "type": "Buffer",
        "value": "dHJhbnNmZXI="
      }
    ]
  }
}
"""
        let invocationResult = decodeJson(NeoInvokeContractVerify.self, from: json).invocationResult!
        XCTAssertEqual(invocationResult.script, "VgEMFJOtFXKks1xLklSDzhcBt4dC3EYPYEBXAAIhXwAhQfgn7IxA")
        XCTAssertEqual(invocationResult.state, .fault)
        XCTAssertEqual(invocationResult.gasConsumed, "0.0103542")
        XCTAssertEqual(invocationResult.exception, "Specified argument was out of the range of valid values. (Parameter 'index')")
        XCTAssertEqual(invocationResult.stack.first, .buffer("transfer".bytes))
    }
    
    // MARK: Utilities Methods
    
    public func testListPlugins() {
        let json = """
{
    "jsonrpc": "2.0",
    "id": 1,
    "result": [
        {
            "name": "ApplicationLogs",
            "version": "3.0.0.0",
            "interfaces": [
                "IPersistencePlugin"
            ]
        },
        {
            "name": "LevelDBStore",
            "version": "3.0.0.0",
            "interfaces": []
        },
        {
            "name": "RocksDBStore",
            "version": "3.0.0.0",
            "interfaces": []
        },
        {
            "name": "RpcNep17Tracker",
            "version": "3.0.0.0",
            "interfaces": [
                "IPersistencePlugin"
            ]
        },
        {
            "name": "RpcServerPlugin",
            "version": "3.0.0.0",
            "interfaces": []
        },
        {
            "name": "StatesDumper",
            "version": "3.0.0.0",
            "interfaces": [
                "IPersistencePlugin"
            ]
        },
        {
            "name": "SystemLog",
            "version": "3.0.0.0",
            "interfaces": [
                "ILogPlugin"
            ]
        }
    ]
}
"""
        let plugins = decodeJson(NeoListPlugins.self, from: json).plugins!
        XCTAssertEqual(plugins.count, 7)
        
        let types: [NodePluginType] = [.applicationLogs, .levelDbStore, .rocksDbStore, .rpcNep17Tracker,
                                       .rpcServerPlugin, .statesDumper, .systemLog]
        let interfaces: [[String]] = [["IPersistencePlugin"], [], [], ["IPersistencePlugin"], [], ["IPersistencePlugin"], ["ILogPlugin"]]
        
        plugins.enumerated().forEach { i, plugin in
            XCTAssertEqual(NodePluginType(rawValue: plugin.name), types[i])
            XCTAssertEqual(plugin.version, "3.0.0.0")
            XCTAssertEqual(plugin.interfaces, interfaces[i])
        }
        
    }
    
    public func testValidateAddress() {
        let json = """
{
    "jsonrpc": "2.0",
    "id": 1,
    "result": {
        "address": "AQVh2pG732YvtNaxEGkQUei3YA4cvo7d2i",
        "isvalid": true
    }
}
"""
        let validation = decodeJson(NeoValidateAddress.self, from: json).validation!
        XCTAssertEqual(validation.address, "AQVh2pG732YvtNaxEGkQUei3YA4cvo7d2i")
        XCTAssertTrue(validation.isValid)
    }
    
    public func testCloseWallet() {
        let json = """
{
    "jsonrpc": "2.0",
    "id": 1,
    "result": true
}
"""
        XCTAssertTrue(decodeJson(NeoCloseWallet.self, from: json).closeWallet!)
    }
    
    public func testOpenWallet() {
        let json = """
{
    "jsonrpc": "2.0",
    "id": 1,
    "result": true
}
"""
        XCTAssertTrue(decodeJson(NeoOpenWallet.self, from: json).openWallet!)
    }
    
    public func testDumpPrivKey() {
        let json = """
{
    "jsonrpc": "2.0",
    "id": 1,
    "result": "L1ZW4aRmy4MMG3x3wk9S6WEJJxcaZi72YxPx854Lspdo9jNFxEoJ"
}
"""
        let privKey = decodeJson(NeoDumpPrivKey.self, from: json).dumpPrivKey!
        XCTAssertEqual(privKey, "L1ZW4aRmy4MMG3x3wk9S6WEJJxcaZi72YxPx854Lspdo9jNFxEoJ")
    }
    
    public func testGetWalletBalance() {
        let json = """
{
    "jsonrpc": "2.0",
    "id": 1,
    "result": {
        "balance": "200"
    }
}
"""
        let balance = decodeJson(NeoGetWalletBalance.self, from: json).walletBalance!
        XCTAssertEqual(balance.balance, "200")
    }
    
    public func testGetWalletBalanceUpperCase() {
        let json = """
{
    "id": 1,
    "jsonrpc": "2.0",
    "result": {
        "Balance": "199999990.0"
    }
}
"""
        let balance = decodeJson(NeoGetWalletBalance.self, from: json).walletBalance!
        XCTAssertEqual(balance.balance, "199999990.0")
    }
    
    public func testGetNewAddress() {
        let json = """
{
    "jsonrpc": "2.0",
    "id": 1,
    "result": "APuGosNQYQoRYYMxvay3yZsragzvfBMdNs"
}
"""
        let address = decodeJson(NeoGetNewAddress.self, from: json).address!
        XCTAssertEqual(address, "APuGosNQYQoRYYMxvay3yZsragzvfBMdNs")
    }
    
    public func testGetUnclaimedGas() {
        let json = """
{
    "jsonrpc": "2.0",
    "id": 1,
    "result": {
        "unclaimed": "79199824176",
        "address": "AGZLEiwUyCC4wiL5sRZA3LbxWPs9WrZeyN"
    }
}
"""
        let unclaimedGas = decodeJson(NeoGetUnclaimedGas.self, from: json).unclaimedGas!
        XCTAssertEqual(unclaimedGas.address, "AGZLEiwUyCC4wiL5sRZA3LbxWPs9WrZeyN")
        XCTAssertEqual(unclaimedGas.unclaimed, "79199824176")
    }
    
    public func testGetWalletUnclaimedGas() {
        let json = """
{
    "jsonrpc": "2.0",
    "id": 1,
    "result": "289799420400"
}
"""
        let walletUnclaimedGas = decodeJson(NeoGetWalletUnclaimedGas.self, from: json).walletUnclaimedGas!
        XCTAssertEqual(walletUnclaimedGas, "289799420400")
    }
    
    public func testImportPrivKey() {
        let json = """
{
    "jsonrpc": "2.0",
    "id": 1,
    "result": {
        "address": "AYhJaF5oqUscfNfH87KQHm1YwuKrwPgkMA",
        "haskey": true,
        "label": null,
        "watchonly": false
    }
}
"""
        let address = decodeJson(NeoImportPrivKey.self, from: json).address!
        XCTAssertEqual(address.address, "AYhJaF5oqUscfNfH87KQHm1YwuKrwPgkMA")
        XCTAssertTrue(address.hasKey)
        XCTAssertNil(address.label)
        XCTAssertFalse(address.watchOnly)
    }
    
    public func testListAddress() {
        let json = """
{
    "jsonrpc": "2.0",
    "id": 1,
    "result": [
        {
            "address": "AK5AmzrrM3sw3kbCHXpHNeuK3kkjnneUrb",
            "haskey": true,
            "label": "hodl",
            "watchonly": false
        },
        {
            "address": "AHE5cLhX5NjGB5R2PcdUvGudUoGUBDeHX4",
            "haskey": false,
            "label": null,
            "watchonly": true
        }
    ]
}
"""
        let addresses = decodeJson(NeoListAddress.self, from: json).addresses!
        XCTAssertEqual(addresses.count, 2)
        
        let address1 = addresses[0]
        XCTAssertEqual(address1.address, "AK5AmzrrM3sw3kbCHXpHNeuK3kkjnneUrb")
        XCTAssertTrue(address1.hasKey)
        XCTAssertEqual(address1.label, "hodl")
        XCTAssertFalse(address1.watchOnly)
        
        let address2 = addresses[1]
        XCTAssertEqual(address2.address, "AHE5cLhX5NjGB5R2PcdUvGudUoGUBDeHX4")
        XCTAssertFalse(address2.hasKey)
        XCTAssertNil(address2.label)
        XCTAssertTrue(address2.watchOnly)
    }
    
    public func testSendFrom() {
        let json = """
{
    "jsonrpc": "2.0",
    "id": 1,
    "result": {
        "hash": "0x6818f446c2e503998ac766a8a175f86d9a89885423f6b055aa123c984625833e",
        "size": 266,
        "version": 0,
        "nonce": 1762654532,
        "sender": "AHE5cLhX5NjGB5R2PcdUvGudUoGUBDeHX4",
        "sysfee": "9007810",
        "netfee": "1266450",
        "validuntilblock": 2106392,
        "signers": [
            {
                "account": "0xf68f181731a47036a99f04dad90043a744edec0f",
                "scopes": "CalledByEntry"
            }
        ],
        "attributes": [],
        "script": "GgwU5sEBNlSvET2KlovcpSyZSKgrlT0MFA/s7USnQwDZ2gSfqTZwpDEXGI/2E8AMCHRyYW5zZmVyDBSJdyDYzXb08Aq/o3wO3YicII/em0FifVtSOA==",
        "witnesses": [
            {
                "invocation": "DEAZaoPvbyaQyUYqIBc4MyDCGxGhxlPCuBbcHn5cYMpHPi2JD4PX2I1EsDPNtrEESPo//WBnsKyl5o5ViR5YDcJR",
                "verification": "EQwhA/HsPB4oPogN5unEifDyfBkAfFM4WqpMDJF8MgB57a3yEQtBMHOzuw=="
            }
        ]
    }
}
"""
        let sendFrom = decodeJson(NeoSendFrom.self, from: json).sendFrom!
        XCTAssertEqual(sendFrom.hash, try! Hash256("0x6818f446c2e503998ac766a8a175f86d9a89885423f6b055aa123c984625833e"))
        XCTAssertEqual(sendFrom.size, 266)
        XCTAssertEqual(sendFrom.version, 0)
        XCTAssertEqual(sendFrom.nonce, 1762654532)
        XCTAssertEqual(sendFrom.sender, "AHE5cLhX5NjGB5R2PcdUvGudUoGUBDeHX4")
        XCTAssertEqual(sendFrom.sysFee, "9007810")
        XCTAssertEqual(sendFrom.netFee, "1266450")
        XCTAssertEqual(sendFrom.validUntilBlock, 2106392)
        XCTAssertEqual(sendFrom.signers, [.init(try! Hash160("0xf68f181731a47036a99f04dad90043a744edec0f"), [.calledByEntry])])
        XCTAssert(sendFrom.attributes.isEmpty)
        XCTAssertEqual(sendFrom.script, "GgwU5sEBNlSvET2KlovcpSyZSKgrlT0MFA/s7USnQwDZ2gSfqTZwpDEXGI/2E8AMCHRyYW5zZmVyDBSJdyDYzXb08Aq/o3wO3YicII/em0FifVtSOA==")
        XCTAssertEqual(sendFrom.witnesses, [
            NeoWitness("DEAZaoPvbyaQyUYqIBc4MyDCGxGhxlPCuBbcHn5cYMpHPi2JD4PX2I1EsDPNtrEESPo//WBnsKyl5o5ViR5YDcJR",
                       "EQwhA/HsPB4oPogN5unEifDyfBkAfFM4WqpMDJF8MgB57a3yEQtBMHOzuw==")
        ])
    }
    
    public func testSendMany() {
        let json = """
{
    "jsonrpc": "2.0",
    "id": 1,
    "result": {
        "hash": "0xf60ec3b0810fb8c17a9a05eaeb3b361ead889a38d3fd1bf2d561a6e7001bb2f5",
        "size": 352,
        "version": 0,
        "nonce": 1256822346,
        "sender": "AHE5cLhX5NjGB5R2PcdUvGudUoGUBDeHX4",
        "sysfee": "18015620",
        "netfee": "1352450",
        "validuntilblock": 2106840,
        "signers": [
            {
                "account": "0xbe175fb771d5782282b7598b56c26a2f5ebf2d24",
                "scopes": "CalledByEntry"
            },
            {
                "account": "0xf68f181731a47036a99f04dad90043a744edec0f",
                "scopes": "CalledByEntry"
            }
        ],
        "attributes": [],
        "script": "AGQMFObBATZUrxE9ipaL3KUsmUioK5U9DBQP7O1Ep0MA2doEn6k2cKQxFxiP9hPADAh0cmFuc2ZlcgwUiXcg2M129PAKv6N8Dt2InCCP3ptBYn1bUjgaDBQP7O1Ep0MA2doEn6k2cKQxFxiP9gwUD+ztRKdDANnaBJ+pNnCkMRcYj/YTwAwIdHJhbnNmZXIMFIl3INjNdvTwCr+jfA7diJwgj96bQWJ9W1I4",
        "witnesses": [
            {
                "invocation": "DEDjHdgTfdXKx1R9f4D1lRklhisjDOkkMt7t1fO1CPO31gVQZUiWJc7GvJqjkR35iDjJjGIwd3s/Lm7q71rwdVC4",
                "verification": "EQwhA/HsPB4oPogN5unEifDyfBkAfFM4WqpMDJF8MgB57a3yEQtBMHOzuw=="
            }
        ]
    }
}
"""
        let sendMany = decodeJson(NeoSendMany.self, from: json).sendMany!
        XCTAssertEqual(sendMany.hash, try! Hash256("0xf60ec3b0810fb8c17a9a05eaeb3b361ead889a38d3fd1bf2d561a6e7001bb2f5"))
        XCTAssertEqual(sendMany.size, 352)
        XCTAssertEqual(sendMany.version, 0)
        XCTAssertEqual(sendMany.nonce, 1256822346)
        XCTAssertEqual(sendMany.sender, "AHE5cLhX5NjGB5R2PcdUvGudUoGUBDeHX4")
        XCTAssertEqual(sendMany.sysFee, "18015620")
        XCTAssertEqual(sendMany.netFee, "1352450")
        XCTAssertEqual(sendMany.validUntilBlock, 2106840)
        XCTAssertEqual(sendMany.signers, [
            .init(try! Hash160("0xbe175fb771d5782282b7598b56c26a2f5ebf2d24"), [.calledByEntry]),
            .init(try! Hash160("0xf68f181731a47036a99f04dad90043a744edec0f"), [.calledByEntry])
        ])
        XCTAssert(sendMany.attributes.isEmpty)
        XCTAssertEqual(sendMany.script, "AGQMFObBATZUrxE9ipaL3KUsmUioK5U9DBQP7O1Ep0MA2doEn6k2cKQxFxiP9hPADAh0cmFuc2ZlcgwUiXcg2M129PAKv6N8Dt2InCCP3ptBYn1bUjgaDBQP7O1Ep0MA2doEn6k2cKQxFxiP9gwUD+ztRKdDANnaBJ+pNnCkMRcYj/YTwAwIdHJhbnNmZXIMFIl3INjNdvTwCr+jfA7diJwgj96bQWJ9W1I4")
        XCTAssertEqual(sendMany.witnesses, [
            NeoWitness("DEDjHdgTfdXKx1R9f4D1lRklhisjDOkkMt7t1fO1CPO31gVQZUiWJc7GvJqjkR35iDjJjGIwd3s/Lm7q71rwdVC4",
                       "EQwhA/HsPB4oPogN5unEifDyfBkAfFM4WqpMDJF8MgB57a3yEQtBMHOzuw==")
        ])
    }
    
    public func testSendManyEmptyTx() {
        let json = """
{
    "jsonrpc": "2.0",
    "id": 1,
    "error": {
        "code": -32602,
        "message": "Invalid params"
    }
}
"""
        XCTAssert(decodeJson(NeoSendMany.self, from: json).hasError)
    }
    
    public func testSendToAddress() {
        let json = """
{
    "jsonrpc": "2.0",
    "id": 1,
    "result": {
        "hash": "0xabd78548399bbe684fac50b6a71d0ce3f689497d4e79cb26a2b4dfb211782c39",
        "size": 375,
        "version": 0,
        "nonce": 1509730265,
        "sender": "AK5AmzrrM3sw3kbCHXpHNeuK3kkjnneUrb",
        "sysfee": "9007810",
        "netfee": "2375840",
        "validuntilblock": 2106930,
        "signers": [
            {
                "account": "0xf68f181731a47036a99f04dad90043a744edec0f",
                "scopes": "CalledByEntry"
            }
        ],
        "attributes": [],
        "script": "GgwU5sEBNlSvET2KlovcpSyZSKgrlT0MFA/s7USnQwDZ2gSfqTZwpDEXGI/2E8AMCHRyYW5zZmVyDBSJdyDYzXb08Aq/o3wO3YicII/em0FifVtSOA==",
        "witnesses": [
            {
                "invocation": "DECstBmb75AW65NjA35fFlSxszuLRDUzd0nnbfyH8MlnSA02f6B1XlvItpZQBsAd7Pvqa7S+olPAKDO0qtq3ZtOB",
                "verification": "DCED8ew8Hig+iA3m6cSJ8PJ8GQB8UzhaqkwMkXwyAHntrfILQQqQatQ="
            },
            {
                "invocation": "DED6KQHcomjUhyLcmIcPwM1iWkbOlgDnidWZP+PLDWLQRk2rKLg5B/sY1YD1bqylF0zmtDCSIQKeMivAGJyOSXi4",
                "verification": "EQwhA/HsPB4oPogN5unEifDyfBkAfFM4WqpMDJF8MgB57a3yEQtBMHOzuw=="
            }
        ]
    }
}
"""
        let sendToAddress = decodeJson(NeoSendToAddress.self, from: json).sendToAddress!
        XCTAssertEqual(sendToAddress.hash, try! Hash256("0xabd78548399bbe684fac50b6a71d0ce3f689497d4e79cb26a2b4dfb211782c39"))
        XCTAssertEqual(sendToAddress.size, 375)
        XCTAssertEqual(sendToAddress.version, 0)
        XCTAssertEqual(sendToAddress.nonce, 1509730265)
        XCTAssertEqual(sendToAddress.sender, "AK5AmzrrM3sw3kbCHXpHNeuK3kkjnneUrb")
        XCTAssertEqual(sendToAddress.sysFee, "9007810")
        XCTAssertEqual(sendToAddress.netFee, "2375840")
        XCTAssertEqual(sendToAddress.validUntilBlock, 2106930)
        XCTAssertEqual(sendToAddress.signers, [.init(try! Hash160("0xf68f181731a47036a99f04dad90043a744edec0f"), [.calledByEntry])])
        XCTAssert(sendToAddress.attributes.isEmpty)
        XCTAssertEqual(sendToAddress.witnesses, [
            .init("DECstBmb75AW65NjA35fFlSxszuLRDUzd0nnbfyH8MlnSA02f6B1XlvItpZQBsAd7Pvqa7S+olPAKDO0qtq3ZtOB",
                  "DCED8ew8Hig+iA3m6cSJ8PJ8GQB8UzhaqkwMkXwyAHntrfILQQqQatQ="),
            .init("DED6KQHcomjUhyLcmIcPwM1iWkbOlgDnidWZP+PLDWLQRk2rKLg5B/sY1YD1bqylF0zmtDCSIQKeMivAGJyOSXi4",
                  "EQwhA/HsPB4oPogN5unEifDyfBkAfFM4WqpMDJF8MgB57a3yEQtBMHOzuw==")
        ])
    }
    
    // MARK: TokenTracker: Nep17
    
    public func testGetNep17Trackers() {
        let json = """
{
    "jsonrpc": "2.0",
    "id": 1,
    "result": {
        "sent": [
            {
                "timestamp": 1554283931,
                "assethash": "1aada0032aba1ef6d1f07bbd8bec1d85f5380fb3",
                "transferaddress": "AYwgBNMepiv5ocGcyNT4mA8zPLTQ8pDBis",
                "amount": "100000000000",
                "blockindex": 368082,
                "transfernotifyindex": 0,
                "txhash": "240ab1369712ad2782b99a02a8f9fcaa41d1e96322017ae90d0449a3ba52a564"
            },
            {
                "timestamp": 1554880287,
                "assethash": "1aada0032aba1ef6d1f07bbd8bec1d85f5380fb3",
                "transferaddress": "AYwgBNMepiv5ocGcyNT4mA8zPLTQ8pDBis",
                "amount": "100000000000",
                "blockindex": 397769,
                "transfernotifyindex": 0,
                "txhash": "12fdf7ce8b2388d23ab223854cb29e5114d8288c878de23b7924880f82dfc834"
            }
        ],
        "received": [
            {
                "timestamp": 1555651816,
                "assethash": "600c4f5200db36177e3e8a09e9f18e2fc7d12a0f",
                "transferaddress": "AYwgBNMepiv5ocGcyNT4mA8zPLTQ8pDBis",
                "amount": "1000000",
                "blockindex": 436036,
                "transfernotifyindex": 0,
                "txhash": "df7683ece554ecfb85cf41492c5f143215dd43ef9ec61181a28f922da06aba58"
            }
        ],
        "address": "AbHgdBaWEnHkCiLtDZXjhvhaAK2cwFh5pF"
    }
}
"""
        let transfers = decodeJson(NeoGetNep17Transfers.self, from: json).nep17Transfers!
        XCTAssertEqual(transfers.sent, [
            .init(timestamp: 1554283931,
                  assetHash: try! Hash160("1aada0032aba1ef6d1f07bbd8bec1d85f5380fb3"),
                  transferAddress: "AYwgBNMepiv5ocGcyNT4mA8zPLTQ8pDBis",
                  amount: 100000000000,
                  blockIndex: 368082,
                  transferNotifyIndex: 0,
                  txHash: try! Hash256("240ab1369712ad2782b99a02a8f9fcaa41d1e96322017ae90d0449a3ba52a564")
                 ),
            .init(timestamp: 1554880287,
                  assetHash: try! Hash160("1aada0032aba1ef6d1f07bbd8bec1d85f5380fb3"),
                  transferAddress: "AYwgBNMepiv5ocGcyNT4mA8zPLTQ8pDBis",
                  amount: 100000000000,
                  blockIndex: 397769,
                  transferNotifyIndex: 0,
                  txHash: try! Hash256("12fdf7ce8b2388d23ab223854cb29e5114d8288c878de23b7924880f82dfc834"))
        ])
        XCTAssertEqual(transfers.received, [
            .init(timestamp: 1555651816,
                  assetHash: try! Hash160("600c4f5200db36177e3e8a09e9f18e2fc7d12a0f"),
                  transferAddress: "AYwgBNMepiv5ocGcyNT4mA8zPLTQ8pDBis",
                  amount: 1000000,
                  blockIndex: 436036,
                  transferNotifyIndex: 0,
                  txHash: try! Hash256("df7683ece554ecfb85cf41492c5f143215dd43ef9ec61181a28f922da06aba58"))
        ])
    }
    
    public func testGetNep17Balances() {
        let json = """
{
    "jsonrpc": "2.0",
    "id": 1,
    "result": {
        "address": "NXXazKH39yNFWWZF5MJ8tEN98VYHwzn7g3",
        "balance": [
            {
                "assethash": "a48b6e1291ba24211ad11bb90ae2a10bf1fcd5a8",
                "name": "SomeToken",
                "symbol": "SOTO",
                "decimals": "4",
                "amount": "50000000000",
                "lastupdatedblock": 251604
            },
            {
                "assethash": "1aada0032aba1ef6d1f07bbd8bec1d85f5380fb3",
                "name": "RandomToken",
                "symbol": "RATO",
                "decimals": "2",
                "amount": "100000000",
                "lastupdatedblock": 251600
            }
        ]
    }
}
"""
        let balances = decodeJson(NeoGetNep17Balances.self, from: json).balances!
        XCTAssertEqual(balances.address, "NXXazKH39yNFWWZF5MJ8tEN98VYHwzn7g3")
        XCTAssertEqual(balances.balances, [
            .init(name: "SomeToken",
                  symbol: "SOTO",
                  decimals: "4",
                  amount: "50000000000",
                  lastUpdatedBlock: 251604,
                  assetHash: try! Hash160("a48b6e1291ba24211ad11bb90ae2a10bf1fcd5a8")),
            .init(name: "RandomToken",
                  symbol: "RATO",
                  decimals: "2",
                  amount: "100000000",
                  lastUpdatedBlock: 251600,
                  assetHash: try! Hash160("1aada0032aba1ef6d1f07bbd8bec1d85f5380fb3"))
        ])
    }
    
    // MARK: ApplicationLogs
    
    public func testGetApplicationLog() {
        let json = """
{
    "jsonrpc": "2.0",
    "id": 1,
    "result": {
        "txid": "0x01bcf2edbd27abb8d660b6a06113b84d02f635fed836ce46a38b4d67eae80109",
        "executions": [
            {
                "trigger": "Application",
                "vmstate": "HALT",
                "exception": "asdf",
                "gasconsumed": "9007810",
                "stack": [
                    {
                        "type": "Integer",
                        "value": "1"
                    }
                ],
                "notifications": [
                    {
                        "contract": "0x70e2301955bf1e74cbb31d18c2f96972abadb328",
                        "eventname": "Transfer",
                        "state": {
                            "type": "Array",
                            "value": [
                                {
                                    "type": "Any"
                                },
                                {
                                    "type": "ByteString",
                                    "value": "ev0gMlXLKXK9CmqCfnTjh+0yK+w="
                                },
                                {
                                    "type": "Integer",
                                    "value": "600000000"
                                }
                            ]
                        }
                    },
                    {
                        "contract": "0xf61eebf573ea36593fd43aa150c055ad7906ab83",
                        "eventname": "Transfer",
                        "state": {
                            "type": "Array",
                            "value": [
                                {
                                    "type": "ByteString",
                                    "value": "VHJhbnNmZXI="
                                },
                                {
                                    "type": "ByteString",
                                    "value": "CaVYdMLaS4bl1J/1MKGxU+sSx9Y="
                                },
                                {
                                    "type": "Integer",
                                    "value": "100"
                                }
                            ]
                        }
                    }
                ]
            }
        ]
    }
}
"""
        let applicationLog = decodeJson(NeoGetApplicationLog.self, from: json).applicationLog!
        XCTAssertEqual(applicationLog.transactionId, try! Hash256("0x01bcf2edbd27abb8d660b6a06113b84d02f635fed836ce46a38b4d67eae80109"))
        XCTAssertEqual(applicationLog.executions[0].trigger, "Application")
        XCTAssertEqual(applicationLog.executions[0].state, .halt)
        XCTAssertEqual(applicationLog.executions[0].gasConsumed, "9007810")
        XCTAssertEqual(applicationLog.executions[0].stack, [.integer(1)])
        
        let notifications = applicationLog.executions[0].notifications
        XCTAssertEqual(notifications[0].contract, try! Hash160("0x70e2301955bf1e74cbb31d18c2f96972abadb328"))
        XCTAssertEqual(notifications[0].eventName, "Transfer")
        
        guard case .array(let list) = notifications[0].state else { return XCTFail() }
        XCTAssertNotNil(list[0])
        XCTAssertEqual(list[1].address, "NX8GreRFGFK5wpGMWetpX93HmtrezGogzk")
        XCTAssertEqual(list[2].integer, 600000000)
        
        XCTAssertEqual(notifications[1].contract, try! Hash160("0xf61eebf573ea36593fd43aa150c055ad7906ab83"))
        XCTAssertEqual(notifications[1].eventName, "Transfer")
        
        guard case .array(let list1) = notifications[1].state else { return XCTFail() }
        XCTAssertEqual(list1[0].string, "Transfer")
        XCTAssertEqual(list1[1].address, "NLnyLtep7jwyq1qhNPkwXbJpurC4jUT8ke")
        XCTAssertEqual(list1[2].integer, 100)

    }
    
    // MARK: StateService
    
    public func testGetStateRoot() {
        let json = """
{
    "jsonrpc": "2.0",
    "id": "1",
    "result": {
        "version": 0,
        "index": 160,
        "roothash": "0x28870d1ed61ef167e99354249c622504b0d81d814eaa87dbf8612c91b9b303b7",
        "witnesses": [
            {
                "invocation": "DEDN8o6cmOUt/pfRIexVzO2shhX2vTYFd+cU8vZDQ2Dvn3pe/vHcYOSlY3lPRKecb5zBuLCqaKSvZsC1FAbT00dWDEDoPojyFw66R+pKQsOy0MFmeBBgaC6Z1XGLAigVDHi2VuhAxfpwFpXSTUv3Uv5cIOY+V5g40+2zpU19YQIAWyOJDEDPfitQTjK90KnrloPXKvgTNFPn1520dxDCzQxhl/Wfp7S8dW91/3x3GrF1EaIi32aJtF8W8jUH1Spr/ma66ISs",
                "verification": "EwwhAwAqLhjDnN7Qb8Yd2UoHuOnz+gNqcFvu+HZCUpVOgtDXDCECAM1gQDlYokm5qzKbbAjI/955zDMJc2eji/a1GIEJU2EMIQKXhyDsbFxYdeA0d+FsbZj5AQhamA13R64ysGgh19j6UwwhA8klCeQozdf3pP3UqXxniRC0DxRl3d5PBJ9zJa8zgHkpFAtBE43vrw=="
            }
        ]
    }
}
"""
        let stateRoot = decodeJson(NeoGetStateRoot.self, from: json).stateRoot!
        XCTAssertEqual(stateRoot.version, 0)
        XCTAssertEqual(stateRoot.index, 160)
        XCTAssertEqual(stateRoot.rootHash, try! Hash256("0x28870d1ed61ef167e99354249c622504b0d81d814eaa87dbf8612c91b9b303b7"))
        XCTAssertEqual(stateRoot.witnesses, [
            .init(
                "DEDN8o6cmOUt/pfRIexVzO2shhX2vTYFd+cU8vZDQ2Dvn3pe/vHcYOSlY3lPRKecb5zBuLCqaKSvZsC1FAbT00dWDEDoPojyFw66R+pKQsOy0MFmeBBgaC6Z1XGLAigVDHi2VuhAxfpwFpXSTUv3Uv5cIOY+V5g40+2zpU19YQIAWyOJDEDPfitQTjK90KnrloPXKvgTNFPn1520dxDCzQxhl/Wfp7S8dW91/3x3GrF1EaIi32aJtF8W8jUH1Spr/ma66ISs",
                "EwwhAwAqLhjDnN7Qb8Yd2UoHuOnz+gNqcFvu+HZCUpVOgtDXDCECAM1gQDlYokm5qzKbbAjI/955zDMJc2eji/a1GIEJU2EMIQKXhyDsbFxYdeA0d+FsbZj5AQhamA13R64ysGgh19j6UwwhA8klCeQozdf3pP3UqXxniRC0DxRl3d5PBJ9zJa8zgHkpFAtBE43vrw=="
            )])
    }
    
    public func testGetProof() {
        let json = """
{
    "jsonrpc": "2.0",
    "id": "1",
    "result": "Bfv///8XBiQBAQ8DRzb6Vkdw0r5nxMBp6Z5nvbyXiupMvffwm0v5GdB6jHvyAAQEBAQEBAQEA7l84HFtRI5V11s58vA+8CZ5GArFLkGUYLO98RLaMaYmA5MEnx0upnVI45XTpoUDRvwrlPD59uWy9aIrdS4T0D2cA6Rwv/l3GmrctRzL1me+iTUFdDgooaz+esFHFXJdDANfA2bdshZMp5ox2goVAOMjvoxNIWWOqjJoRPu6ZOw2kdj6A8xovEK1Mp6cAG9z/jfFDrSEM60kuo97MNaVOP/cDZ1wA1nf4WdI+jksYz0EJgzBukK8rEzz8jE2cb2Zx2fytVyQBANC7v2RaLMCRF1XgLpSri12L2IwL9Zcjz5LZiaB5nHKNgQpAQYPDw8PDw8DggFffnsVMyqAfZjg+4gu97N/gKpOsAK8Q27s56tijRlSAAMm26DYxOdf/IjEgkE/u/CoRL6dDnzvs1dxCg/00esMvgPGioeOqQCkDOTfliOnCxYjbY/0XvVUOXkceuDm1W0FzQQEBAQEBAQEBAQEBAQEBJIABAPH1PnX/P8NOgV4KHnogwD7xIsD8KvNhkTcDxgCo7Ec6gPQs1zD4igSJB4M9jTREq+7lQ5PbTH/6d138yUVvtM8bQP9Df1kh7asXrYjZolKhLcQ1NoClQgEzbcJfYkCHXv6DQQEBAOUw9zNl/7FJrWD7rCv0mbOoy6nLlHWiWuyGsA12ohRuAQEBAQEBAQEBAYCBAIAAgA="
}
"""
        XCTAssertEqual(decodeJson(NeoGetProof.self, from: json).proof,
                       "Bfv///8XBiQBAQ8DRzb6Vkdw0r5nxMBp6Z5nvbyXiupMvffwm0v5GdB6jHvyAAQEBAQEBAQEA7l84HFtRI5V11s58vA+8CZ5GArFLkGUYLO98RLaMaYmA5MEnx0upnVI45XTpoUDRvwrlPD59uWy9aIrdS4T0D2cA6Rwv/l3GmrctRzL1me+iTUFdDgooaz+esFHFXJdDANfA2bdshZMp5ox2goVAOMjvoxNIWWOqjJoRPu6ZOw2kdj6A8xovEK1Mp6cAG9z/jfFDrSEM60kuo97MNaVOP/cDZ1wA1nf4WdI+jksYz0EJgzBukK8rEzz8jE2cb2Zx2fytVyQBANC7v2RaLMCRF1XgLpSri12L2IwL9Zcjz5LZiaB5nHKNgQpAQYPDw8PDw8DggFffnsVMyqAfZjg+4gu97N/gKpOsAK8Q27s56tijRlSAAMm26DYxOdf/IjEgkE/u/CoRL6dDnzvs1dxCg/00esMvgPGioeOqQCkDOTfliOnCxYjbY/0XvVUOXkceuDm1W0FzQQEBAQEBAQEBAQEBAQEBJIABAPH1PnX/P8NOgV4KHnogwD7xIsD8KvNhkTcDxgCo7Ec6gPQs1zD4igSJB4M9jTREq+7lQ5PbTH/6d138yUVvtM8bQP9Df1kh7asXrYjZolKhLcQ1NoClQgEzbcJfYkCHXv6DQQEBAOUw9zNl/7FJrWD7rCv0mbOoy6nLlHWiWuyGsA12ohRuAQEBAQEBAQEBAYCBAIAAgA=")
    }
    
    public func testVerifyProof() {
        let json = """
{
    "jsonrpc": "2.0",
    "id": 1,
    "result": "QAFBAighAhY5RqEz49Lg2Yf7kMsBsGDtF4DxcY4too7fE7ll/StgIQA="
}
"""
        XCTAssertEqual(decodeJson(NeoVerifyProof.self, from: json).verifyProof!, "QAFBAighAhY5RqEz49Lg2Yf7kMsBsGDtF4DxcY4too7fE7ll/StgIQA=")
    }
    
    public func testGetStateHeight() {
        let json = """
{
    "jsonrpc": "2.0",
    "id": 1,
    "result": {
        "localrootindex": 212,
        "validatedrootindex": 211
    }
}
"""
        let stateHeight = decodeJson(NeoGetStateHeight.self, from: json).stateHeight!
        XCTAssertEqual(stateHeight.localRootIndex, 212)
        XCTAssertEqual(stateHeight.validatedRootIndex, 211)
    }
    
    public func testGetState() {
        let json = """
{
    "jsonrpc": "2.0",
    "id": 1,
    "result": "QQEhBwAA1VhfeRI="
}
"""
        XCTAssertEqual(decodeJson(NeoGetState.self, from: json).state!, "QQEhBwAA1VhfeRI=")
    }
    
    public func testFindStates() {
        let json = """
{
    "jsonrpc": "2.0",
    "id": 1,
    "result": {
        "firstProof": "Gfr///8UDRZcmJnDi79ZkcXkewSTcljK7GkIJAEBDwOakA9CYtxDPpx00gKk0RCLmrtNtpTsY2rXB/RqfGHIPLIABAQEBAQEBAMe+jlFz2/5ZKl+ycxczvmS75mO9ssmFZef+WHov7XIHQQDiT6zHh/siCZ0c2bfBEymPmRNTiXSAKFIammjmnnBnJYDh0IX5YfZdqNZkfFN/6VaLZ6kX+N+bBGdlNVUyP7pwJ4DrpFUvhWA+kXVxDLE8qKtLcQimKQY1RcWw14bsjURuRYEBAQDsyA6/WuQyV98xH99kDVz3bhQHmUNBIQqJd0x0R/+TGwEKQEGDw8PDw8PAzKhCJmqIIilFwEfMQJDUEMXInq+AbRk8Jfnoi1weu8aUgADo6udX84sFVzKZLdtwtJ6TIMgQOrYZQ+7yKG+5TlliscDzboXdiwLKASBJeAVtNTl7NHqclD6UBe4XrwJQQYJIDQEBAQEBAQEBAQEBAQEBAQkAQEEA6pd1tKBerO8Qub4cvuKEpXDlGCJsktZ4Vk0xT+D6Av5UgADBr2ExYHjKsB15w2Ra40oWm7iPwdhWEVf6nHV6St/W8gEBAQEBAQDufefqjG8jPxPHOFpyF8LE16aXEzlFeuts4vaQ+wGCL4EBAQEBAQEBARKAScNAQYFDAkICQkMAwgLCw8FCQkBDAUOBAcLAAQJAwcCBQgMCg4MBgkDzXuGD6B7eZe7+IxNOv1j48vZn5A9qz4nzzvdSqSQRr8LAglBASEFACrPdwI=",
        "lastProof": "Gfr///8Uf2XUNDYnCLJV8OBoVr3LXOmdhQUIJAEBDwOakA9CYtxDPpx00gKk0RCLmrtNtpTsY2rXB/RqfGHIPLIABAQEBAQEBAMe+jlFz2/5ZKl+ycxczvmS75mO9ssmFZef+WHov7XIHQQDiT6zHh/siCZ0c2bfBEymPmRNTiXSAKFIammjmnnBnJYDh0IX5YfZdqNZkfFN/6VaLZ6kX+N+bBGdlNVUyP7pwJ4DrpFUvhWA+kXVxDLE8qKtLcQimKQY1RcWw14bsjURuRYEBAQDsyA6/WuQyV98xH99kDVz3bhQHmUNBIQqJd0x0R/+TGwEKQEGDw8PDw8PAzKhCJmqIIilFwEfMQJDUEMXInq+AbRk8Jfnoi1weu8aUgADo6udX84sFVzKZLdtwtJ6TIMgQOrYZQ+7yKG+5TlliscDzboXdiwLKASBJeAVtNTl7NHqclD6UBe4XrwJQQYJIDQEBAQEBAQEBAQEBAQEBAQkAQEEA6pd1tKBerO8Qub4cvuKEpXDlGCJsktZ4Vk0xT+D6Av5UgADBr2ExYHjKsB15w2Ra40oWm7iPwdhWEVf6nHV6St/W8gEBAQEBAQDufefqjG8jPxPHOFpyF8LE16aXEzlFeuts4vaQ+wGCL4EBAQEBAQEBARKAScPBgUNBAMEAwYCBwAICwIFBQ8ADgAGCAUGCw0MCwUMDgkJDQgFAAUDkvma2Sek54h+A0fdKAxoUjETufDdw3bX/Crnad92qPUNAgtBASEHAADVWF95Eg==",
        "truncated": false,
        "results": [
            {
                "key": "FA0WXJiZw4u/WZHF5HsEk3JYyuxp",
                "value": "QQEhBQAqz3cC"
            },
            {
                "key": "FH9l1DQ2JwiyVfDgaFa9y1zpnYUF",
                "value": "QQEhBwAA1VhfeRI="
            }
        ]
    }
}
"""
        let states = decodeJson(NeoFindStates.self, from: json).states!
        
        let firstProof = "Gfr///8UDRZcmJnDi79ZkcXkewSTcljK7GkIJAEBDwOakA9CYtxDPpx00gKk0RCLmrtNtpTsY2rXB/RqfGHIPLIABAQEBAQEBAMe+jlFz2/5ZKl+ycxczvmS75mO9ssmFZef+WHov7XIHQQDiT6zHh/siCZ0c2bfBEymPmRNTiXSAKFIammjmnnBnJYDh0IX5YfZdqNZkfFN/6VaLZ6kX+N+bBGdlNVUyP7pwJ4DrpFUvhWA+kXVxDLE8qKtLcQimKQY1RcWw14bsjURuRYEBAQDsyA6/WuQyV98xH99kDVz3bhQHmUNBIQqJd0x0R/+TGwEKQEGDw8PDw8PAzKhCJmqIIilFwEfMQJDUEMXInq+AbRk8Jfnoi1weu8aUgADo6udX84sFVzKZLdtwtJ6TIMgQOrYZQ+7yKG+5TlliscDzboXdiwLKASBJeAVtNTl7NHqclD6UBe4XrwJQQYJIDQEBAQEBAQEBAQEBAQEBAQkAQEEA6pd1tKBerO8Qub4cvuKEpXDlGCJsktZ4Vk0xT+D6Av5UgADBr2ExYHjKsB15w2Ra40oWm7iPwdhWEVf6nHV6St/W8gEBAQEBAQDufefqjG8jPxPHOFpyF8LE16aXEzlFeuts4vaQ+wGCL4EBAQEBAQEBARKAScNAQYFDAkICQkMAwgLCw8FCQkBDAUOBAcLAAQJAwcCBQgMCg4MBgkDzXuGD6B7eZe7+IxNOv1j48vZn5A9qz4nzzvdSqSQRr8LAglBASEFACrPdwI="
        
        let lastProof = "Gfr///8Uf2XUNDYnCLJV8OBoVr3LXOmdhQUIJAEBDwOakA9CYtxDPpx00gKk0RCLmrtNtpTsY2rXB/RqfGHIPLIABAQEBAQEBAMe+jlFz2/5ZKl+ycxczvmS75mO9ssmFZef+WHov7XIHQQDiT6zHh/siCZ0c2bfBEymPmRNTiXSAKFIammjmnnBnJYDh0IX5YfZdqNZkfFN/6VaLZ6kX+N+bBGdlNVUyP7pwJ4DrpFUvhWA+kXVxDLE8qKtLcQimKQY1RcWw14bsjURuRYEBAQDsyA6/WuQyV98xH99kDVz3bhQHmUNBIQqJd0x0R/+TGwEKQEGDw8PDw8PAzKhCJmqIIilFwEfMQJDUEMXInq+AbRk8Jfnoi1weu8aUgADo6udX84sFVzKZLdtwtJ6TIMgQOrYZQ+7yKG+5TlliscDzboXdiwLKASBJeAVtNTl7NHqclD6UBe4XrwJQQYJIDQEBAQEBAQEBAQEBAQEBAQkAQEEA6pd1tKBerO8Qub4cvuKEpXDlGCJsktZ4Vk0xT+D6Av5UgADBr2ExYHjKsB15w2Ra40oWm7iPwdhWEVf6nHV6St/W8gEBAQEBAQDufefqjG8jPxPHOFpyF8LE16aXEzlFeuts4vaQ+wGCL4EBAQEBAQEBARKAScPBgUNBAMEAwYCBwAICwIFBQ8ADgAGCAUGCw0MCwUMDgkJDQgFAAUDkvma2Sek54h+A0fdKAxoUjETufDdw3bX/Crnad92qPUNAgtBASEHAADVWF95Eg=="
        
        XCTAssertEqual(states, .init(firstProof: firstProof, lastProof: lastProof, truncated: false, results: [
            .init(key: "FA0WXJiZw4u/WZHF5HsEk3JYyuxp", value: "QQEhBQAqz3cC"),
            .init(key: "FH9l1DQ2JwiyVfDgaFa9y1zpnYUF", value: "QQEhBwAA1VhfeRI=")
        ]))
    }

    public func testFindStatesSingle() {
        let json = """
{
    "jsonrpc": "2.0",
    "id": 1,
    "result": {
        "firstProof": "Bfr///8LBiQBAQ8DqDawCFNqYkkQC+no3z6WbmuP8DJmy9e4MMK+QzHITdGyAAQEBAQEBAQDHvo5Rc9v+WSpfsnMXM75ku+ZjvbLJhWXn/lh6L+1yB0EA4k+sx4f7IgmdHNm3wRMpj5kTU4l0gChSGppo5p5wZyWA7QRkH8fw1R6WnCQfRWk96ZKPBPSeOU+gvwQuwjznHjfA66RVL4VgPpF1cQyxPKirS3EIpikGNUXFsNeG7I1EbkWBAQEA7MgOv1rkMlffMR/fZA1c924UB5lDQSEKiXdMdEf/kxsBCkBBg8PDw8PDwMJqhMyRWjael2lcsob2BXims/yMjMrrSkkWY/MsReC7lIAAzP6dmF3DTZHkfcXYHO6On6KQucSwUv9UryMqImoBKrLA27ebHC45rpr3EGcLJ7D7EAm/JihcES3pIzYVxgh6hSrBAQEBAQEBAQEBAQEBAQEJAEBCwMWm2J/uEa8sf+ET9RUiBXqOLuLQ/dr4V494mGlwcp9DAkCBwCY0uJieRI=",
        "truncated": true,
        "results": [
            {
                "key": "Cw==",
                "value": "AJjS4mJ5Eg=="
            }
        ]
    }
}
"""
        let states = decodeJson(NeoFindStates.self, from: json).states!
        
        let firstProof = "Bfr///8LBiQBAQ8DqDawCFNqYkkQC+no3z6WbmuP8DJmy9e4MMK+QzHITdGyAAQEBAQEBAQDHvo5Rc9v+WSpfsnMXM75ku+ZjvbLJhWXn/lh6L+1yB0EA4k+sx4f7IgmdHNm3wRMpj5kTU4l0gChSGppo5p5wZyWA7QRkH8fw1R6WnCQfRWk96ZKPBPSeOU+gvwQuwjznHjfA66RVL4VgPpF1cQyxPKirS3EIpikGNUXFsNeG7I1EbkWBAQEA7MgOv1rkMlffMR/fZA1c924UB5lDQSEKiXdMdEf/kxsBCkBBg8PDw8PDwMJqhMyRWjael2lcsob2BXims/yMjMrrSkkWY/MsReC7lIAAzP6dmF3DTZHkfcXYHO6On6KQucSwUv9UryMqImoBKrLA27ebHC45rpr3EGcLJ7D7EAm/JihcES3pIzYVxgh6hSrBAQEBAQEBAQEBAQEBAQEJAEBCwMWm2J/uEa8sf+ET9RUiBXqOLuLQ/dr4V494mGlwcp9DAkCBwCY0uJieRI="
        
        XCTAssertEqual(states.firstProof, firstProof)
        XCTAssertNil(states.lastProof)
        XCTAssertEqual(states.results.count, 1)
        
    }
    
    public func testFindStatesEmpty() {
        let json = """
{
    "jsonrpc": "2.0",
    "id": 1,
    "result": {
        "truncated": true,
        "results": []
    }
}
"""
        let states = decodeJson(NeoFindStates.self, from: json).states!
        XCTAssertNil(states.firstProof)
        XCTAssertNil(states.lastProof)
        XCTAssert(states.truncated)
        XCTAssert(states.results.isEmpty)
    }
    
    // MARK: Neo-express
    
    public func testExpressGetPopulatedBlocks() {
        let json = """
{
    "jsonrpc": "2.0",
    "id": 1,
    "result": {
        "cacheId": "637613615288087170",
        "blocks": [
            1129,
            1127,
            0
        ]
    }
}
"""
        let populatedBlocks = decodeJson(NeoExpressGetPopulatedBlocks.self, from: json).populatedBlocks!
        XCTAssertEqual(populatedBlocks.cacheId, "637613615288087170")
        XCTAssertEqual(populatedBlocks.blocks, [1129, 1127, 0])
    }
    
    public func testExpressGetNep17Contracts() {
        let json = """
{
    "jsonrpc": "2.0",
    "id": 1,
    "result": [
        {
            "scriptHash": "0xef4073a0f2b305a38ec4050e4d3d28bc40ea63f5",
            "symbol": "NEO",
            "decimals": 0
        },
        {
            "scriptHash": "0xd2a4cff31913016155e38e474a2c06d08be276cf",
            "symbol": "GAS",
            "decimals": 8
        }
    ]
}
"""
        let nep17Contracts = decodeJson(NeoExpressGetNep17Contracts.self, from: json).nep17Contracts!
        XCTAssertEqual(nep17Contracts, [
            .init(scriptHash: try! Hash160("0xef4073a0f2b305a38ec4050e4d3d28bc40ea63f5"),
                  symbol: "NEO", decimals: 0),
            .init(scriptHash: try! Hash160("0xd2a4cff31913016155e38e474a2c06d08be276cf"),
                  symbol: "GAS", decimals: 8)
        ])
    }
    
    public func testGetContractStorage() {
        let json = """
{
    "jsonrpc": "2.0",
    "id": 1,
    "result": [
        {
            "key": "01",
            "value": ""
        },
        {
            "key": "0b",
            "value": "00e1f505"
        },
        {
            "key": "0d",
            "value": "00e8764817"
        },
        {
            "key": "0e",
            "value": "40014102282102c2f3870c8805f83881e93cddaac2b2130ad4a2ca44a327ac64e18322862b19ee2100"
        },
        {
            "key": "14b65d362f086196286c2cd6868afbe0cf75f732a3",
            "value": "4103210400e1f505210000"
        },
        {
            "key": "1d00000000",
            "value": "0065cd1d"
        }
    ]
}
"""
        let contractStorage = decodeJson(NeoExpressGetContractStorage.self, from: json).contractStorage!
        XCTAssertEqual(contractStorage.count, 6)
        
        let storage3 = contractStorage[2]
        XCTAssertEqual(storage3.key, "0d")
        XCTAssertEqual(storage3.value, "00e8764817")
        
        let storage6 = contractStorage[5]
        XCTAssertEqual(storage6.key, "1d00000000")
        XCTAssertEqual(storage6.value, "0065cd1d")

    }
    
    public func testEcpressCreateCheckpoint() {
        let json = """
{
    "jsonrpc": "2.0",
    "id": 1,
    "result": "checkpoint-1.neoxp-checkpoint"
}
"""
        XCTAssertEqual(decodeJson(NeoExpressCreateCheckpoint.self, from: json).filename!, "checkpoint-1.neoxp-checkpoint")
    }
    
    public func testExpressListOracleRequests() {
        let json = """
{
    "jsonrpc": "2.0",
    "id": 1,
    "result": [
        {
            "requestid": 0,
            "originaltxid": "0x0b2327b9c4a6445a3e1d85ae9f99184a9cf5d7234602be54800057968332180a",
            "gasforresponse": 1000000000,
            "url": "https://www.neow3j.io",
            "filter": "$.nftinfo",
            "callbackcontract": "0xf18a0ccda4947ba1cbeaf5a7f579c385ed2cf87f",
            "callbackmethod": "storeResponse",
            "userdata": "KAA="
        }
    ]
}
"""
        let oracleRequests = decodeJson(NeoExpressListOracleRequests.self, from: json).oracleRequests!
        XCTAssertEqual(oracleRequests.first, .init(requestId: 0,
                                                   originalTransactionHash: try! Hash256("0x0b2327b9c4a6445a3e1d85ae9f99184a9cf5d7234602be54800057968332180a"),
                                                   gasForResponse: 1000000000,
                                                   url: "https://www.neow3j.io",
                                                   filter: "$.nftinfo",
                                                   callbackContract: try! Hash160("0xf18a0ccda4947ba1cbeaf5a7f579c385ed2cf87f"),
                                                   callbackMethod: "storeResponse",
                                                   userData: "KAA="))
    }
    
    public func testExpressCreateOracleResponseTx() {
        let json = """
{
    "jsonrpc": "2.0",
    "id": 1,
    "result": "AAAAAAD+KXk7AAAAAAKgIQAAAAAA5BcAAAJYhxcRfgqoEHKvq3HS3Yn+fEuS/gDWpJ16ac8mblfxSXP0i4whCH8cRgABEQAAAAAAAAAAAAZuZW93M2olwh8MBmZpbmlzaAwUWIcXEX4KqBByr6tx0t2J/nxLkv5BYn1bUgIAAAAqEQwhAmB6OLgBCo9AHCXdAd8bdK8YJ90WuCH8B0UfLvfwLaYPEUGe0Nw6"
}
"""
        let oracleResponseTx = decodeJson(NeoExpressCreateOracleResponseTx.self, from: json).oracleResponseTx
        XCTAssertEqual(oracleResponseTx, "AAAAAAD+KXk7AAAAAAKgIQAAAAAA5BcAAAJYhxcRfgqoEHKvq3HS3Yn+fEuS/gDWpJ16ac8mblfxSXP0i4whCH8cRgABEQAAAAAAAAAAAAZuZW93M2olwh8MBmZpbmlzaAwUWIcXEX4KqBByr6tx0t2J/nxLkv5BYn1bUgIAAAAqEQwhAmB6OLgBCo9AHCXdAd8bdK8YJ90WuCH8B0UfLvfwLaYPEUGe0Nw6")
    }
    
    public func testExpressShutdown() {
        let json = """
{
    "jsonrpc": "2.0",
    "id": 1,
    "result": {
        "process-id": 73625
    }
}
"""
        XCTAssertEqual(decodeJson(NeoExpressShutdown.self, from: json).expressShutdown?.processId, 73625)
    }
    
    // TokenTracker: Nep11
    
    public func testGetNep11Balances() {
        let json = """
{
    "jsonrpc": "2.0",
    "id": 1,
    "result": {
        "address": "NXXazKH39yNFWWZF5MJ8tEN98VYHwzn7g3",
        "balance": [
            {
                "assethash": "a48b6e1291ba24211ad11bb90ae2a10bf1fcd5a8",
                "name": "FunnyCats",
                "symbol": "FCS",
                "decimals": "0",
                "tokens": [
                    {
                        "tokenid": "1",
                        "amount": "1",
                        "lastupdatedblock": 12345
                    },
                    {
                        "tokenid": "2",
                        "amount": "1",
                        "lastupdatedblock": 123456
                    }
                ]
            },
            {
                "assethash": "1aada0032aba1ef6d1f07bbd8bec1d85f5380fb3",
                "name": "CuteNeoKittens",
                "symbol": "CNKS",
                "decimals": "4",
                "tokens": [
                    {
                        "tokenid": "4",
                        "amount": "10000",
                        "lastupdatedblock": 12345
                    },
                    {
                        "tokenid": "10",
                        "amount": "6500",
                        "lastupdatedblock": 654321
                    }
                ]
            }
        ]
    }
}
"""
        let balances = decodeJson(NeoGetNep11Balances.self, from: json).balances!
        XCTAssertEqual(balances.address, "NXXazKH39yNFWWZF5MJ8tEN98VYHwzn7g3")
        XCTAssertEqual(balances.balances, [
            .init(name: "FunnyCats",
                  symbol: "FCS",
                  decimals: "0",
                  tokens: [
                    .init(tokenId: "1", amount: "1", lastUpdatedBlock: 12345),
                    .init(tokenId: "2", amount: "1", lastUpdatedBlock: 123456)
                  ],
                  assetHash: try! Hash160("a48b6e1291ba24211ad11bb90ae2a10bf1fcd5a8")),
            .init(name: "CuteNeoKittens",
                  symbol: "CNKS",
                  decimals: "4",
                  tokens: [
                    .init(tokenId: "4", amount: "10000", lastUpdatedBlock: 12345),
                    .init(tokenId: "10", amount: "6500", lastUpdatedBlock: 654321)
                  ],
                  assetHash: try! Hash160("1aada0032aba1ef6d1f07bbd8bec1d85f5380fb3"))
        ])
    }
    
    public func testGetNep11Transfers() {
        let json = "{\n" +
        "    \"jsonrpc\": \"2.0\",\n" +
        "    \"id\": 1,\n" +
        "    \"result\": {\n" +
        "        \"sent\": [\n" +
        "            {\n" +
        "                \"tokenid\": \"1\",\n" +
        "                \"timestamp\": 1554283931,\n" +
        "                \"assethash\": \"1aada0032aba1ef6d1f07bbd8bec1d85f5380fb3\",\n" +
        "                \"transferaddress\": \"AYwgBNMepiv5ocGcyNT4mA8zPLTQ8pDBis\",\n" +
        "                \"amount\": \"100000000000\",\n" +
        "                \"blockindex\": 368082,\n" +
        "                \"transfernotifyindex\": 0,\n" +
        "                \"txhash\": \"240ab1369712ad2782b99a02a8f9fcaa41d1e96322017ae90d0449a3ba52a564\"\n" +
        "            },\n" +
        "            {\n" +
        "                \"tokenid\": \"2\",\n" +
        "                \"timestamp\": 1554880287,\n" +
        "                \"assethash\": \"1aada0032aba1ef6d1f07bbd8bec1d85f5380fb3\",\n" +
        "                \"transferaddress\": \"AYwgBNMepiv5ocGcyNT4mA8zPLTQ8pDBis\",\n" +
        "                \"amount\": \"100000000000\",\n" +
        "                \"blockindex\": 397769,\n" +
        "                \"transfernotifyindex\": 0,\n" +
        "                \"txhash\": \"12fdf7ce8b2388d23ab223854cb29e5114d8288c878de23b7924880f82dfc834\"\n" +
        "            }\n" +
        "        ],\n" +
        "        \"received\": [\n" +
        "            {\n" +
        "                \"tokenid\": \"3\",\n" +
        "                \"timestamp\": 1555651816,\n" +
        "                \"assethash\": \"600c4f5200db36177e3e8a09e9f18e2fc7d12a0f\",\n" +
        "                \"transferaddress\": \"AYwgBNMepiv5ocGcyNT4mA8zPLTQ8pDBis\",\n" +
        "                \"amount\": \"1000000\",\n" +
        "                \"blockindex\": 436036,\n" +
        "                \"transfernotifyindex\": 0,\n" +
        "                \"txhash\": \"df7683ece554ecfb85cf41492c5f143215dd43ef9ec61181a28f922da06aba58\"\n" +
        "            }\n" +
        "        ],\n" +
        "        \"address\": \"AbHgdBaWEnHkCiLtDZXjhvhaAK2cwFh5pF\"\n" +
        "    }\n" +
        "}"
        let transfers = decodeJson(NeoGetNep11Transfers.self, from: json).nep11Transfers!
        XCTAssertEqual(transfers.sent, [
            .init(tokenId: "1",
                  timestamp: 1554283931,
                  assetHash: try! Hash160("1aada0032aba1ef6d1f07bbd8bec1d85f5380fb3"),
                  transferAddress: "AYwgBNMepiv5ocGcyNT4mA8zPLTQ8pDBis",
                  amount: 100000000000,
                  blockIndex: 368082,
                  transferNotifyIndex: 0,
                  txHash: try! Hash256("240ab1369712ad2782b99a02a8f9fcaa41d1e96322017ae90d0449a3ba52a564")),
            .init(tokenId: "2",
                  timestamp: 1554880287,
                  assetHash: try! Hash160("1aada0032aba1ef6d1f07bbd8bec1d85f5380fb3"),
                  transferAddress: "AYwgBNMepiv5ocGcyNT4mA8zPLTQ8pDBis",
                  amount: 100000000000,
                  blockIndex: 397769,
                  transferNotifyIndex: 0,
                  txHash: try! Hash256("12fdf7ce8b2388d23ab223854cb29e5114d8288c878de23b7924880f82dfc834"))
        ])
        
        XCTAssertEqual(transfers.received, [
            .init(tokenId: "3",
                  timestamp: 1555651816,
                  assetHash: try! Hash160("600c4f5200db36177e3e8a09e9f18e2fc7d12a0f"),
                  transferAddress: "AYwgBNMepiv5ocGcyNT4mA8zPLTQ8pDBis",
                  amount: 1000000,
                  blockIndex: 436036,
                  transferNotifyIndex: 0,
                  txHash: try! Hash256("df7683ece554ecfb85cf41492c5f143215dd43ef9ec61181a28f922da06aba58"))
        ])
    }

    public func testGetNep11Properties() {
        let json = """
{
    "jsonrpc": "2.0",
    "id": 1,
    "result": {
        "keyProp1": "valueProp1",
        "keyProp2": "valueProp2"
    }
}
"""
        let properties = decodeJson(NeoGetNep11Properties.self, from: json).properties!
        XCTAssertEqual(properties, [
            "keyProp1" : "valueProp1",
            "keyProp2" : "valueProp2"
        ])
        
    }
    
    private func decodeJson<T: Decodable>(_ type: T.Type, from json: String) -> T {
        return try! JSONDecoder().decode(type, from: json.data(using: .utf8)!)
    }
    
}
