local items = require("src.config.items")
local const = require("src.config.constants")
local state = require("src.lib.state._")
local deb = require("src.lib.debug._")

-- Handles changes of the page selectors reported by the host (Reason). A
-- selector is enabled while the target device's remote map binds it to a page
-- variation, and carries a value above zero while its page is the selected
-- one. From that the codec learns how many pages the device has and which one
-- is active, wherever the change came from: the page buttons, another surface
-- or the host switching devices.
return function(changedItems)
  local hasChanged
  for _, changedItemIndex in ipairs(changedItems) do
    for i = 1, const.counts.pageSelects do
      if changedItemIndex == items["pageSelect" .. i].index then
        hasChanged = true
        local changedItem = remote.get_item_state(changedItemIndex)
        state.setPageState(i, changedItem)
      end
    end
  end

  if hasChanged then
    state.updatePages()
  end
end
