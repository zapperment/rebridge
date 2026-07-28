-- Tracks the parameter pages of the target device, fed by the pageSelect
-- items (see setState/pages): count is how many pages the device's remote map
-- defines (0 when it has no page group), active is the page currently
-- selected. enabled and selected mirror what the host last reported per
-- selector.
local pages = {
  active = 1,
  count = 0,
  enabled = {},
  selected = {},
  displayPending = false,
}

-- records the page now selected; switching to another page of a device that
-- has pages brings up the display, so that it is clear which page the controls
-- are on now
function pages.setActive(page)
  if page == pages.active then
    return
  end
  pages.active = page
  if pages.count > 0 then
    pages.displayPending = true
  end
end

function pages.consumeDisplay()
  local pending = pages.displayPending
  pages.displayPending = false
  return pending
end

function pages.reset()
  pages.active = 1
  pages.count = 0
  pages.enabled = {}
  pages.selected = {}
  pages.displayPending = false
end

return pages
