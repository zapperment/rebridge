local state = require("src.lib.state._")
local items = require("src.config.items")
local debug = require("src.lib.debug._")

return function(changedItems)
  for _, changedItemIndex in ipairs(changedItems) do
    if changedItemIndex == items.targetTrackName.index then
      local targetTrackName = remote.get_item_text_value(changedItemIndex)
      --debug.log("SSt: target track name is " .. targetTrackName)
      state.set("deviceType", targetTrackName)
      --state.set("display", targetTrackName)
    elseif changedItemIndex == items.documentName.index then
      local documentName = remote.get_item_text_value(changedItemIndex)
      debug.log("SSt: document name is now " .. documentName)
      state.set("documentName", documentName)
      --state.set("display", documentName)
    elseif changedItemIndex == items.deviceType.index then
      local deviceType = remote.get_item_text_value(changedItemIndex)
      --debug.log("SSt: device type is " .. deviceType)
      state.set("deviceType", deviceType)
    elseif changedItemIndex == items.deviceName.index then
      local deviceName = remote.get_item_text_value(changedItemIndex)
      --debug.log("SSt: device name is " .. deviceName)
      state.set("deviceName", deviceName)
      --state.set("display", deviceName)
    elseif changedItemIndex == items.patchName.index then
      local patchName = remote.get_item_text_value(changedItemIndex)
      --debug.log("SSt: patch name is " .. patchName)
      state.set("patchName", patchName)
      state.set("display", patchName)
    end
  end
end
