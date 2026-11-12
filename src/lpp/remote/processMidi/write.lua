local items = require "src.lpp.config.items"
local deb = require "src.lib.debug._"

-- the name of the item that carries a change to the host
local function itemName(change)
  if change.kind == "selection" then
    return "track" .. change.track .. "selection"
  end
  if change.kind == "setup" then
    return "setup"
  end
  if change.kind == "length" then
    return "switchinterval"
  end
  if change.kind == "fillin" then
    return "fillin"
  end
  if change.kind == "function" then
    return "function"
  end
  if change.kind == "mute" or change.kind == "solo" or change.kind == "relaunch" then
    return "track" .. change.track .. change.kind
  end
  local track = math.floor(change.index / 8) + 1
  local row = change.index % 8 + 1
  local clip = "track" .. track .. "clip" .. row
  -- the settings of a CV output, such as track1clip1a, track1clip1fillina,
  -- track1clip1landinga, track1clip1introa or track1clip1outroa
  if change.output then
    local letter = string.char(string.byte("a") + change.output - 1)
    return clip .. string.match(change.kind, "^(.*)output$") .. letter
  end
  return clip .. change.kind
end

-- hands a change of Launchnik, as launchnik.press makes it, to the host; nil
-- stands for a press that changes nothing
return function(event, change)
  if not change then
    return
  end
  local name = itemName(change)
  deb.log("[lpp:remote:processMidi:write] " .. name .. " = " .. change.value)
  remote.handle_input({ time_stamp = event.time_stamp, item = items[name].index, value = change.value })
end
