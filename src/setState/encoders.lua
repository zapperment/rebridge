local items = require("src.config.items")
local state = require("src.lib.state._")
local getColour = require("src.lib.colour.getColour")
--local debug = require("src.lib.debug._")

-- handles changes of the encoders of the host (Reason)
return function(changedItems)
  -- if #changedItems > 0 then
  --   for i = 1, 24 do
  --     local encoder = "encoder" .. i
  --     local itemState = remote.get_item_state(items[encoder].index)
  --     debug.log(tostring(i) .. "--------------------------------------------------")
  --     debug.log(encoder .. ".is_enabled:       " .. (itemState.is_enabled and "true" or "false"))
  --     debug.log(encoder .. ".remote_item_name: " .. itemState.remote_item_name)
  --     debug.log(encoder .. ".text_value:       " .. itemState.text_value)
  --   end
  -- end
  for _, changedItemIndex in ipairs(changedItems) do
    local changedItem = remote.get_item_state(changedItemIndex)
    for i = 1, 24 do
      local encoder = "encoder" .. i
      if changedItemIndex == items[encoder].index then
        if changedItem.is_enabled then
          local hostValue = changedItem.value
          --debug.log("SSt: host says " .. encoder .. ".enabled is true")
          --debug.log("SSt: host says " .. encoder .. ".value is " .. tostring(hostValue))
          state.set(encoder .. ".enabled", true)
          state.set(encoder .. ".value", hostValue)
          state.set(encoder .. ".colour", getColour(items[encoder].colour, hostValue))
        else
          local hostValue = changedItem.value
          --debug.log("SSt: host says " .. encoder .. ".enabled is false")
          --debug.log("SSt: host says " .. encoder .. ".value is " .. tostring(hostValue))
          state.set(encoder .. ".enabled", false)
        end
      end
    end
  end
end
