local items = require("src.config.items")
local const = require("src.config.constants")
local state = require("src.lib.state._")
local cycleParams = require("src.config.cycleParams")

-- handles changes of the buttons of the host (Reason)
return function(changedItems)
  for _, changedItemIndex in ipairs(changedItems) do
    local changedItem = remote.get_item_state(changedItemIndex)
    for i = 1, const.counts.buttons do
      local control = "button" .. i
      if changedItemIndex == items[control].index then
        if changedItem.is_enabled then
          state.set(control .. ".enabled", true)
          local param = changedItem.remote_item_name
          state.set(control .. ".param", param)
          local hostValue = changedItem.value
          local hostTextValue = changedItem.text_value
          local deviceType = state.get("deviceType")
          local deviceCycleParams = cycleParams[deviceType]
          if deviceCycleParams and deviceCycleParams[param] then
            state.set(control .. ".type", const.button.cycle)
            state.set(control .. ".hostValue", hostValue)
          else
            state.set(control .. ".type", const.button.toggle)
            state.set(control .. ".hostValue", hostValue > 0 and true or false)
          end
          state.set(control .. ".hostTextValue", hostTextValue)
        else
          state.set(control .. ".enabled", false)
        end
      end
    end
  end
end
