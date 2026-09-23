local const = require "src.lcxl3.config.constants"
local ctrl = require "src.lcxl3.config.controls"
local selections = require "src.config.selections"

local SelectionManager = {}

-- Tracks the selection of a selecting device, fed by the selector item, which
-- the remote map binds to the device's selector parameter, and by the option
-- selectors, which it binds to the group values that hold each option's mapping
-- (see setState/selection). Options are numbered from 1; option 0 stands for no
-- option being selected.
--
-- The host owns which option is selected. The codec only keeps the group in
-- step with it, and can only switch the group while it handles MIDI from the
-- surface (see processMidi/selection), so whenever the two disagree it asks the
-- surface for a reply to handle (see deliverMidi/selection and ADR 0003).
--
-- What the delivery needs to know is kept in the state manager's selection
-- entries, so that it can tell what has changed since the last delivery.
function SelectionManager:new(config)
  local instance = {
    selectorName = nil,
    optionEnabled = {},
    optionSelected = {},
    -- the option whose group is in force, nil while the host has not said
    active = nil,
    -- the option the codec last pinged the surface for and last switched the
    -- group to, so that it asks only once for each
    pingedFor = nil,
    switchedFor = nil,
    pingPending = false,
    state = config.state
  }
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function SelectionManager:reset()
  self.selectorName = nil
  self.optionEnabled = {}
  self.optionSelected = {}
  self.active = nil
  self.pingedFor = nil
  self.switchedFor = nil
  self.pingPending = false
  self.state:set("selection.enabled", false)
  self.state:set("selection.selected", 0)
  self.state:set("selection.count", 0)
end

-- the selector item is enabled only while the target device is a selecting
-- device; its value is -1 while no option is selected
function SelectionManager:setSelectorState(itemState)
  local enabled = itemState.is_enabled
  self.state:set("selection.enabled", enabled)
  if not enabled then
    self.state:set("selection.selected", 0)
    return
  end
  self.selectorName = itemState.remote_item_name
  self.state:set("selection.selected", math.max(0, math.floor(itemState.value + 0.5) + 1))
end

function SelectionManager:setOptionState(option, itemState)
  self.optionEnabled[option] = itemState.is_enabled
  self.optionSelected[option] = itemState.is_enabled and itemState.value > 0
end

function SelectionManager:update()
  local count = 0
  for option = 1, const.counts.options do
    if self.optionEnabled[option] then
      count = count + 1
    end
  end
  self.state:set("selection.count", count)
  self.active = nil
  for option = 0, const.counts.options do
    if self.optionSelected[option] then
      self.active = option
      break
    end
  end
  if self:isInStep() then
    self.pingedFor = nil
    self.switchedFor = nil
  elseif self.pingedFor ~= self:getSelected() then
    self.pingedFor = self:getSelected()
    self.pingPending = true
  end
end

function SelectionManager:isEnabled()
  return self.state:get "selection.enabled"
end

function SelectionManager:getSelected()
  return self.state:get "selection.selected"
end

function SelectionManager:getCount()
  return self.state:get "selection.count"
end

-- whether the group in force is the one of the selected option; a group the
-- remote map does not define cannot be switched to, so there is nothing to do
function SelectionManager:isInStep()
  local selected = self:getSelected()
  return not self:isEnabled()
      or self.active == selected
      or not self.optionEnabled[selected]
end

-- the option whose group the codec should switch to now, or nil when the group
-- is in step or the codec has already switched it for the selected option
function SelectionManager:takeSwitch()
  local selected = self:getSelected()
  if self:isInStep() or self.switchedFor == selected then
    return nil
  end
  self.switchedFor = selected
  return selected
end

function SelectionManager:consumePing()
  local pending = self.pingPending
  self.pingPending = false
  return pending
end

-- the value to give the selector parameter when the selection button of the
-- given option is pressed: pressing the button of the selected option
-- deselects it
function SelectionManager:getSelectorValueFor(option)
  if option == self:getSelected() then
    return -1
  end
  return option - 1
end

-- whether the button is one of the selection buttons of the target device,
-- which then belong to the selection rather than to a parameter
function SelectionManager:isSelectionButton(control)
  if not self:isEnabled() then
    return false
  end
  for _, selectionButton in ipairs(ctrl.selectionButtons) do
    if selectionButton == control then
      return true
    end
  end
  return false
end

function SelectionManager:getSelectorName()
  return self.selectorName or " "
end

-- the label of the given option, or of no option being selected for option 0
function SelectionManager:getOptionLabel(option)
  local selection = selections[self.state:get "deviceType"] or {}
  if option == 0 then
    return selection.none or "None"
  end
  return selection.options and selection.options[option] or tostring(option)
end

function SelectionManager:getColour(defaultColour)
  local selection = selections[self.state:get "deviceType"] or {}
  return selection.colour or defaultColour
end

return SelectionManager
