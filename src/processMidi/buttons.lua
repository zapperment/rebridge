local items = require("src.config.items")
local const = require("src.config.constants")
local state = require("src.lib.state._")
local buttonStates = require("src.lib.state.buttons")
local cycleParams = require("src.config.cycleParams")
local getColour = require("src.lib.colour.getColour")

-- the number of values of the mapped parameter if the button cycles through
-- them like the momentary buttons on the device's own UI, nil for toggles
local function getCycleCount(item)
  local deviceCycleParams = cycleParams[state.getNext("deviceType")]
  return deviceCycleParams and deviceCycleParams[remote.get_item_name(item.index)]
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
      local cycleCount = getCycleCount(item)
      if cycleCount then
        -- a cycle button is momentary: bright while held, and each press
        -- advances the parameter to its next value, wrapping around at the end
        if pressed then
          buttonStates.held[button] = true
          state.set(button .. ".colour", getColour(item.colour, 95))
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
          state.set(button .. ".colour", getColour(item.colour, 1))
        end
        processed = true
      elseif pressed then
        local turnedOn = state.flip(button .. ".value")
        local colourValue = turnedOn and 95 or 1
        state.set(button .. ".colour", getColour(item.colour, colourValue))
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
  return processed
end
