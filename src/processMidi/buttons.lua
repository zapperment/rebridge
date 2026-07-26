local items = require("src.config.items")
local state = require("src.lib.state._")
local buttonStates = require("src.lib.state.buttons")
local getColour = require("src.lib.colour.getColour")

-- handles changes of the buttons of the remote surface (Launch Control)
return function(event)
  local processed = false

  for i = 1, 16 do
    local button = "button" .. i
    local item = items[button]
    local match = remote.match_midi(item.midi, event)
    if match and state.get(button .. ".enabled") then
      local turnedOn = state.flip(button .. ".value")
      local colourValue = turnedOn and 95 or 1
      state.set(button .. ".colour", getColour(item.colour, colourValue))
      buttonStates.pressed = item

      -- update host (Reason)
      local hostValue = turnedOn and 127 or 0
      remote.handle_input({ time_stamp = event.time_stamp, item = item.index, value = hostValue })
      processed = true
    end
  end
  return processed
end
