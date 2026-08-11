local StateManager = require("src.lib.state.StateManager")

local stateManager = StateManager:new()

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
}
