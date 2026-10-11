local items = require "src.lppmk3.config.items"
local state = require "src.lppmk3.lib.state._"

-- handles changes of the transport of the host (Reason)
return function(hostItems)
  for _, hostItemIndex in ipairs(hostItems) do
    if hostItemIndex == items.playButton.index then
      local changedItem = remote.get_item_state(hostItemIndex)
      state.set("transport.playing", changedItem.is_enabled and changedItem.value > 0)
    elseif hostItemIndex == items.recordButton.index then
      local changedItem = remote.get_item_state(hostItemIndex)
      state.set("transport.recording", changedItem.is_enabled and changedItem.value > 0)
    end
  end
end
