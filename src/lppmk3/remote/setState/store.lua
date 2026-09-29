local items = require "src.lppmk3.config.items"
local state = require "src.lppmk3.lib.state._"

-- the name the host reports for the given item, or nil while the item is not
-- mapped, as the LaunchEon's name is while another device has remote focus
local function nameOf(hostItemIndex)
  if not remote.is_item_enabled(hostItemIndex) then
    return nil
  end
  return remote.get_item_text_value(hostItemIndex)
end

-- handles changes of the names of the song and the LaunchEon, which together
-- tell the surface store whose colours to keep
return function(hostItems)
  for _, hostItemIndex in ipairs(hostItems) do
    if hostItemIndex == items.documentName.index then
      state.set("store.documentName", nameOf(hostItemIndex))
    elseif hostItemIndex == items.deviceName.index then
      state.set("store.deviceName", nameOf(hostItemIndex))
    end
  end
end
