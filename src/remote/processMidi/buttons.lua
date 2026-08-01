local items = require("src.config.items")
local const = require("src.config.constants")
local state = require("src.lib.state._")
local buttonStates = require("src.lib.state.buttons")
local cycleParams = require("src.config.cycleParams")
local col = require("src.lib.colour._")
local deb = require("src.lib.debug._")

-- the number of values of the mapped parameter if the button cycles through
-- them like the momentary buttons on the device's own UI, nil for toggles
local function getCycleCount(paramName)
  local deviceCycleParams = cycleParams[state.getNext("deviceType")]
  return deviceCycleParams and deviceCycleParams[paramName]
end

-- the host reports the parameter's value scaled to the item's 0-127 range;
-- these convert between that range and the parameter's own 0..count-1 values
local function toParamValue(scaledValue, count)
  return math.floor(scaledValue * (count - 1) / 127 + 0.5)
end

local function toScaledValue(paramValue, count)
  return math.floor(paramValue * 127 / (count - 1) + 0.5)
end

-- handles changes of the buttons of the remote surface (Launch Control)
return function(event)
  local processed = false

  for i = 1, const.counts.buttons do
    local button = "button" .. i
    local item = items[button]
    local match = remote.match_midi(item.midi, event)
    if match and state.get(button .. ".enabled") then
      local pressed = match.x > 0
      local paramName = remote.get_item_name(item.index)
      local colourName = col.getColourName(state.getNext("deviceType"), paramName, item.colour)
      local cycleCount = getCycleCount(paramName)
      if cycleCount then
        -- a cycle button is momentary: bright while held, and each press
        -- advances the parameter to its next value, wrapping around at the end
        if pressed then
          buttonStates.held[button] = true
          state.set(button .. ".colour", col.getColour(colourName, 95))
          buttonStates.pressed = item

          local currentValue = toParamValue(remote.get_item_state(item.index).value, cycleCount)
          local nextValue = (currentValue + 1) % cycleCount

          -- update host (Reason)
          remote.handle_input({
            time_stamp = event.time_stamp,
            item = item.index,
            value = toScaledValue(nextValue, cycleCount)
          })
        else
          buttonStates.held[button] = nil
          state.set(button .. ".colour", col.getColour(colourName, 1))
        end
        processed = true
      elseif pressed then
        local turnedOn = state.flip(button .. ".value")
        local colourValue = turnedOn and 95 or 1
        state.set(button .. ".colour", col.getColour(colourName, colourValue))
        buttonStates.pressed = item

        -- update host (Reason)
        local hostValue = turnedOn and 127 or 0
        remote.handle_input({ time_stamp = event.time_stamp, item = item.index, value = hostValue })
        processed = true
      else
        -- releasing a toggle button does nothing, but the event is consumed
        processed = true
      end
    end
  end
  if processed then
    deb.log("[remote.processMidi.buttons] LCXL3 => CODEC")
  end
  return processed
end
