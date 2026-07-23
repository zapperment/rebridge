local faderStates = require("src.lib.state.faders")
local items = require("src.config.items")
local constants = require("src.config.constants")
local stateUtils = require("src.lib.state.utils")

-- handles changes of the faders from the host (Reason)
return function(changedItems)
  for _, changedItemIndex in ipairs(changedItems) do
    local changedItem = remote.get_item_state(changedItemIndex)
    for i = 1, 8 do
      local fader = "fader" .. i
      if changedItemIndex == items[fader].index then
        if changedItem.is_enabled then
          local hostValue = changedItem.value
          local controlSurfaceValue = faderStates[fader].controlSurface
          local state
          if controlSurfaceValue == nil then
            -- it goes here when the codec is loaded
            -- because we do not know where the fader is at on the control surface
            state = constants.fader.unknown
          elseif hostValue >= controlSurfaceValue - constants.pickupTolerance and hostValue <= controlSurfaceValue + constants.pickupTolerance then
            --local xy = changedItem.IN_SYNC.value
            state = constants.fader.inSync
          elseif hostValue > controlSurfaceValue then
            --local xy = changedItem.TOO_LOW.value
            state = constants.fader.tooLow
          elseif hostValue < controlSurfaceValue then
            --local xy = changedItem.TOO_HIGH.value
            state = constants.fader.tooHigh
          end
          faderStates[fader].host = hostValue
          stateUtils.set(fader, state)
        else
          faderStates[fader] = {}
          stateUtils.set(fader, constants.fader.unassigned)
        end
      end
    end
  end
end
