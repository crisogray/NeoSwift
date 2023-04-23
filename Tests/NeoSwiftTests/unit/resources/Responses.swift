
// MARK: NEP-17 Balances

let nep17BalancesOfDefaultAccountJson = """
{
  "jsonrpc": "2.0",
  "id": 1,
  "result": {
    "balance": [
      {
        "assethash": "0xd2a4cff31913016155e38e474a2c06d08be276cf",
        "amount": "300000000",
        "lastupdatedblock": 1091
      },
      {
        "assethash": "0xef4073a0f2b305a38ec4050e4d3d28bc40ea63f5",
        "amount": "5",
        "lastupdatedblock": 1337
      }
    ],
    "address": "NUrPrFLETzoe7N2FLi2dqTvLwc9L2Em84K"
  }
}
"""

let nep17BalancesOfCommitteeAccountJson = """
{
  "jsonrpc": "2.0",
  "id": 1,
  "result": {
    "balance": [
      {
        "assethash": "0xd2a4cff31913016155e38e474a2c06d08be276cf",
        "amount": "410985799730",
        "lastupdatedblock": 1337
      },
      {
        "assethash": "0xef4073a0f2b305a38ec4050e4d3d28bc40ea63f5",
        "amount": "49999995",
        "lastupdatedblock": 1337
      }
    ],
    "address": "NWcx4EfYdfqn5jNjDz8AHE6hWtWdUGDdmy"
  }
}
"""

// MARK: Invoke Script

let invokeScriptNecessaryMockJson = """
{
  "jsonrpc": "2.0",
  "id": 1,
  "result": {
    "script": "AQID",
    "state": "HALT",
    "gasconsumed": "30",
    "exception": null,
    "stack": [
      {
        "type": "Integer",
        "value": "770"
      }
    ]
  }
}
"""

let invokeScriptSymbolNeoJson = """
{
  "jsonrpc": "2.0",
  "id": 1,
  "result": {
    "script": "wh8MBnN5bWJvbAwUg6sGea1VwFChOtQ/WTbqc/XrHvZBYn1bUg==",
    "state": "HALT",
    "gasconsumed": "984060",
    "exception": null,
    "stack": [
      {
        "type": "ByteString",
        "value": "TkVP"
      }
    ]
  }
}
"""

let invokeScriptTransferFixedSysFeeJson = """
{
  "jsonrpc": "2.0",
  "id": 1,
  "result": {
    "script": "CxUMFJQTQyOSE/oOdl8QJ850L0jbd5qWDBQGSl3MDxYsg0c9Aok46V+3dhMechTAHwwIdHJhbnNmZXIMFIOrBnmtVcBQoTrUP1k26nP16x72QWJ9W1I=",
    "state": "HALT",
    "gasconsumed": "9999510",
    "exception": null,
    "stack": [
      {
        "type": "Boolean",
        "value": false
      }
    ]
  }
}
"""

let invokeScriptInvalidJson = """
{
  "jsonrpc": "2.0",
  "id": 1,
  "result": {
    "script": "DAASDBSTrRVy",
    "state": "FAULT",
    "gasconsumed": "270",
    "exception": "Instruction out of bounds. InstructionPointer: 5, operandSize: 20, length: 9",
    "stack": []
  }
}
"""

let invokeScriptExceptionJson = """
{
  "jsonrpc": "2.0",
  "id": 1,
  "result": {
    "script": "DA5PcmFjbGVDb250cmFjdEEa93tn",
    "state": "FAULT",
    "gasconsumed": "240",
    "exception": "Value was either too large or too small for an Int32.",
    "stack": []
  }
}
"""

let invokeScriptTransferJson = """
{
  "jsonrpc": "2.0",
  "id": 1,
  "result": {
    "script": "CxEMFJQTQyOSE/oOdl8QJ850L0jbd5qWDBSDOdNlxQku4D3i0slAfRw+a1KXlxTAHwwIdHJhbnNmZXIMFIOrBnmtVcBQoTrUP1k26nP16x72QWJ9W1I=",
    "state": "HALT",
    "gasconsumed": "9999510",
    "exception": null,
    "stack": [
      {
        "type": "Boolean",
        "value": false
      }
    ]
  }
}
"""

