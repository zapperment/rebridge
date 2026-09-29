local const = require "src.lppmk3.config.constants"
local switchMeter = require "src.lppmk3.config.switchMeter"
local state = require "src.lppmk3.lib.state._"
local timing = require "src.lppmk3.lib.timing._"
local midi = require "src.lppmk3.lib.midi._"
local col = require "src.lppmk3.lib.colour._"

-- the number of buttons of the switch meter to light: none while the Pattern
-- Timer is off or the song position is not known yet
local function litButtons()
  local interval = timing.switchInterval(state.get "patternTimer")
  local songPosition = state.get "songPosition"
  if not interval or not songPosition then
    return 0
  end
  return timing.switchMeterSteps(songPosition, interval)
end

-- called regularly by the codec to update the switch meter: its lit buttons
-- are vibrant and pulsing while the transport is playing, dim and static while
-- it is stopped, the others off; only buttons whose look changes are sent, so
-- as not to disturb the pulsing of the others
return function()
  local events = {}
  local lit = litButtons()
  local playing = state.get "transport.playing"
  for index, button in ipairs(switchMeter) do
    local colour = col.config.off
    local behaviour = const.colourBehaviour.static
    if index <= lit then
      colour = playing and button.colour.vibrant or button.colour.dim
      behaviour = playing and const.colourBehaviour.pulsing or const.colourBehaviour.static
    end
    local path = "switchMeter.button" .. index
    state.set(path .. ".colour", colour)
    state.set(path .. ".behaviour", behaviour)
    local _, colourChanged = state.update(path .. ".colour")
    local _, behaviourChanged = state.update(path .. ".behaviour")
    if colourChanged or behaviourChanged then
      table.insert(events, midi.makeColourEvent(button.controller, colour, behaviour))
    end
  end
  return events
end
