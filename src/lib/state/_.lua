local StateManager = require("src.lib.state.StateManager")
local PageManager = require("src.lib.state.PageManager")

local stateManager = StateManager:new()
local pageManager = PageManager:new({ state = stateManager })

return {
  hasChanged = function(path)
    return stateManager:hasChanged(path)
  end,
  update = function(path)
    return stateManager:update(path)
  end,
  updateAll = function()
    stateManager:updateAll()
  end,
  get = function(path)
    return stateManager:get(path)
  end,
  getHostValue = function(param)
    return stateManager:getHostValue(param)
  end,
  set = function(path, next)
    stateManager:set(path, next)
  end,
  add = function(path, delta, min, max)
    stateManager:add(path, delta, min, max)
  end,
  flip = function(path)
    return stateManager:flip(path)
  end,
  inc = function(path)
    stateManager:inc(path)
  end,
  dec = function(path)
    stateManager:dec(path)
  end,
  shift = function()
    stateManager:shift()
  end,
  unshift = function()
    stateManager:unshift()
  end,
  setShifted = function(shifted)
    stateManager:setShifted(shifted)
  end,
  isShifted = function()
    return stateManager:isShifted()
  end,
  forceDisplay = function(control)
    stateManager:forceDisplay(control)
  end,
  isDisplayForced = function(control)
    return stateManager:isDisplayForced(control)
  end,
  canForceDisplay = function(control)
    return stateManager:canForceDisplay(control)
  end,
  useAlternative = function(control)
    stateManager:useAlternative(control)
  end,
  isUsingAlternative = function(control)
    return stateManager:isUsingAlternative(control)
  end,
  canUseAlternative = function(control)
    return stateManager:canUseAlternative(control)
  end,
  setActivePage = function(page)
    pageManager:setActive(page)
  end,
  consumePageDisplay = function()
    return pageManager:consumeDisplay()
  end,
  resetPages = function()
    pageManager:reset()
  end,
  selectPage = function(step)
    return pageManager:select(step)
  end,
  setPageState = function(pageNumber, itemState)
    pageManager:setState(pageNumber, itemState)
  end,
  updatePages = function()
    pageManager:update()
  end,
  getPageLabelAndName = function()
    return pageManager:getLabelAndName()
  end,
}
