local items = require("src.config.items")
local state = require("src.lib.state._")
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
          state.set(button .. ".enabled", true)
          state.set(button .. ".value", hostValue)
          local colourValue = changedItem.value > 0 and 95 or 1
          state.set(button .. ".colour", getColour(items[button].colour, colourValue))
        else
          state.set(button .. ".enabled", false)
        end
      end
    end
  end
end
