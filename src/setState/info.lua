local state = require("src.lib.state._")
local items = require("src.config.items")
local debug = require("src.lib.debug._")

return function(changedItems)
  for _, changedItemIndex in ipairs(changedItems) do
    if changedItemIndex == items.targetTrackName.index then
      local targetTrackName = remote.get_item_text_value(changedItemIndex)
      state.set("targetTrackName", targetTrackName)
    elseif changedItemIndex == items.documentName.index then
      local documentName = remote.get_item_text_value(changedItemIndex)
      state.set("documentName", documentName)
    elseif changedItemIndex == items.deviceType.index then
      local deviceType = remote.get_item_text_value(changedItemIndex)
      state.set("deviceType", deviceType)
    elseif changedItemIndex == items.deviceName.index then
      local deviceName = remote.get_item_text_value(changedItemIndex)
      state.set("deviceName", deviceName)
    elseif changedItemIndex == items.patchName.index then
      local patchName = remote.get_item_text_value(changedItemIndex)
      state.set("patchName", patchName)
    end
  end
end
