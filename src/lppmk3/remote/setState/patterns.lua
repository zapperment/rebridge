local items = require "src.lppmk3.config.items"
local state = require "src.lppmk3.lib.state._"
local ctrl = require "src.lppmk3.config.controls"
local deb = require "src.lib.debug._"
local str = require "src.lib.string._"

-- handles changes of the patterns of the host (Reason)
return function(hostItems)
  local logMe = false
  for _, hostItemIndex in ipairs(hostItems) do
    for _, pattern in ipairs(ctrl.patterns) do
      if hostItemIndex == items[pattern].index then
        local hostItem = remote.get_item_state(hostItemIndex)
        local isEnabled = hostItem.is_enabled
        state.set(pattern .. ".enabled", isEnabled)
        local hostValue = hostItem.value;
        if logMe then
          deb.log(
            "[lppmk3.setState.patterns] " ..
            "hostValue=" .. str.serialise(hostValue)
          )
        end
        state.set(pattern .. ".hostValue", hostValue)
      end
    end
  end
end
