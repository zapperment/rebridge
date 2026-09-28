local tbl = require "src.lib.table._"
local ctrl = require "src.lppmk3.config.controls"

local StateManager = {}

local function entry(value)
  return {
    current = value,
    next = value,
  }
end

function StateManager:new()
  local instance = {
    deviceType = entry " ",
  }
  for _, pattern in ipairs(ctrl.patterns) do
    instance[pattern] = {
      enabled = entry(false),
      hostValue = entry(nil),
    }
  end
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

return StateManager
