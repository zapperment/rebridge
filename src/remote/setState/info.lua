local state = require("src.lib.state._")
local items = require("src.config.items")
local deb = require("src.lib.debug._")

return function(hostItems)
  for _, hostItemIndex in ipairs(hostItems) do
    if hostItemIndex == items.targetTrackName.index then
      local targetTrackName = remote.get_item_text_value(hostItemIndex)
      state.set("targetTrackName", targetTrackName)
    elseif hostItemIndex == items.documentName.index then
      local documentName = remote.get_item_text_value(hostItemIndex)
      state.set("documentName", documentName)
    elseif hostItemIndex == items.deviceType.index then
      local deviceType = remote.get_item_text_value(hostItemIndex)
      state.set("deviceType", deviceType)
    elseif hostItemIndex == items.deviceName.index then
      local deviceName = remote.get_item_text_value(hostItemIndex)
      state.set("deviceName", deviceName)
    elseif hostItemIndex == items.patchName.index then
      local patchName = remote.get_item_text_value(hostItemIndex)
      state.set("patchName", patchName)
    end
  end
end
