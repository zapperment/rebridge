local items = require("src.config.items")
local const = require("src.config.constants")
local state = require("src.lib.state._")
local getColour = require("src.lib.colour.getColour")

-- handles changes of the encoders of the host (Reason)
return function(changedItems)
  for _, changedItemIndex in ipairs(changedItems) do
    local changedItem = remote.get_item_state(changedItemIndex)
    for i = 1, const.counts.encoders do
      local encoder = "encoder" .. i
      if changedItemIndex == items[encoder].index then
        if changedItem.is_enabled then
          local hostValue = changedItem.value
          state.set(encoder .. ".enabled", true)
          state.set(encoder .. ".value", hostValue)
          state.set(encoder .. ".colour", getColour(items[encoder].colour, hostValue))
        else
          state.set(encoder .. ".enabled", false)
        end
      end
    end
  end
end