let invokeScriptFaultJson = """
{
  "jsonrpc": "2.0",
  "id": 1,
  "result": {
    "script": "wh8MCWJhbGFuY2VPZgwU9WPqQLwoPU0OBcSOowWz8qBzQO9BYn1bUg==",
    "state": "FAULT",
    "gasconsumed": "984030",
    "exception": "Method \\"balanceOf\\" with 0 parameter(s) doesn't exist in the contract 0xef4073a0f2b305a38ec4050e4d3d28bc40ea63f5.",
    "notifications": [],
    "stack": []
  }
}
"""

// MARK: Invoke Function

let invokeFunctionTransferNeoJson = """
{
  "jsonrpc": "2.0",
  "id": 1,
  "result": {
    "script": "CxUMFJQTQyOSE/oOdl8QJ850L0jbd5qWDBQGSl3MDxYsg0c9Aok46V+3dhMechTAHwwIdHJhbnNmZXIMFIOrBnmtVcBQoTrUP1k26nP16x72QWJ9W1I=",
    "state": "HALT",
    "gasconsumed": "9999510",
    "exception": null,
    "stack": [
      {
        "type": "Boolean",
        "value": true
      }
    ]
  }
}
"""

let invokeFunctionBalanceOf1000000 = """
{
  "jsonrpc": "2.0",
  "id": 1,
  "result": {
    "script": "DBQGSl3MDxYsg0c9Aok46V+3dhMechHAHwwJYmFsYW5jZU9mDBQos62rcmn5whgds8t0Hr9VGTDicEFifVtS",
    "state": "HALT",
    "gasconsumed": "1999210",
    "exception": null,
    "stack": [
      {
        "type": "Integer",
        "value": "1000000"
      }
    ]
  }
}
"""

// MARK: Calculate Network Fee

let calculateNetworkFeeJson = """
{
  "jsonrpc": "2.0",
  "id": 1,
  "result": {
    "networkfee": 1230610
  }
}
"""

// MARK: Get Block Count

let getBlockCountJson_1000 = """
{
  "jsonrpc": "2.0",
  "id": 1,
  "result": 1000
}
"""

// MARK: Get Committee

let getCommitteeJson = """
{
  "jsonrpc": "2.0",
  "id": 1,
  "result": [
    "02c0b60c995bc092e866f15a37c176bb59b7ebacf069ba94c0ebf561cb8f956238"
  ]
}
"""

// MARK: Send Raw Transaction

let sendRawTransactionJson = """
{
  "jsonrpc": "2.0",
  "id": 1,
  "result": {
    "hash": "0x830816f0c801bcabf919dfa1a90d7b9a4f867482cb4d18d0631a5aa6daefab6a"
  }
}
"""

// MARK: Get Application Log

let getApplicationLogJson = """
{
  "jsonrpc": "2.0",
  "id": 1,
  "result": {
    "txid": "0xeb52f99ae5cf923d8905bdd91c4160e2207d20c0cb42f8062f31c6743770e4d1",
    "executions": [
      {
        "trigger": "Application",
        "vmstate": "HALT",
        "exception": null,
        "gasconsumed": "9007990",
        "stack": [
          {
            "type": "Boolean",
            "value": true
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
                  "type": "ByteString",
                  "value": "CJjqIZc3j2I6dnCXRFREhXbQrq8="
                },
                {
                  "type": "ByteString",
                  "value": "lBNDI5IT+g52XxAnznQvSNt3mpY="
                },
                {
                  "type": "Integer",
                  "value": "20000000000000"
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

let getApplicationLogUnkownJson = """
{
  "jsonrpc": "2.0",
  "id": 1,
  "error": {
    "code": -100,
    "message": "Unknown transaction/blockhash"
  }
}
"""
