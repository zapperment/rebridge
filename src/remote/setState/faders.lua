local faderStates = require("src.lib.state.faders")
local items = require("src.config.items")
local const = require("src.config.constants")
local state = require("src.lib.state._")
local deb = require("src.lib.debug._")

-- handles changes of the faders of the host (Reason)
return function(changedItems)
  local hasChanged
  for _, changedItemIndex in ipairs(changedItems) do
    local changedItem = remote.get_item_state(changedItemIndex)
    for i = 1, const.counts.faders do
      local fader = "fader" .. i
      if changedItemIndex == items[fader].index then
        hasChanged = true
        if changedItem.is_enabled then
          local hostValue = changedItem.value
          local controlSurfaceValue = faderStates[fader].remoteSurface
          local status
          if controlSurfaceValue == nil then
            -- it goes here when the codec is loaded
            -- because we do not know where the fader is at on the control surface
            status = const.fader.unknown
          elseif hostValue >= controlSurfaceValue - const.pickupTolerance and hostValue <= controlSurfaceValue + const.pickupTolerance then
            status = const.fader.inSync
          elseif hostValue > controlSurfaceValue then
            status = const.fader.tooLow
          elseif hostValue < controlSurfaceValue then
            status = const.fader.tooHigh
          end
          faderStates[fader].host = hostValue
          state.set(fader, status)
        else
          faderStates[fader] = {}
          state.set(fader, const.fader.unassigned)
        end
      end
    end
  end
  if hasChanged then
    deb.log("[remote.setState.faders] RSN => CODEC")
  end
end
