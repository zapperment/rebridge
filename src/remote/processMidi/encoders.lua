local items = require("src.config.items")
local const = require("src.config.constants")
local state = require("src.lib.state._")
local col = require("src.lib.colour._")
local deb = require("src.lib.debug._")

local function process(control, event, callback)
  local item = items[control]
  local match = remote.match_midi(item.midi, event)
  if match and state.get(control .. ".enabled") then
    local controlSurfaceValue = match.x
    state.set(control .. ".controlSurfaceValue", controlSurfaceValue)
    callback(control, controlSurfaceValue, item)
    return true
  end
  return false
end

-- handles changes of the encoders of the remote surface (Launch Control)
return function(event)
  local processed = false

  for i = 1, const.counts.encoders do
    processed = process(
      "encoder" .. i,
      event,
      function(control, controlSurfaceValue, item)
        local colourName = col.getColourName(
          state.getNext("deviceType"),
          remote.get_item_name(item.index),
          item.colour
        )
        state.set(control .. ".colour", col.getColour(colourName, controlSurfaceValue))

        -- update host (Reason)
        remote.handle_input({
          time_stamp = event.time_stamp,
          item = item.index,
          value = controlSurfaceValue
        })
      end
    )
  end
  return processed
end
