local state = require "src.lib.state._"
local items = require "src.config.items"
local deb = require "src.lib.debug._"

-- The names a Combinator's labels are looked up under (see
-- lib/display/getDisplayName), so a change to either of them puts different
-- labels on the display without any parameter changing its name.
local function setLookupName(path, name)
  if name ~= state.get(path) then
    state.forceParamUpdate()
  end
  state.set(path, name)
end

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
      setLookupName("deviceName", remote.get_item_text_value(hostItemIndex))
    elseif hostItemIndex == items.patchName.index then
      setLookupName("patchName", remote.get_item_text_value(hostItemIndex))
    end
  end
end
