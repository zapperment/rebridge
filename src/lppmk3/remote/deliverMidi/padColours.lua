local deb = require "src.lib.debug._"
local const = require "src.lppmk3.config.constants"
local ctrl = require "src.lppmk3.config.controls"
local padControllers = require "src.lppmk3.config.padControllers"
local state = require "src.lppmk3.lib.state._"
local midi = require "src.lppmk3.lib.midi._"
local col = require "src.lppmk3.lib.colour._"

local flashing = const.colourBehaviour.flashing

-- whether the host value stands for no device, i.e. for stopping the device
local function isStop(hostValue)
  return hostValue == nil or hostValue < 1 or hostValue > const.counts.patternValues
end

-- the events that light a pattern pad: the playing pad is bright, the others
-- dim; while a switch is pending, the pending pad flashes between dim and
-- bright, or for a pending stop, the playing pad between bright and dim (the
-- Launchpad flashes between the static colour and the flashing one)
local function makePadEvents(padController, index, colour, hostValue, playingValue)
  local dim = col.unselectedPatternColour(colour)
  if index == playingValue then
    local events = { midi.makeColourEvent(padController, colour) }
    if hostValue ~= playingValue and isStop(hostValue) then
      table.insert(events, midi.makeColourEvent(padController, dim, flashing))
    end
    return events
  end
  local events = { midi.makeColourEvent(padController, dim) }
  if index == hostValue then
    table.insert(events, midi.makeColourEvent(padController, colour, flashing))
  end
  return events
end

-- called regularly by the codec to update the remote surface (Launchpad)
return function()
  local logMe = false
  local events = {}
  for _, device in ipairs(ctrl.devices) do
    local enabled, enabledChanged = state.update(device .. ".enabled")
    local hostValue, hostValueChanged = state.update(device .. ".hostValue")
    local playingValue, playingValueChanged = state.update(device .. ".playingValue")
    local colours = {}
    local coloursChanged = false
    for value = 1, const.counts.patternValues do
      local colour, colourChanged = state.update(device .. ".colour" .. value)
      colours[value] = colour
      coloursChanged = coloursChanged or colourChanged
    end
    if not enabled and enabledChanged then
      -- the device has just been disabled, clear its pads
      for _, padController in ipairs(padControllers[device]) do
        table.insert(events, midi.makeColourEvent(padController, col.config.off))
      end
    elseif enabled and (enabledChanged or hostValueChanged or playingValueChanged or coloursChanged) then
      if logMe then
        deb.log(
          "[lppmk3.deliverMidi.padColours] " ..
          "device=" .. device
        )
        deb.log(
          "[lppmk3.deliverMidi.padColours] " ..
          "hostValue=" .. hostValue
        )
      end
      for index, padController in ipairs(padControllers[device]) do
        for _, event in ipairs(makePadEvents(padController, index, colours[index], hostValue, playingValue)) do
          table.insert(events, event)
        end
      end
    end
  end
  return events
end
