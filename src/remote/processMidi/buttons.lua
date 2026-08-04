local items = require("src.config.items")
local const = require("src.config.constants")
local state = require("src.lib.state._")
local buttonStates = require("src.lib.state.buttons")
local cycleParams = require("src.config.cycleParams")
local col = require("src.lib.colour._")
local util = require("src.remote.processMidi.util._")
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
  for i = 1, const.counts.buttons do
    if util.process(
          "button" .. i,
          event,
          function(control, controlSurfaceValue, item)
            -- callback START --
            local pressed = controlSurfaceValue > 0
            local paramName = remote.get_item_name(item.index)
            local colourName = col.getColourName(state.getNext("deviceType"), paramName, item.colour)
            local cycleCount = getCycleCount(paramName)
            if cycleCount then
              -- a cycle button is momentary: bright while held, and each press
              -- advances the parameter to its next value, wrapping around at the end
              if pressed then
                buttonStates.held[control] = true
                state.set(control .. ".colour", col.getColour(colourName, 95))
                buttonStates.pressed = item
                local hostValue = remote.get_item_state(item.index).value
                local currentValue = toParamValue(hostValue, cycleCount)
                local nextValue = (currentValue + 1) % cycleCount
                local nextValueScaled = toScaledValue(nextValue, cycleCount)
                if paramName == "Resonator Select" then
                  -- this is always 127 (button pressed)
                  -- deb.log(
                  --   "[remote:processMidi:buttons] " .. control ..
                  --   ".controlSurfaceValue=" .. controlSurfaceValue
                  -- )
                  -- this is always 21
                  -- deb.log(
                  --   "[remote:processMidi:buttons] " ..
                  --   "cycleCount=" .. cycleCount
                  -- )
                  deb.log(
                    "[remote:processMidi:buttons] resonatorSelect " ..
                    "hostValue=" .. hostValue
                  )
                  deb.log(
                    "[remote:processMidi:buttons] resonatorSelect " ..
                    "currentValue=" .. currentValue
                  )
                  deb.log(
                    "[remote:processMidi:buttons] resonatorSelect " ..
                    "nextValue=" .. nextValue
                  )
                  deb.log(
                    "[remote:processMidi:buttons] resonatorSelect " ..
                    "nextValueScaled=" .. nextValueScaled
                  )
                end

                -- update host (Reason)
                remote.handle_input({
                  time_stamp = event.time_stamp,
                  item = item.index,
                  value = nextValueScaled
                })
              else
                buttonStates.held[control] = nil
                state.set(control .. ".colour", col.getColour(colourName, 1))
              end
            elseif pressed then
              local turnedOn = state.flip(control .. ".value")
              local colourValue = turnedOn and 95 or 1
              state.set(control .. ".colour", col.getColour(colourName, colourValue))
              buttonStates.pressed = item

              -- update host (Reason)
              local hostValue = turnedOn and 127 or 0
              remote.handle_input({ time_stamp = event.time_stamp, item = item.index, value = hostValue })
            end
            -- callback END --
          end
        ) then
      return true
    end
  end
end
