local items = require "src.lcxl3.config.items"
local state = require "src.lcxl3.lib.state._"
local deb = require "src.lib.debug._"

-- handles changes of the transport state (play/record) of the host (Reason)
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
