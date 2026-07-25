local items = require("src.config.items")
local state = require("src.lib.state._")

-- handles changes of the transport state (play/record) of the host (Reason)
return function(changedItems)
  for _, changedItemIndex in ipairs(changedItems) do
    if changedItemIndex == items.playButton.index then
      local changedItem = remote.get_item_state(changedItemIndex)
      state.set("transport.playing", changedItem.is_enabled and changedItem.value > 0)
    elseif changedItemIndex == items.recordButton.index then
      local changedItem = remote.get_item_state(changedItemIndex)
      state.set("transport.recording", changedItem.is_enabled and changedItem.value > 0)
    end
  end
end
