local items = require("src.config.items")
local const = require("src.config.constants")
local state = require("src.lib.state._")
local deb = require("src.lib.debug._")

-- handles changes of the faders of the host (Reason)
return function(changedItems)
  local hasChanged
  for _, changedItemIndex in ipairs(changedItems) do
    local item = remote.get_item_state(changedItemIndex)
    for i = 1, const.counts.faders do
      local fader = "fader" .. i
      if changedItemIndex == items[fader].index then
        hasChanged = true
        local hostTextValue = item.text_value;
        local hostValue = item.value;
        local param = item.remote_item_name;
        local enabled = item.is_enabled;
        local controlSurfaceValue = state.getNext(fader .. ".controlSurfaceValue")
        local status
        if enabled then
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
        else
          status = const.fader.unassigned
        end
        state.set(fader .. ".param", param)
        state.set(fader .. ".hostValue", hostValue)
        state.set(fader .. ".hostTextValue", hostTextValue)
        state.set(fader .. ".enabled", enabled)
        state.set(fader .. ".status", status)
      end
    end
  end
end
