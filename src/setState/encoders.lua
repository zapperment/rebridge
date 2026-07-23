local items = require("src.config.items")
local stateUtils = require("src.lib.state.utils")
local getColour = require("src.lib.colour.getColour")

-- handles changes of the encoders from the host (Reason)
return function(changedItems)
  for _, changedItemIndex in ipairs(changedItems) do
    local changedItem = remote.get_item_state(changedItemIndex)
    for i = 1, 24 do
      local encoder = "encoder" .. i
      if changedItemIndex == items[encoder].index then
        if changedItem.is_enabled then
          local hostValue = changedItem.value
          stateUtils.set(encoder .. ".enabled", true)
          stateUtils.set(encoder .. ".value", hostValue)
          stateUtils.set(encoder .. ".colour", getColour(items[encoder].colour, hostValue))
        else
          stateUtils.set(encoder .. ".enabled", false)
        end
      end
    end
  end
end
