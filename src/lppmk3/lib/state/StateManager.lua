local tbl = require "src.lib.table._"
local const = require "src.lppmk3.config.constants"
local ctrl = require "src.lppmk3.config.controls"
local patternColours = require "src.lppmk3.config.patternColours"

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
    shifted = false,
    -- LaunchEon's Pattern Timer, 0 (off) to 5 (4 bars)
    patternTimer = entry(0),
    transport = {
      -- start out as changed, so that the play and record buttons are lit from
      -- the start
      playing = { current = nil, next = false },
      recording = { current = nil, next = false },
    },
    songPosition = entry(nil),
    -- the colour and behaviour each button of the switch meter was last lit
    -- with (button1 ... button8), starting out unknown so that the meter is
    -- delivered from the start
    switchMeter = {},
    -- what the codec knows about the song and LaunchEon, and where it stands
    -- with the surface store (see remote/deliverMidi/store)
    store = {
      documentName = entry(nil),
      deviceName = entry(nil),
      requestedKey = entry(nil),
      awaitingReply = entry(false),
      dirty = entry(false),
    },
  }
  for button = 1, const.counts.switchMeterButtons do
    instance.switchMeter["button" .. button] = {
      colour = entry(nil),
      behaviour = entry(nil),
    }
  end
  for _, device in ipairs(ctrl.devices) do
    instance[device] = {
      enabled = entry(false),
      hostValue = entry(nil),
      -- the value actually playing, which lags behind the host value while a
      -- switch is pending (see lib/timing)
      playingValue = entry(nil),
    }
    -- the colour each of the device's patterns is shown in when its pad is lit
    -- (colour1 ... colour8), which is up to the user rather than the host (see
    -- remote/processMidi/pads)
    for value = 1, const.counts.patternValues do
      instance[device]["colour" .. value] = entry(patternColours[1])
    end
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
