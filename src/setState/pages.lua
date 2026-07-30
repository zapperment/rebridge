local items = require("src.config.items")
local const = require("src.config.constants")
local pages = require("src.lib.state.pages")
local debug = require("src.lib.debug._")

-- Handles changes of the page selectors reported by the host (Reason). A
-- selector is enabled while the target device's remote map binds it to a page
-- variation, and carries a value above zero while its page is the selected
-- one. From that the codec learns how many pages the device has and which one
-- is active, wherever the change came from: the page buttons, another surface
-- or the host switching devices.
return function(changedItems)
  local changed = false
  for _, changedItemIndex in ipairs(changedItems) do
    for i = 1, const.counts.pageSelects do
      if changedItemIndex == items["pageSelect" .. i].index then
        local changedItem = remote.get_item_state(changedItemIndex)
        pages.enabled[i] = changedItem.is_enabled
        pages.selected[i] = changedItem.is_enabled and changedItem.value > 0
        changed = true
      end
    end
  end

  if changed then
    local count = 0
    local active
    for i = 1, const.counts.pageSelects do
      if pages.enabled[i] then
        count = count + 1
        if active == nil and pages.selected[i] then
          active = i
        end
      end
    end
    pages.count = count
    pages.setActive(active or 1)
  end
end
