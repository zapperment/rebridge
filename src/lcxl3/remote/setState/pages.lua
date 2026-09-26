local items = require "src.lcxl3.config.items"
local const = require "src.lcxl3.config.constants"
local state = require "src.lcxl3.lib.state._"
local deb = require "src.lib.debug._"

-- Handles changes of the page selectors reported by the host (Reason). A
-- selector is enabled while the target device's remote map binds it to a page
-- variation, and carries a value above zero while its page is the selected
-- one. From that the codec learns how many pages the device has and which one
-- is active, wherever the change came from: the page buttons, another surface
-- or the host switching devices.
return function(hostItems)
  local hasChanged
  for _, hostItemIndex in ipairs(hostItems) do
    for i = 1, const.counts.pageSelects do
      if hostItemIndex == items["pageSelect" .. i].index then
        hasChanged = true
        local changedItem = remote.get_item_state(hostItemIndex)
        state.setPageState(i, changedItem)
      end
    end
  end

  if hasChanged then
    state.updatePages()
  end
end
