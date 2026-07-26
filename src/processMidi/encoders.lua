local items = require("src.config.items")
local const = require("src.config.constants")
local state = require("src.lib.state._")
local getColour = require("src.lib.colour.getColour")

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
      state.set(encoder .. ".colour", getColour(item.colour, remoteSurfaceValue))

      -- update host (Reason)
      remote.handle_input({ time_stamp = event.time_stamp, item = item.index, value = remoteSurfaceValue })
      processed = true
    end
  end
  return processed
end
