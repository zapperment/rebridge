local items = require("src.config.items")
local const = require("src.config.constants")
local state = require("src.lib.state._")
local conditionalValueLabels = require("src.config.conditionalValueLabels")
local disp = require("src.lib.display._")
local deb = require("src.lib.debug._")

-- handles changes of the encoders of the host (Reason)
return function(changedItems)
  for _, changedItemIndex in ipairs(changedItems) do
    local changedItem = remote.get_item_state(changedItemIndex)
    for i = 1, const.counts.encoders do
      local control = "encoder" .. i
      if changedItemIndex == items[control].index then
        local hostValue = changedItem.value;
        local param = changedItem.remote_item_name;
        local enabled = changedItem.is_enabled;
        if enabled then
          state.set(control .. ".enabled", true)
          state.set(control .. ".param", param)
          state.set(control .. ".hostValue", hostValue)
          state.set(control .. ".hostTextValue", disp.getTextValue(changedItem))
        else
          state.set(control .. ".enabled", false)
        end
      end
    end
  end
end
