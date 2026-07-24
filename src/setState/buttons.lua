local items = require("src.config.items")
local stateUtils = require("src.lib.state.utils")
local getColour = require("src.lib.colour.getColour")

-- handles changes of the buttons of the host (Reason)
return function(changedItems)
  for _, changedItemIndex in ipairs(changedItems) do
    local changedItem = remote.get_item_state(changedItemIndex)
    for i = 1, 16 do
      local button = "button" .. i
      if changedItemIndex == items[button].index then
        if changedItem.is_enabled then
          local hostValue = changedItem.value > 0 and true or false
          stateUtils.set(button .. ".enabled", true)
          stateUtils.set(button .. ".value", hostValue)
          local colourValue = changedItem.value > 0 and 95 or 1
          stateUtils.set(button .. ".colour", getColour(items[button].colour, colourValue))
        else
          stateUtils.set(button .. ".enabled", false)
        end
      end
    end
  end
end
