import json
import core, utils
import response_type

export response_type

proc fetchMessages*(chatId: string, cursorVal: string, limit: int): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [chatId, cursorVal, limit]
  result = callPrivateRPC("chatMessages".prefix, payload)

proc fetchPinnedMessages*(chatId: string, cursorVal: string, limit: int): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [chatId, cursorVal, limit]
  result = callPrivateRPC("chatPinnedMessages".prefix, payload)

proc fetchReactions*(chatId: string, cursorVal: string, limit: int): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [chatId, cursorVal, limit]
  result = callPrivateRPC("emojiReactionsByChatID".prefix, payload)

proc addReaction*(chatId: string, messageId: string, emojiId: int): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [chatId, messageId, emojiId]
  result = callPrivateRPC("sendEmojiReaction".prefix, payload)

proc removeReaction*(reactionId: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [reactionId]
  result = callPrivateRPC("sendEmojiReactionRetraction".prefix, payload)

proc pinUnpinMessage*(chatId: string, messageId: string, pin: bool): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %*[{
    "message_id": messageId,
    "pinned": pin,
    "chat_id": chatId
  }]
  result = callPrivateRPC("sendPinMessage".prefix, payload)

proc fetchMessageByMessageId*(messageId: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [messageId]
  result = callPrivateRPC("messageByMessageID".prefix, payload)

proc fetchReactionsForMessageWithId*(chatId: string, messageId: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [chatId, messageId]
  result = callPrivateRPC("emojiReactionsByChatIDMessageID".prefix, payload)