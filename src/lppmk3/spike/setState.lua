local items = require "src.lppmk3.config.items"
local deb = require "src.lib.debug._"
local spike = require "src.lppmk3.spike.state"

local fields = {
  spikeClipPresent = "present",
  spikeClipColour = "colour",
  spikeSetup = "setup",
  spikeLight = "light",
}

-- THROWAWAY: keeps a copy of what the host reports about the Launchnik Spike
-- device; the light is not logged, since it changes with every flash
return function(hostItems)
  for _, hostItemIndex in ipairs(hostItems) do
    for name, field in pairs(fields) do
      if hostItemIndex == items[name].index then
        local changedItem = remote.get_item_state(hostItemIndex)
        if name == "spikeSetup" then
          spike.enabled = changedItem.is_enabled
        end
        if changedItem.is_enabled then
          spike[field] = changedItem.value
          if field == "light" then
            spike.lightChanged = true
          else
            deb.log("[spike] host reports " .. name .. " = " .. changedItem.value)
          end
        end
      end
    end
  end
end
