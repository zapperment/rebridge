local items = require("src.config.items")
local const = require("src.config.constants")
local state = require("src.lib.state._")
local col = require("src.lib.colour._")
local deb = require("src.lib.debug._")

-- handles changes of the encoders of the remote surface (Launch Control)
return function(event)
  local processed = false

  for i = 1, const.counts.encoders do
    local encoder = "encoder" .. i
    local item = items[encoder]
    local match = remote.match_midi(item.midi, event)
    if match and state.get(encoder .. ".enabled") then
      local remoteSurfaceValue = match.x
      state.set(encoder .. ".value", remoteSurfaceValue)
      local colourName = col.getColourName(state.getNext("deviceType"), remote.get_item_name(item.index), item.colour)
      state.set(encoder .. ".colour", col.getColour(colourName, remoteSurfaceValue))

      -- update host (Reason)
      remote.handle_input({ time_stamp = event.time_stamp, item = item.index, value = remoteSurfaceValue })
      processed = true
    end
  end
  if processed then
    deb.log("[processMidi.encoders] LCXL3 => CODEC")
  end
  return processed
end
