local tbl = require "src.lib.table._"

local StateManager = {}

function StateManager:new()
  local instance = {
    shifted = false,
    transport = {
      -- start out as changed, so that the play and record buttons are lit from
      -- the start
      playing = { current = nil, next = false },
      recording = { current = nil, next = false },
    },
  }
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function StateManager:hasChanged(path)
  local item = tbl.getValueFromPath(self, path)
  if item == nil then
    return false
  end
  return item.next ~= item.current
end

function StateManager:update(path)
  local item = tbl.getValueFromPath(self, path)
  if item == nil then
    return
  end
  local hasChanged = self:hasChanged(path)
  item.current = item.next
  return item.current, hasChanged
end

function StateManager:get(path)
  local item = tbl.getValueFromPath(self, path)
  if item == nil then
    return nil
  end
  return item.next
end

function StateManager:set(path, next)
  local item, parent = tbl.getValueFromPath(self, path)
  if item == nil then
    return
  end
  item.next = next
  return next
end

function StateManager:shift()
  self.shifted = true
end

function StateManager:unshift()
  self.shifted = false
end

function StateManager:setShifted(shifted)
  if type(shifted) ~= "boolean" then
    return
  end
  self.shifted = shifted
end

function StateManager:isShifted()
  return self.shifted
end

return StateManager
