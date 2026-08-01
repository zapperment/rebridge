local state = require("src.lib.state._")
local items = require("src.config.items")
local deb = require("src.lib.debug._")

return function(changedItems)
  local hasChanged
  for _, changedItemIndex in ipairs(changedItems) do
    if changedItemIndex == items.targetTrackName.index then
      hasChanged = true
      local targetTrackName = remote.get_item_text_value(changedItemIndex)
      state.set("targetTrackName", targetTrackName)
    elseif changedItemIndex == items.documentName.index then
      hasChanged = true
      local documentName = remote.get_item_text_value(changedItemIndex)
      state.set("documentName", documentName)
    elseif changedItemIndex == items.deviceType.index then
      hasChanged = true
      local deviceType = remote.get_item_text_value(changedItemIndex)
      state.set("deviceType", deviceType)
    elseif changedItemIndex == items.deviceName.index then
      hasChanged = true
      local deviceName = remote.get_item_text_value(changedItemIndex)
      state.set("deviceName", deviceName)
    elseif changedItemIndex == items.patchName.index then
      hasChanged = true
      local patchName = remote.get_item_text_value(changedItemIndex)
      state.set("patchName", patchName)
    end
  end
  if hasChanged then
    deb.log("[remote.setState.info] RSN => CODEC")
  end
end
