local StateManager = require "src.lppmk3.lib.state.StateManager"

local stateManager = StateManager:new()

return {
  hasChanged = function(path)
    return stateManager:hasChanged(path)
  end,
  update = function(path)
    return stateManager:update(path)
  end,
  get = function(path)
    return stateManager:get(path)
  end,
  set = function(path, next)
    stateManager:set(path, next)
  end,
}
