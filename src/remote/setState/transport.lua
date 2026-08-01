local items = require("src.config.items")
local state = require("src.lib.state._")
local deb = require("src.lib.debug._")

-- handles changes of the transport state (play/record) of the host (Reason)
return function(changedItems)
  local hasChanged
  for _, changedItemIndex in ipairs(changedItems) do
    if changedItemIndex == items.playButton.index then
      hasChanged = true
      local changedItem = remote.get_item_state(changedItemIndex)
      state.set("transport.playing", changedItem.is_enabled and changedItem.value > 0)
    elseif changedItemIndex == items.recordButton.index then
      hasChanged = true
      local changedItem = remote.get_item_state(changedItemIndex)
      state.set("transport.recording", changedItem.is_enabled and changedItem.value > 0)
    end
  end
  if hasChanged then
    deb.log("[remote.setState.transport] RSN => CODEC")
  end
end
