local const = require "src.lcxl3.config.constants"
local pageNames = require "src.config.pageNames"
local PageManager = {}

-- Tracks the parameter pages of the target device, fed by the pageSelect
-- items (see setState/pages): count is how many pages the device's remote map
-- defines (0 when it has no page group), active is the page currently
-- selected. enabled and selected mirror what the host last reported per
-- selector.
function PageManager:new(config)
  local instance = {
    active = 1,
    count = 0,
    enabled = {},
    selected = {},
    displayPending = false,
    state = config.state
  }
  setmetatable(instance, self)
  self.__index = self
  return instance
end

-- records the page now selected; switching to another page of a device that
-- has pages brings up the display, so that it is clear which page the controls
-- are on now
function PageManager:setActive(page)
  if page == self.active then
    return
  end
  self.active = page
  if self.count > 0 then
    self.displayPending = true
  end
end

function PageManager:getActive()
  return self.active
end

function PageManager:getCount()
  return self.count
end

function PageManager:consumeDisplay()
  local pending = self.displayPending
  self.displayPending = false
  return pending
end

function PageManager:reset()
  self.active = 1
  self.count = 0
  self.enabled = {}
  self.selected = {}
  self.displayPending = false
end

function PageManager:select(step)
  local nextActive = self.active + step
  if self.count == 0 then
    return
  end
  if nextActive < 1 then
    nextActive = self.count
  end
  if nextActive > self.count then
    nextActive = 1
  end
  self:setActive(nextActive)
  return nextActive
end

function PageManager:setState(pageNumber, itemState)
  local isEnabled = itemState.is_enabled
  local hostValue = itemState.value
  self.enabled[pageNumber] = isEnabled
  self.selected[pageNumber] = isEnabled and hostValue > 0
end

function PageManager:update()
  local count = 0
  local active
  for i = 1, const.counts.pageSelects do
    if self.enabled[i] then
      count = count + 1
      if active == nil and self.selected[i] then
        active = i
      end
    end
  end
  self.count = count
  self:setActive(active or 1)
  self.state:reset()
end

function PageManager:getLabelAndName()
  local names = pageNames[self.state:get "deviceType"]
  local name = names and names[self.active] or " "
  local label = "Page " .. self.active
  return label, name
end

return PageManager
