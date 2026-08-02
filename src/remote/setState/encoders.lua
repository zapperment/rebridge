local items = require("src.config.items")
local const = require("src.config.constants")
local state = require("src.lib.state._")
local col = require("src.lib.colour._")
local conditionalValueLabels = require("src.config.conditionalValueLabels")
local paramValues = require("src.lib.state.paramValues")
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
  local hasChanged
  for _, changedItemIndex in ipairs(changedItems) do
    local changedItem = remote.get_item_state(changedItemIndex)
    for i = 1, const.counts.encoders do
      local encoder = "encoder" .. i
      if changedItemIndex == items[encoder].index then
        hasChanged = true
        if changedItem.is_enabled then
          local hostValue = changedItem.value
          if watchedParams[changedItem.remote_item_name] then
            paramValues[changedItem.remote_item_name] = hostValue
          end
          state.set(encoder .. ".enabled", true)
          state.set(encoder .. ".value", hostValue)
          local colourName = col.getColourName(state.getNext("deviceType"), changedItem.remote_item_name,
            items[encoder].colour)
          state.set(encoder .. ".colour", col.getColour(colourName, hostValue))
        else
          state.set(encoder .. ".enabled", false)
        end
      end
    end
  end
end
