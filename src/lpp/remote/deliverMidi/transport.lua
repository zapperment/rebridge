local const = require "src.lpp.config.constants"
local items = require "src.lpp.config.items"
local state = require "src.lpp.lib.state._"
local col = require "src.lpp.lib.colour._"

local pulsing = const.colourBehaviour.pulsing

-- makes what the codec calls regularly to update the play and record button
-- LEDs of the device given: dim and static while off, bright and pulsing while
-- on; each change is delivered once
return function(device)
  local makeColourEvent = device.midi.makeColourEvent

  return function()
    local events = {}

    if state.hasChanged "transport.playing" then
      local playing = state.update "transport.playing"
      local colour = playing and col.config.green.vibrant or col.config.green.dim
      local behaviour = playing and pulsing or nil
      table.insert(events, makeColourEvent(items.playButton.controller, colour, behaviour))
    end

    if state.hasChanged "transport.recording" then
      local recording = state.update "transport.recording"
      local colour = recording and col.config.red.vibrant or col.config.red.dim
      local behaviour = recording and pulsing or nil
      table.insert(events, makeColourEvent(items.recordButton.controller, colour, behaviour))
    end

    return events
  end
end
