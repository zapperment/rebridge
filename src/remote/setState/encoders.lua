local items = require("src.config.items")
local const = require("src.config.constants")
local state = require("src.lib.state._")
local col = require("src.lib.colour._")
local conditionalValueLabels = require("src.config.conditionalValueLabels")
local paramValues = require("src.lib.state.paramValues")
local disp = require("src.lib.display._")
local deb = require("src.lib.debug._")

-- parameters whose settings drive the display of other parameters (see
-- config/conditionalValueLabels), collected across all device types
local watchedParams = {}
for _, deviceConditionals in pairs(conditionalValueLabels) do
  for _, conditional in pairs(deviceConditionals) do
    watchedParams[conditional.dependsOn] = true
  end
end

-- handles changes of the encoders of the host (Reason)
return function(changedItems)
  for _, changedItemIndex in ipairs(changedItems) do
    local item = remote.get_item_state(changedItemIndex)
    for i = 1, const.counts.encoders do
      local control = "encoder" .. i
      if changedItemIndex == items[control].index then
        local hostValue = item.value;
        local param = item.remote_item_name;
        local enabled = item.is_enabled;
        if enabled then
          if watchedParams[param] then
            paramValues[param] = hostValue
          end
          state.set(control .. ".enabled", true)
          state.set(control .. ".param", param)
          state.set(control .. ".hostValue", hostValue)
          state.set(control .. ".hostTextValue", disp.getTextValue(item))
          local colourName = col.getColourName(state.getNext("deviceType"), item.remote_item_name,
            items[control].colour)
          state.set(control .. ".colour", col.getColour(colourName, hostValue))
        else
          state.set(control .. ".enabled", false)
        end
      end
    end
  end
end
