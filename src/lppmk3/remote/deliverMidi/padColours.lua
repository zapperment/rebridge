local deb = require "src.lib.debug._"
local const = require "src.lppmk3.config.constants"
local ctrl = require "src.lppmk3.config.controls"
local padControllers = require "src.lppmk3.config.padControllers"
local state = require "src.lppmk3.lib.state._"
local midi = require "src.lppmk3.lib.midi._"
local col = require "src.lppmk3.lib.colour._"

-- called regularly by the codec to update the remote surface (Launchpad)
return function()
  local logMe = false
  local events = {}
  for _, pattern in ipairs(ctrl.patterns) do
    local enabled, enabledChanged = state.update(pattern .. ".enabled")
    local hostValue, hostValueChanged = state.update(pattern .. ".hostValue")
    local colours = {}
    local coloursChanged = false
    for value = 1, const.counts.patternValues do
      local colour, colourChanged = state.update(pattern .. ".colour" .. value)
      colours[value] = colour
      coloursChanged = coloursChanged or colourChanged
    end
    if not enabled and enabledChanged then
      -- the pattern has just been disabled, clear its pads
      for _, padController in ipairs(padControllers[pattern]) do
        table.insert(events, midi.makeColourEvent(padController, col.config.off))
      end
    elseif enabled and (enabledChanged or hostValueChanged or coloursChanged) then
      if logMe then
        deb.log(
          "[lppmk3.deliverMidi.padColours] " ..
          "pattern=" .. pattern
        )
        deb.log(
          "[lppmk3.deliverMidi.padColours] " ..
          "hostValue=" .. hostValue
        )
      end
      for index, padController in ipairs(padControllers[pattern]) do
        local colour = col.unselectedPatternColour(colours[index])
        if index == hostValue then
          colour = colours[index]
        end
        table.insert(events, midi.makeColourEvent(padController, colour))
      end
    end
  end
  return events
end
