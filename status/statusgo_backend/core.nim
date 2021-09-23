import json, nimcrypto, chronicles
import status_go, ../utils

logScope:
  topics = "rpc"

proc callRPC*(inputJSON: string): string =
  return $status_go.callRPC(inputJSON)

proc callPrivateRPCRaw*(inputJSON: string): string =
  return $status_go.callPrivateRPC(inputJSON)

proc ethCallPrivateRPC*(chainId: int, payload = %* []): string =
  let methodName = "eth_call"
  try:
    let inputJSON = %* {
      "jsonrpc": "2.0",
      "chainId": chainId,
      "method": methodName,
      "params": %payload
    }
    debug "ethCallPrivateRPC", rpc_method="eth_call"
    let response = status_go.callPrivateRPC($inputJSON)
    result = $response
    if parseJSON(result).hasKey("error"):
      error "rpc response error", result, payload, methodName
  except Exception as e:
    error "error doing rpc request", methodName=methodName, exception=e.msg


proc callPrivateRPC*(methodName: string, payload = %* []): string =
  try:
    let inputJSON = %* {
      "jsonrpc": "2.0",
      "method": methodName,
      "params": %payload
    }
    debug "callPrivateRPC", rpc_method=methodName
    let response = status_go.callPrivateRPC($inputJSON)
    result = $response
    if parseJSON(result).hasKey("error"):
      error "rpc response error", result, payload, methodName
  except Exception as e:
    error "error doing rpc request", methodName=methodName, exception=e.msg

proc sendTransaction*(inputJSON: string, password: string): string =
  var hashed_password = "0x" & $keccak_256.digest(password)
  return $status_go.sendTransaction(inputJSON, hashed_password)

proc startMessenger*() =
  discard callPrivateRPC("startMessenger".prefix)

proc addPeer*(peer: string) =
  let response = callPrivateRPC("admin_addPeer", %* [peer])
  info "addPeer", topics="mailserver-interaction", rpc_method="admin_addPeer", peer, response

proc removePeer*(peer: string) =
  let response = callPrivateRPC("admin_removePeer", %* [peer])
  info "removePeer", topics="mailserver-interaction", rpc_method="admin_removePeer", peer, response


proc markTrustedPeer*(peer: string) =
  let response = callPrivateRPC("markTrustedPeer".prefix(false), %* [peer])
  info "markTrustedPeer", topics="mailserver-interaction", rpc_method="waku_markTrustedPeer", peer, response


proc getBlockByNumber*(blockNumber: string): string =
  result = callPrivateRPC("eth_getBlockByNumber", %* [blockNumber, false])

proc getTransfersByAddress*(address: string, toBlock: string, limit: string, fetchMore: bool = false): string =
  let toBlockParsed = if not fetchMore: newJNull() else: %toBlock
  result = callPrivateRPC("wallet_getTransfersByAddress", %* [address, toBlockParsed, limit, fetchMore])

proc signMessage*(rpcParams: string): string =
  return $status_go.signMessage(rpcParams)

proc signTypedData*(data: string, address: string, password: string): string =
  return $status_go.signTypedData(data, address, password)

proc getBloomFilter*(): string =
  return $callPrivateRPC("bloomFilter".prefix, %* []).parseJSON()["result"].getStr
