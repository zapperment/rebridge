local const = require "src.lppmk3.config.constants"
local state = require "src.lppmk3.lib.state._"
local store = require "src.lppmk3.lib.store._"
local col = require "src.lppmk3.lib.colour._"
local patternColours = require "src.lppmk3.config.patternColours"

local commands = const.store.commands

-- whether the performer has given any pattern a colour of its own
local function hasColours()
  for _, colour in ipairs(store.colours.get()) do
    if colour ~= patternColours[1] then
      return true
    end
  end
  return false
end

-- whether the message answers the request the codec is waiting for
local function answersRequest(message)
  return state.get "store.awaitingReply"
      and message.documentName == state.get "store.documentName"
      and message.deviceName == state.get "store.deviceName"
end

-- handles the messages of the surface store: its colours for the song and
-- LaunchEon asked for are shown; if it has none, the pads keep theirs, which
-- are then stored; when it starts, it gets the colours the performer has set,
-- or is asked for its own
return function(event)
  if event.port ~= const.ports.store then
    return false
  end
  local message = store.parseMessage(event)
  if message == nil then
    return true
  end
  if message.command == commands.hello then
    if hasColours() then
      state.set("store.dirty", true)
    else
      state.set("store.requestedKey", nil)
    end
  elseif message.command == commands.colours and answersRequest(message) then
    store.colours.set(message.colours)
    state.set("store.awaitingReply", false)
  elseif message.command == commands.unknown and answersRequest(message) then
    state.set("store.dirty", true)
    state.set("store.awaitingReply", false)
  end
  return true
end
