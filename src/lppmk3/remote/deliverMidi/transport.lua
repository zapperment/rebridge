local const = require "src.lppmk3.config.constants"
local items = require "src.lppmk3.config.items"
local state = require "src.lppmk3.lib.state._"
local midi = require "src.lppmk3.lib.midi._"
local col = require "src.lppmk3.lib.colour._"

local pulsing = const.colourBehaviour.pulsing

-- called regularly by the codec to update the play and record button LEDs:
-- dim and static while off, bright and pulsing while on; it only reads whether
-- the transport is playing, which the pad colours then mark as delivered (see
-- remote/deliverMidi/padColours), so it has to be called before them
return function()
  local events = {}

  if state.hasChanged "transport.playing" then
    local playing = state.get "transport.playing"
    local colour = playing and col.config.green.vibrant or col.config.green.dim
    local behaviour = playing and pulsing or nil
    table.insert(events, midi.makeColourEvent(items.playButton.controller, colour, behaviour))
  end

  if state.hasChanged "transport.recording" then
    local recording = state.update "transport.recording"
    local colour = recording and col.config.red.vibrant or col.config.red.dim
    local behaviour = recording and pulsing or nil
    table.insert(events, midi.makeColourEvent(items.recordButton.controller, colour, behaviour))
  end

  return events
end
