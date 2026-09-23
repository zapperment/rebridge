local ctrl = require "src.lcxl3.config.controls"
local state = require "src.lib.state._"
local str = require "src.lib.string._"
local const = require "src.lcxl3.config.constants"
local cycleParams = require "src.lcxl3.config.cycleParams"
local util = require "src.remote.processMidi.util._"
local deb = require "src.lib.debug._"

-- the number of values of the mapped parameter if the button cycles through
-- them like the buttons on the device's own UI, nil for other buttons
local function getCycleCount(paramName)
  local deviceCycleParams = cycleParams[state.get "deviceType"]
  return deviceCycleParams and deviceCycleParams[paramName]
end

-- the host reports the parameter's value scaled to the item's 0-127 range;
-- these convert between that range and the parameter's own 0..count-1 values
local function toParamValue(scaledValue, count)
  return math.floor(scaledValue * (count - 1) / 127 + 0.5)
end

local corrections = {
  [6] = 7,
  [121] = 120
}

local function toScaledValue(paramValue, count)
  local scaled = math.floor(paramValue * 127 / (count - 1) + 0.5)
  local correction = corrections[scaled]
  if correction then
    deb.log(
      "[remote:processMidi:buttons] " ..
      "button correction: changed " .. scaled .. " to " .. correction
    )
    return correction
  end
  return scaled
end

-- handles changes of the buttons of the remote surface (Launch Control)
return function(event)
  local processed = false
  for _, control in ipairs(ctrl.buttons) do
    local logMe = false --control == "button1"
    processed = util.process(
      control,
      event,
      function(controlSurfaceValue, item)
        -- callback START --
        local pressed = controlSurfaceValue > 0
        local paramName = remote.get_item_name(item.index)
        local cycleCount = getCycleCount(paramName)
        if cycleCount then
          -- a cycle button is momentary: bright while held, and each press
          -- advances the parameter to its next value, wrapping around at the end
          if pressed then
            local hostValue = state.get(control .. ".hostValue")
            local currentValue = toParamValue(hostValue, cycleCount)
            local nextValue = (currentValue + 1) % cycleCount
            local nextValueScaled = toScaledValue(nextValue, cycleCount)

            -- update host (Reason)
            remote.handle_input({
              time_stamp = event.time_stamp,
              item = item.index,
              value = nextValueScaled
            })
          end
        elseif state.get(control .. ".type") == const.button.momentary then
          -- the host flips the parameter itself whenever the button goes down,
          -- and needs to see it come up again before the next press counts, so
          -- the codec passes both on (see config/momentaryParams)
          remote.handle_input({ time_stamp = event.time_stamp, item = item.index, value = pressed and 127 or 0 })
        elseif pressed then
          local turnedOn = state.flip(control .. ".hostValue")
          if logMe then
            deb.log(
              "[remote:processMidi:buttons] " ..
              "turnedOn=" .. str.serialise(turnedOn) .. " " ..
              "(" .. type(turnedOn) .. ")"
            )
          end

          -- update host (Reason)
          local hostValue = turnedOn and 127 or 0
          remote.handle_input({ time_stamp = event.time_stamp, item = item.index, value = hostValue })
        end
        -- callback END --
      end
    ) or processed
  end
  return processed
end
