import json, json_serialization, strformat, chronicles
import status_go
import response_type

export response_type

logScope:
  topics = "rpc"

proc callRPC*(inputJSON: string): string =
  return $status_go.callRPC(inputJSON)

proc callPrivateRPCRaw*(inputJSON: string): string {.raises: [].} =
    result = $status_go.callPrivateRPC(inputJSON)

proc callPrivateRPC*(methodName: string, payload = %* []): RpcResponse[JsonNode] 
  {.raises: [RpcException, ValueError, Defect, SerializationError].} =
  try:
    let inputJSON = %* {
      "jsonrpc": "2.0",
      "method": methodName,
      "params": %payload
    }
    debug "NewBE_callPrivateRPC", rpc_method=methodName
    let rpcResponseRaw = status_go.callPrivateRPC($inputJSON)
    result = Json.decode(rpcResponseRaw, RpcResponse[JsonNode])
    if(not result.error.isNil):
      var err = "\nstatus-go error ["
      err &= fmt"methodName:{methodName}, "
      err &= fmt"code:{result.error.code}, "
      err &= fmt"message:{result.error.message} "
      err &= "]\n"
      error "rpc response error", err
      raise newException(ValueError, err)

  except RpcException as e:
    error "error doing rpc request", methodName = methodName, exception=e.msg
    raise newException(RpcException, e.msg)
    
proc signMessage*(rpcParams: string): string =
  return $status_go.signMessage(rpcParams)

proc signTypedData*(data: string, address: string, password: string): string =
  return $status_go.signTypedData(data, address, password)
