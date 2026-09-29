local state = require "src.lppmk3.lib.state._"
local store = require "src.lppmk3.lib.store._"

-- called regularly by the codec to update the surface store: whenever the song
-- or the LaunchEon changes, their colours are asked for; whenever the colours
-- change, they are sent; nothing happens until both names are known
return function()
  local documentName = state.get "store.documentName"
  local deviceName = state.get "store.deviceName"
  if documentName == nil or deviceName == nil then
    return {}
  end
  local key = documentName .. "\n" .. deviceName
  if state.get "store.dirty" then
    state.set("store.dirty", false)
    state.set("store.requestedKey", key)
    state.set("store.awaitingReply", false)
    return { store.makeColoursEvent(documentName, deviceName, store.colours.get()) }
  end
  local requestedKey = state.get "store.requestedKey"
  if key ~= requestedKey then
    state.set("store.sameSong", requestedKey ~= nil and
      string.sub(requestedKey, 1, string.len(documentName) + 1) == documentName .. "\n")
    state.set("store.requestedKey", key)
    state.set("store.awaitingReply", true)
    return { store.makeRequestEvent(documentName, deviceName) }
  end
  return {}
end
