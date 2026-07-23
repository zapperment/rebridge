local items = require("src.config.items")
local stateUtils = require("src.lib.state.utils")
local getColour = require("src.lib.colour.getColour")

-- handles changes of the faders from the remote surface (Launch Control)
return function(event)
  local processed = false

  for i = 1, 24 do
    local encoder = "encoder" .. i
    local item = items[encoder]
    local match = remote.match_midi(item.midi, event)
    if match and stateUtils.get(encoder .. ".enabled") then
      local remoteSurfaceValue = match.x
      stateUtils.set(encoder .. ".value", remoteSurfaceValue)
      stateUtils.set(encoder .. ".colour", getColour(item.colour, remoteSurfaceValue))

      -- update host (Reason)
      remote.handle_input({ time_stamp = event.time_stamp, item = item.index, value = remoteSurfaceValue })
      processed = true
    end
  end
  return processed
end
