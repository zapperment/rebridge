local items = require("src.config.items")
local stateUtils = require("src.lib.state.utils")
local getColour = require("src.lib.colour.getColour")

-- handles changes of the buttons of the remote surface (Launch Control)
return function(event)
  local processed = false

  for i = 1, 16 do
    local button = "button" .. i
    local item = items[button]
    local match = remote.match_midi(item.midi, event)
    if match and stateUtils.get(button .. ".enabled") then
      local turnedOn = stateUtils.flip(button .. ".value")
      local colourValue = turnedOn and 95 or 1
      stateUtils.set(button .. ".colour", getColour(item.colour, colourValue))

      -- update host (Reason)
      local hostValue = turnedOn and 127 or 0
      remote.handle_input({ time_stamp = event.time_stamp, item = item.index, value = hostValue })
      processed = true
    end
  end
  return processed
end
